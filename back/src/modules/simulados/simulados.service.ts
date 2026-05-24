import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';
import { redis, keys, TTL } from '../../shared/redis';
import { Prisma } from '@prisma/client';

const FREE_MAX_Q_PER_SIMULADO = 20;
const FREE_MAX_Q_PER_DAY = 15;

interface StartParams {
  mode: string;
  subject?: string;
  subjects?: string[];
  totalQ: number;
  excludeAnswered?: boolean;
  isPro: boolean;
}

interface AnswerParams {
  questionId: string;
  answer: string;
  timeSpentSecs?: number;
  isPro: boolean;
}

export class SimuladosService {
  async listQuestions(filters: {
    subject?: string;
    lawCode?: string;
    difficulty?: string;
    limit: number;
  }) {
    return db.question.findMany({
      where: {
        ...(filters.subject && { subject: filters.subject }),
        ...(filters.lawCode && { lawCode: filters.lawCode }),
        ...(filters.difficulty && { difficulty: filters.difficulty }),
      },
      take: filters.limit,
      select: {
        id: true,
        statement: true,
        options: true,
        subject: true,
        topic: true,
        lawCode: true,
        board: true,
        year: true,
        phase: true,
        difficulty: true,
        isPro: true,
      },
    });
  }

  async startAttempt(userId: string, params: StartParams) {
    // Free: máximo 20 questões por simulado
    if (!params.isPro && params.totalQ > FREE_MAX_Q_PER_SIMULADO) {
      throw Errors.badRequest(
        `Plano Free: máximo ${FREE_MAX_Q_PER_SIMULADO} questões por simulado`,
      );
    }

    // Constraint: no máximo 1 simulado in_progress por usuário
    const inProgress = await db.simuladoAttempt.findFirst({
      where: { userId, status: 'in_progress' },
      select: { id: true },
    });
    if (inProgress) {
      throw Errors.simuladoInProgress(inProgress.id);
    }

    // Montar condições WHERE incrementalmente
    const conditions: Prisma.Sql[] = [];

    if (params.mode === 'weak_areas') {
      if (!params.isPro) throw Errors.proRequired();
      const since = new Date(Date.now() - 60 * 24 * 60 * 60 * 1000);
      const weakSubjects = await db.$queryRaw<{ subject: string }[]>(Prisma.sql`
        SELECT q.subject,
               COUNT(*) FILTER (WHERE sq.is_correct = true)::float / COUNT(*)::float AS accuracy_rate
        FROM simulado_questions sq
        JOIN questions q ON q.id = sq.question_id
        JOIN simulado_attempts sa ON sa.id = sq.attempt_id
        WHERE sa.user_id = ${userId}
          AND sq.answered_at >= ${since}
          AND sq.student_answer IS NOT NULL
        GROUP BY q.subject
        ORDER BY accuracy_rate ASC
        LIMIT 3
      `);
      if (weakSubjects.length > 0) {
        const names = weakSubjects.map((r) => r.subject);
        conditions.push(
          Prisma.sql`subject IN (${Prisma.join(
            names.map((s) => Prisma.sql`${s}`),
            ', ',
          )})`,
        );
      }
    } else if (params.mode === 'custom' && params.subject) {
      conditions.push(Prisma.sql`subject = ${params.subject}`);
    } else if (params.subjects && params.subjects.length > 0) {
      conditions.push(
        Prisma.sql`subject IN (${Prisma.join(
          params.subjects.map((s) => Prisma.sql`${s}`),
          ', ',
        )})`,
      );
    }

    // excludeAnswered — PRO only
    if (params.excludeAnswered) {
      if (!params.isPro) throw Errors.proRequired();
      conditions.push(
        Prisma.sql`id NOT IN (SELECT question_id FROM user_question_answered WHERE user_id = ${userId})`,
      );
    }

    const whereClause =
      conditions.length > 0
        ? Prisma.sql`WHERE ${Prisma.join(conditions, ' AND ')}`
        : Prisma.empty;

    const rawIds = await db.$queryRaw<{ id: string }[]>(
      Prisma.sql`SELECT id FROM questions ${whereClause} ORDER BY random() LIMIT ${params.totalQ}`,
    );

    if (rawIds.length < params.totalQ) {
      throw Errors.notFound('Questões suficientes para o simulado');
    }

    const questions = await db.question.findMany({
      where: { id: { in: rawIds.map((r) => r.id) } },
    });

    const attempt = await db.simuladoAttempt.create({
      data: {
        userId,
        mode: params.mode,
        totalQ: questions.length,
        subjects: params.subjects ?? (params.subject ? [params.subject] : undefined),
        questions: {
          create: questions.map((q, idx) => ({
            questionId: q.id,
            order: idx + 1,
          })),
        },
      },
      include: { questions: { include: { question: true }, orderBy: { order: 'asc' } } },
    });

    return {
      id: attempt.id,
      mode: attempt.mode,
      status: attempt.status,
      totalQ: attempt.totalQ,
      subjects: attempt.subjects,
      startedAt: attempt.startedAt,
      questions: attempt.questions.map((sq) => ({
        id: sq.id,
        order: sq.order,
        enunciado: sq.question.statement,
        opcoes: sq.question.options as Record<string, string>,
        subject: sq.question.subject,
        difficulty: sq.question.difficulty,
      })),
    };
  }

