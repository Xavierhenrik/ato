import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

// Spec v5.0 — Passo 1/4: Fase acadêmica
type AcademicPhase = 'graduation_start' | 'graduation_mid' | 'oab_prep';

export class OnboardingService {
  async getState(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    return {
      step: profile.onboardingStep,
      done: profile.onboardingDone,
      data: {
        academicPhase: profile.academicPhase,
        dailyStudyMins: profile.dailyStudyMins,
        selectedSubjects: profile.selectedSubjects,
        nivelamentoPendente: profile.nivelamentoPendente,
      },
    };
  }

  async updateStep(userId: string, step: number, data: Record<string, unknown>) {
    const updateData: Record<string, unknown> = { onboardingStep: step };

    // Passo 1 → fase acadêmica
    if (step === 1) updateData.academicPhase = data.academicPhase as AcademicPhase;
    // Passo 2 → meta de minutos diários
    if (step === 2) updateData.dailyStudyMins = data.dailyStudyMins as number;
    // Passo 3 → disciplinas selecionadas (array de códigos)
    if (step === 3) updateData.selectedSubjects = data.selectedSubjects;

    const profile = await db.profile.update({
      where: { userId },
      data: updateData,
    });

    return { step: profile.onboardingStep };
  }

  async complete(userId: string) {
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');

    const isOabPrep = profile.academicPhase === 'oab_prep';

    await db.profile.update({
      where: { userId },
      data: {
        onboardingDone: true,
        onboardingStep: 4,
        // Se fase OAB, quiz diagnóstico fica pendente (RF14, T08-T09)
        ...(isOabPrep && { nivelamentoPendente: true }),
      },
    });

    // Gera plano de estudos baseado no perfil (T19)
    const plan = await this.generateStudyPlan(userId, profile);

    // Fork de roteamento: Fluxo A → Home direto; Fluxo B (OAB) → Quiz Diagnóstico
    return {
      done: true,
      studyPlan: plan,
      flow: isOabPrep ? 'B' : 'A',
      nivelamentoPendente: isOabPrep,
    };
  }

  // T08 — Usuário concluiu o Quiz Diagnóstico OAB (RF14)
  async completeQuiz(userId: string) {
    await db.profile.update({
      where: { userId },
      data: { nivelamentoPendente: false },
    });
    return { nivelamentoPendente: false };
  }

  // T09 — Usuário confirmou o skip do Quiz Diagnóstico (RF14)
  async skipQuiz(userId: string) {
    // nivelamentoPendente já é true após complete() para OAB — apenas confirma e retorna estado
    const profile = await db.profile.findUnique({ where: { userId } });
    if (!profile) throw Errors.notFound('Perfil');
    // Garante que está marcado como pendente mesmo que chamado diretamente
    if (!profile.nivelamentoPendente) {
      await db.profile.update({
        where: { userId },
        data: { nivelamentoPendente: true },
      });
    }
    return { nivelamentoPendente: true };
  }

  private async generateStudyPlan(
    userId: string,
    profile: { academicPhase: string | null; dailyStudyMins: number | null },
  ) {
    const phase = profile.academicPhase as AcademicPhase | null;
    const goal = 'oab_first';
    const durationDays =
      phase === 'oab_prep' ? 90 : phase === 'graduation_mid' ? 120 : 180;
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

    return db.studyPlan.upsert({
      where: { userId },
      update: { goal, durationDays, dailyMins, areas },
      create: { userId, goal, durationDays, dailyMins, areas },
    });
  }
}
