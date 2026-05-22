import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

export class AuthService {
  async getOrCreateUser(userId: string) {
    const user = await db.user.findUnique({
      where: { id: userId },
      include: { profile: true, subscription: true },
    });
    if (!user) throw Errors.notFound('Usuário');
    return user;
  }

  async getFullProfile(userId: string) {
    const user = await db.user.findUnique({
      where: { id: userId },
      include: {
        profile: true,
        subscription: true,
        studyPlan: true,
      },
    });
    if (!user) throw Errors.notFound('Usuário');
    return user;
  }

  async deleteAccount(userId: string) {
    // Cascade deletes all related records (profiles, sessions, etc.)
    await db.user.delete({ where: { id: userId } });
  }
}