  async submitAnswer(userId: string, attemptId: string, params: AnswerParams) {
    // Free: limite diário de 15 questões
    if (!params.isPro) {
      const dailyKey = keys.simuladoDaily(userId);
      const count = (await redis.get<number>(dailyKey)) ?? 0;
      if (count >= FREE_MAX_Q_PER_DAY) {
        throw Errors.simuladoDailyLimit();
      }
    }

    const attempt = await db.simuladoAttempt.findFirst({
      where: { id: attemptId, userId },
    });
    if (!attempt) throw Errors.notFound('Simulado');

    const question = await db.question.findUnique({ where: { id: params.questionId } });
    if (!question) throw Errors.notFound('Questão');

    const isCorrect = params.answer === question.correctAnswer;

    await db.simuladoQuestion.updateMany({
      where: { attemptId, questionId: params.questionId },
      data: {
        studentAnswer: params.answer,
        isCorrect,
        timeSpentSecs: params.timeSpentSecs,
        answeredAt: new Date(),
      },
    });

    if (isCorrect) {
      await db.simuladoAttempt.update({
        where: { id: attemptId },
        data: { correctQ: { increment: 1 } },
      });
    }

    // Upsert em UserQuestionAnswered (ignora conflito unique)
    await db.userQuestionAnswered.upsert({
      where: { userId_questionId: { userId, questionId: params.questionId } },
      create: { userId, questionId: params.questionId },
      update: { answeredAt: new Date() },
    });

    // Incrementar contador diário Free
    if (!params.isPro) {
      const dailyKey = keys.simuladoDaily(userId);
      const newCount = await redis.incr(dailyKey);
      if (newCount === 1) {
        await redis.expire(dailyKey, TTL.rateLimitDay);
      }
    }

    return {
      correct: isCorrect,
      correctAnswer: question.correctAnswer,
      ...(params.isPro && question.explanation ? { explanation: question.explanation } : {}),
    };
  }

  async abandonAttempt(userId: string, attemptId: string) {
    const attempt = await db.simuladoAttempt.findFirst({
      where: { id: attemptId, userId },
    });
    if (!attempt) throw Errors.notFound('Simulado');

    return db.simuladoAttempt.update({
      where: { id: attemptId },
      data: { status: 'abandoned' },
      select: { id: true, status: true },
    });
  }

  async getInProgress(userId: string) {
    const attempt = await db.simuladoAttempt.findFirst({
      where: { userId, status: 'in_progress' },
      include: {
        questions: {
          include: { question: true },
          orderBy: { order: 'asc' },
        },
      },
      orderBy: { startedAt: 'desc' },
    });

    if (!attempt) return null;

    return {
      id: attempt.id,
      mode: attempt.mode,
      status: attempt.status,
      totalQ: attempt.totalQ,
      subjects: attempt.subjects,
      startedAt: attempt.startedAt,
      questions: attempt.questions.map((sq) => ({
        id: sq.id,
        order: sq.order,
        enunciado: sq.question.statement,
        opcoes: sq.question.options as Record<string, string>,
        subject: sq.question.subject,
        difficulty: sq.question.difficulty,
      })),
    };
  }

  async completeAttempt(userId: string, attemptId: string) {
    const attempt = await db.simuladoAttempt.findFirst({
      where: { id: attemptId, userId },
    });
    if (!attempt) throw Errors.notFound('Simulado');

    const score = attempt.totalQ > 0 ? (attempt.correctQ / attempt.totalQ) * 100 : 0;

    return db.simuladoAttempt.update({
      where: { id: attemptId },
      data: { completedAt: new Date(), score, status: 'completed' },
    });
  }

  async getResults(userId: string, attemptId: string, isPro: boolean) {
    const attempt = await db.simuladoAttempt.findFirst({
      where: { id: attemptId, userId },
      include: {
        questions: {
          include: { question: true },
          orderBy: { order: 'asc' },
        },
      },
    });
    if (!attempt) throw Errors.notFound('Simulado');

    const total = attempt.totalQ;
    const correct = attempt.correctQ;
    const wrong = total - correct;

    const bySubject: Record<string, { total: number; correct: number }> = {};
    for (const sq of attempt.questions) {
      const subj = sq.question.subject;
      if (!bySubject[subj]) bySubject[subj] = { total: 0, correct: 0 };
      bySubject[subj].total += 1;
      if (sq.isCorrect === true) bySubject[subj].correct += 1;
    }

    return {
      id: attempt.id,
      score: attempt.score,
      total,
      correct,
      wrong,
      completedAt: attempt.completedAt,
      bySubject,
      questions: attempt.questions.map((sq) => ({
        id: sq.id,
        order: sq.order,
        enunciado: sq.question.statement,
        opcoes: sq.question.options as Record<string, string>,
        correctAnswer: sq.question.correctAnswer,
        studentAnswer: sq.studentAnswer,
        isCorrect: sq.isCorrect,
        subject: sq.question.subject,
        ...(isPro && sq.question.explanation ? { explanation: sq.question.explanation } : {}),
      })),
    };
  }

  async getHistory(userId: string) {
    const items = await db.simuladoAttempt.findMany({
      where: { userId, completedAt: { not: null } },
      orderBy: { completedAt: 'desc' },
      take: 20,
      select: {
        id: true,
        mode: true,
        totalQ: true,
        correctQ: true,
        score: true,
        completedAt: true,
      },
    });

    return items.map((a) => ({
      id: a.id,
      score: a.score,
      totalQuestions: a.totalQ,
      correctAnswers: a.correctQ,
      completedAt: a.completedAt,
      mode: a.mode,
    }));
  }
}
