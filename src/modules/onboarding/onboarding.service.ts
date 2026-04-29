import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

// T03 — Objetivo
type StudyGoal = 'oab_first' | 'oab_second' | 'both';
// T04 — Nível de conhecimento
type KnowledgeLevel = 'beginner' | 'intermediate' | 'advanced';

export class OnboardingService {
  async getState(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    return {
      step: profile.onboardingStep,
      done: profile.onboardingDone,
      data: {
        studyGoal: profile.studyGoal,
        knowledgeLevel: profile.knowledgeLevel,
        dailyStudyMins: profile.dailyStudyMins,
      },
    };
  }

  async updateStep(userId: string, step: number, data: Record<string, unknown>) {
    const updateData: Record<string, unknown> = { onboardingStep: step };

    if (step === 1) updateData.studyGoal = data.studyGoal as StudyGoal;
    if (step === 2) updateData.knowledgeLevel = data.knowledgeLevel as KnowledgeLevel;
    if (step === 3) updateData.dailyStudyMins = data.dailyStudyMins as number;

    const profile = await db.profile.update({
      where: { userId },
      data: updateData,
    });

    return { step: profile.onboardingStep };
  }

  async complete(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    await db.profile.update({
      where: { userId },
      data: { onboardingDone: true, onboardingStep: 4 },
    });

    // Gera plano de estudos baseado no perfil (T19)
    const plan = await this.generateStudyPlan(userId, profile);
    return { done: true, studyPlan: plan };
  }

  private async generateStudyPlan(
    userId: string,
    profile: { studyGoal: string | null; dailyStudyMins: number | null },
  ) {
    const goal = (profile.studyGoal as StudyGoal) ?? 'oab_first';
    const dailyMins = profile.dailyStudyMins ?? 60;

    // Áreas OAB com pesos padrão
    const areas = [
      { code: 'CC', name: 'Código Civil', weight: 0.20 },
      { code: 'CF', name: 'Constitucional', weight: 0.20 },
      { code: 'CPC', name: 'Processo Civil', weight: 0.15 },
      { code: 'CP', name: 'Penal', weight: 0.15 },
      { code: 'CPP', name: 'Processo Penal', weight: 0.10 },
      { code: 'CLT', name: 'Trabalhista', weight: 0.10 },
      { code: 'CTN', name: 'Tributário', weight: 0.05 },
      { code: 'CDC', name: 'Consumidor', weight: 0.03 },
      { code: 'EOAB', name: 'Estatuto OAB', weight: 0.02 },
    ];

    const durationDays = goal === 'oab_first' ? 90 : 120;

    return db.studyPlan.upsert({
      where: { userId },
      update: { goal, durationDays, dailyMins, areas },
      create: { userId, goal, durationDays, dailyMins, areas },
    });
  }
}
