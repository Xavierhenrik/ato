import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

function startOfDay(date: Date): Date {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
}

function prevWeekday(from: Date): Date {
  const d = new Date(from);
  do { d.setDate(d.getDate() - 1); } while (d.getDay() === 0 || d.getDay() === 6);
  return d;
}

export class DashboardService {
  async getHomeData(userId: string) {
    const [profile, subscription] = await Promise.all([
      db.profile.findUnique({ where: { userId } }),
      db.subscription.findUnique({ where: { userId } }),
    ]);

    if (!profile) throw Errors.notFound('Perfil');

    const today = startOfDay(new Date());

    // questionsAnsweredToday — conta SimuladoQuestion com studentAnswer NOT NULL e answeredAt >= hoje 00:00
    const questionsAnsweredToday = await db.simuladoQuestion.count({
      where: {
        attempt: { userId },
        studentAnswer: { not: null },
        answeredAt: { gte: today },
      },
    });

    // topicsReadToday — conta TopicRead com readAt >= hoje 00:00
    const topicsReadToday = await db.topicRead.count({
      where: {
        userId,
        readAt: { gte: today },
      },
    });

    return {
      name: profile.name,
      plan: subscription?.plan ?? 'free',
      oabMode: profile.academicPhase === 'oab_prep',
      nivelamentoPendente: profile.nivelamentoPendente,
      streak: {
        current: profile.streakDays,
        longest: profile.longestStreak,
      },
      dailyProgress: {
        questionsAnsweredToday,
        topicsReadToday,
        dailyGoalMins: profile.dailyStudyMins ?? 60,
      },
    };
  }

  async getRevisionCards(userId: string) {
    const twoWeeksAgo = new Date();
    twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);

    const [rows, studyPlan] = await Promise.all([
      db.simuladoQuestion.findMany({
        where: {
          attempt: { userId },
          answeredAt: { gte: twoWeeksAgo },
          studentAnswer: { not: null },
        },
        include: {
          question: { select: { subject: true, lawCode: true, topicId: true } },
        },
      }),
      db.studyPlan.findUnique({
        where: { userId },
        select: { weakTopics: true, analyzedAt: true },
      }),
    ]);

    type SubjectBucket = {
      lawCode: string | null;
      total: number;
      errors: number;
      topicErrors: Map<string, number>;
    };
    const subjectMap = new Map<string, SubjectBucket>();

    for (const row of rows) {
      const subject = row.question.subject;
      const existing = subjectMap.get(subject) ?? {
        lawCode: row.question.lawCode,
        total: 0,
        errors: 0,
        topicErrors: new Map<string, number>(),
      };
      existing.total += 1;
      if (row.isCorrect === false) {
        existing.errors += 1;
        const topicId = row.question.topicId;
        if (topicId) {
          existing.topicErrors.set(topicId, (existing.topicErrors.get(topicId) ?? 0) + 1);
        }
      }
      subjectMap.set(subject, existing);
    }

    // Camada 2: use Sonnet profile if analyzed within last 7 days
    type WeakEntry = { id: string; title: string; priority: number };
    const CAMADA2_TTL_DAYS = 7;
    let weakBySubject: Record<string, WeakEntry[]> | null = null;
    if (studyPlan?.analyzedAt && studyPlan.weakTopics) {
      const daysSince = (Date.now() - studyPlan.analyzedAt.getTime()) / (1000 * 60 * 60 * 24);
      if (daysSince < CAMADA2_TTL_DAYS) {
        weakBySubject = studyPlan.weakTopics as Record<string, WeakEntry[]>;
      }
    }

    // Camada 1: top 3 topicIds per subject by error count (fallback when Camada 2 not available)
    const allTopicIds = new Set<string>();
    const subjectTop3 = new Map<string, { id: string; errors: number }[]>();

