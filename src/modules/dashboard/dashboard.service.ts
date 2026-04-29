import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

export class DashboardService {
  async getHomeData(userId: string) {
    const [profile, subscription, recentAttempts] = await Promise.all([
      db.profile.findUnique({ where: { userId } }),
      db.subscription.findUnique({ where: { userId } }),
      db.simuladoAttempt.findMany({
        where: { userId, completedAt: { not: null } },
        orderBy: { completedAt: 'desc' },
        take: 3,
      }),
    ]);

    if (!profile) throw Errors.notFound('Perfil');

    return {
      name: profile.name,
      plan: subscription?.plan ?? 'free',
      streak: {
        current: profile.streakDays,
        longest: profile.longestStreak,
      },
      recentAttempts,
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

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const lastStudy = profile.lastStudyDate ? new Date(profile.lastStudyDate) : null;
    if (lastStudy) lastStudy.setHours(0, 0, 0, 0);

    const isToday = lastStudy?.getTime() === today.getTime();
    if (isToday) return { streak: profile.streakDays, updated: false };

    const isYesterday =
      lastStudy?.getTime() === today.getTime() - 86_400_000;

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
