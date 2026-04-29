import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

interface StartParams {
  mode: string;
  subject?: string;
  totalQ: number;
}

interface AnswerParams {
  questionId: string;
  answer: string;
  timeSpentSecs?: number;
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
    // Seleciona questões aleatórias
    const where =
      params.mode === 'custom' && params.subject ? { subject: params.subject } : {};
    const questions = await db.question.findMany({
      where,
      take: params.totalQ,
      orderBy: { id: 'asc' },
    });

    if (questions.length < params.totalQ) {
      throw Errors.notFound('Questões suficientes para o simulado');
    }

    const attempt = await db.simuladoAttempt.create({
      data: {
        userId,
        mode: params.mode,
        totalQ: questions.length,
        questions: {
          create: questions.map((q, idx) => ({
            questionId: q.id,
            order: idx + 1,
          })),
        },
      },
      include: { questions: { include: { question: true }, orderBy: { order: 'asc' } } },
    });

    return attempt;
  }

  async submitAnswer(userId: string, attemptId: string, params: AnswerParams) {
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

    return { isCorrect, correctAnswer: question.correctAnswer };
  }

  async completeAttempt(userId: string, attemptId: string) {
    const attempt = await db.simuladoAttempt.findFirst({
      where: { id: attemptId, userId },
    });
    if (!attempt) throw Errors.notFound('Simulado');

    const score = attempt.totalQ > 0 ? (attempt.correctQ / attempt.totalQ) * 100 : 0;

    return db.simuladoAttempt.update({
      where: { id: attemptId },
      data: { completedAt: new Date(), score },
    });
  }

  async getResults(userId: string, attemptId: string) {
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
    return attempt;
  }

  async getHistory(userId: string) {
    return db.simuladoAttempt.findMany({
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
  }
}
