import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

type AcademicPhase = 'graduation_start' | 'graduation_mid' | 'graduation_end' | 'oab_prep';

export class UsersService {
  async getProfile(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');
    return profile;
  }

  async updateProfile(
    userId: string,
    data: { name?: string; avatarUrl?: string; academicPhase?: AcademicPhase },
  ) {
    const updateData: Record<string, unknown> = {};

    if (data.name !== undefined) updateData.name = data.name;
    if (data.avatarUrl !== undefined) updateData.avatarUrl = data.avatarUrl;

    if (data.academicPhase !== undefined) {
      updateData.academicPhase = data.academicPhase;
      // Atualiza nivelamentoPath ao trocar fase
      updateData.nivelamentoPath = data.academicPhase === 'oab_prep' ? 'oab' : 'graduation';
      // nivelamentoPendente NÃO é alterado pela troca de academicPhase (T21, RF14)
    }

    return db.profile.update({ where: { userId }, data: updateData });
  }

  async updateNotifications(
    userId: string,
    data: { notifEnabled: boolean; notifTime?: string; oneSignalPlayerId?: string },
  ) {
    return db.profile.update({ where: { userId }, data });
  }
}
