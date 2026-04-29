import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

export class UsersService {
  async getProfile(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');
    return profile;
  }

  async updateProfile(userId: string, data: { name?: string; avatarUrl?: string }) {
    return db.profile.update({ where: { userId }, data });
  }

  async updateNotifications(
    userId: string,
    data: { notifEnabled: boolean; notifTime?: string; oneSignalPlayerId?: string },
  ) {
    return db.profile.update({ where: { userId }, data });
  }
}