    if (!weakBySubject) {
      for (const [subject, data] of subjectMap.entries()) {
        const top3 = Array.from(data.topicErrors.entries())
          .sort((a, b) => b[1] - a[1])
          .slice(0, 3)
          .map(([id, errors]) => ({ id, errors }));
        subjectTop3.set(subject, top3);
        top3.forEach(({ id }) => allTopicIds.add(id));
      }

      const topicTitleMap = new Map<string, string>();
      if (allTopicIds.size > 0) {
        const topics = await db.topic.findMany({
          where: { id: { in: Array.from(allTopicIds) } },
          select: { id: true, title: true },
        });
        topics.forEach(t => topicTitleMap.set(t.id, t.title));
      }

      const cards = Array.from(subjectMap.entries())
        .map(([subject, data]) => {
          const top3 = subjectTop3.get(subject) ?? [];
          return {
            subject,
            lawCode: data.lawCode ?? '',
            errorRate: data.total > 0 ? data.errors / data.total : 0,
            totalAnswered: data.total,
            priority: (data.total > 0 && data.errors / data.total > 0.5) ? 'high' : 'scheduled',
            topTopics: top3
              .map(({ id, errors }) => ({ id, title: topicTitleMap.get(id) ?? '', errors }))
              .filter(t => t.title !== ''),
          };
        })
        .sort((a, b) => b.errorRate - a.errorRate);

      return { cards };
    }

    // Camada 2 path: Sonnet-ranked topics, real error counts from 14-day window
    const cards = Array.from(subjectMap.entries())
      .map(([subject, data]) => {
        const sonnetTopics = (weakBySubject![subject] ?? [])
          .sort((a, b) => a.priority - b.priority)
          .slice(0, 3)
          .map(t => ({
            id: t.id,
            title: t.title,
            errors: data.topicErrors.get(t.id) ?? 0,
          }));
        return {
          subject,
          lawCode: data.lawCode ?? '',
          errorRate: data.total > 0 ? data.errors / data.total : 0,
          totalAnswered: data.total,
          priority: (data.total > 0 && data.errors / data.total > 0.5) ? 'high' : 'scheduled',
          topTopics: sonnetTopics,
        };
      })
      .sort((a, b) => b.errorRate - a.errorRate);

    return { cards };
  }

  async getPerformanceHub(userId: string) {
    const rows = await db.simuladoQuestion.findMany({
      where: {
        attempt: { userId },
        studentAnswer: { not: null },
      },
      include: {
        question: { select: { subject: true } },
      },
    });

    const totalAnswered = rows.length;
    const totalCorrect = rows.filter(r => r.isCorrect === true).length;
    const globalAccuracyRate = totalAnswered > 0 ? totalCorrect / totalAnswered : 0;

    // Breakdown por subject
    const subjectMap = new Map<string, { answered: number; correct: number }>();
    for (const row of rows) {
      const subject = row.question.subject;
      const existing = subjectMap.get(subject) ?? { answered: 0, correct: 0 };
      existing.answered += 1;
      if (row.isCorrect === true) existing.correct += 1;
      subjectMap.set(subject, existing);
    }

    const bySubject = Array.from(subjectMap.entries()).map(([subject, data]) => ({
      subject,
      answered: data.answered,
      correct: data.correct,
      accuracyRate: data.answered > 0 ? data.correct / data.answered : 0,
    }));

    return {
      totalAnswered,
      globalAccuracyRate,
      oabBaseline: 0.60,
      bySubject,
    };
  }

  async getStreakData(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    return {
      current: profile.streakDays,
      longest: profile.longestStreak,
      lastStudyDate: profile.lastStudyDate,
    };
  }

  async logStudySession(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    // RF21: fins de semana não quebram nem incrementam o streak
    const todayDow = new Date().getDay();
    if (todayDow === 0 || todayDow === 6) {
      return { streak: profile.streakDays, updated: false };
    }

    const today = startOfDay(new Date());
    const lastStudy = profile.lastStudyDate ? startOfDay(new Date(profile.lastStudyDate)) : null;

    if (lastStudy?.getTime() === today.getTime()) {
      return { streak: profile.streakDays, updated: false };
    }

    const prevWorkday = prevWeekday(today);
    const isYesterday = lastStudy?.getTime() === prevWorkday.getTime();
    const newStreak = isYesterday ? profile.streakDays + 1 : 1;

    await db.profile.update({
      where: { userId },
      data: {
        streakDays: newStreak,
        longestStreak: Math.max(newStreak, profile.longestStreak),
        lastStudyDate: new Date(),
      },
    });

    return { streak: newStreak, updated: true };
  }
}
