import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

type AcademicPhase = 'graduation_start' | 'graduation_mid' | 'graduation_end' | 'oab_prep';

const DURATION_BY_PHASE: Record<AcademicPhase, number> = {
  graduation_start: 180,
  graduation_mid: 120,
  graduation_end: 90,
  oab_prep: 90,
};

export class OnboardingService {
  async complete(userId: string, academicPhase: AcademicPhase, dailyStudyMins: number) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    const flow = academicPhase === 'oab_prep' ? 'oab' : 'graduation';
    const nivelamentoPath = flow;

    await db.profile.update({
      where: { userId },
      data: {
        academicPhase,
        dailyStudyMins,
        onboardingDone: true,
        onboardingStep: 1,
        nivelamentoPendente: true,
        nivelamentoPath,
      },
    });

    const studyPlan = await this.upsertStudyPlan(userId, academicPhase, dailyStudyMins);

    return {
      done: true,
      flow,
      nivelamentoPendente: true,
      nivelamentoPath,
      studyPlan: { id: studyPlan.id, durationDays: studyPlan.durationDays, dailyMins: studyPlan.dailyMins },
    };
  }

  async completeQuiz(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    await db.profile.update({
      where: { userId },
      data: { nivelamentoPendente: false, nivelamentoConcluido: true },
    });

    return { nivelamentoPendente: false, nivelamentoConcluido: true };
  }

  async dismissQuiz(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    // Idempotência: se já concluído, não sobrescreve nivelamentoConcluido: true
    if (!profile.nivelamentoConcluido) {
      await db.profile.update({
        where: { userId },
        data: { nivelamentoPendente: false },
      });
    } else {
      await db.profile.update({
        where: { userId },
        data: { nivelamentoPendente: false },
      });
    }

    return {
      nivelamentoPendente: false,
      nivelamentoConcluido: profile.nivelamentoConcluido,
    };
  }

  private async upsertStudyPlan(userId: string, phase: AcademicPhase, dailyMins: number) {
    const durationDays = DURATION_BY_PHASE[phase];
    const goal = phase === 'oab_prep' ? 'oab_first' : 'graduation';

    const areas = [
      { code: 'CC',   name: 'Código Civil',     weight: 0.20 },
      { code: 'CF',   name: 'Constitucional',   weight: 0.20 },
      { code: 'CPC',  name: 'Processo Civil',   weight: 0.15 },
      { code: 'CP',   name: 'Penal',            weight: 0.15 },
      { code: 'CPP',  name: 'Processo Penal',   weight: 0.10 },
      { code: 'CLT',  name: 'Trabalhista',      weight: 0.10 },
      { code: 'CTN',  name: 'Tributário',       weight: 0.05 },
      { code: 'CDC',  name: 'Consumidor',       weight: 0.03 },
      { code: 'EOAB', name: 'Estatuto OAB',     weight: 0.02 },
    ];

    return db.studyPlan.upsert({
      where: { userId },
      update: { goal, durationDays, dailyMins, areas },
      create: { userId, goal, durationDays, dailyMins, areas },
    });
  }
}
