export class AppError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: string,
    message: string,
    public readonly extra?: Record<string, unknown>,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export const Errors = {
  unauthorized: () => new AppError(401, 'UNAUTHORIZED', 'Token inválido ou expirado'),
  forbidden: () => new AppError(403, 'FORBIDDEN', 'Acesso negado'),
  notFound: (resource: string) => new AppError(404, 'NOT_FOUND', `${resource} não encontrado`),
  conflict: (msg: string) => new AppError(409, 'CONFLICT', msg),
  badRequest: (msg: string) => new AppError(400, 'BAD_REQUEST', msg),
  rateLimited: (plan: string) =>
    new AppError(
      429,
      'RATE_LIMITED',
      plan === 'free'
        ? 'Limite de 20 mensagens/dia atingido. Assine o PRO para 200 mensagens.'
        : 'Limite de 200 mensagens/dia atingido.',
    ),
  proRequired: () => new AppError(403, 'PRO_REQUIRED', 'Esta funcionalidade requer o plano PRO'),
  simuladoInProgress: (inProgressId: string) =>
    new AppError(409, 'SIMULADO_IN_PROGRESS', 'Você já tem um simulado em andamento', {
      inProgressId,
    }),
  simuladoDailyLimit: () =>
    new AppError(
      429,
      'SIMULADO_DAILY_LIMIT',
      'Limite de 15 questões/dia atingido no plano Free. Assine o PRO para questões ilimitadas.',
    ),
};
