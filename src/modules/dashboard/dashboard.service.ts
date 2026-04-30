import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

function lastWeekday(from: Date): Date {
  const d = new Date(from);
  do { d.setDate(d.getDate() - 1); } while (d.getDay() === 0 || d.getDay() === 6);
  return d;
}

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

    // RF21: fins de semana não quebram nem incrementam o streak
    const todayDow = new Date().getDay();
    if (todayDow === 0 || todayDow === 6) {
      return { streak: profile.streakDays, updated: false };
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const lastStudy = profile.lastStudyDate ? new Date(profile.lastStudyDate) : null;
    if (lastStudy) lastStudy.setHours(0, 0, 0, 0);

    const isToday = lastStudy?.getTime() === today.getTime();
    if (isToday) return { streak: profile.streakDays, updated: false };

    const prevWorkday = lastWeekday(today);
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
