import Anthropic from '@anthropic-ai/sdk';
import { db } from '../../shared/db';

const STALENESS_DAYS = 7;
const MIN_ERRORS_FOR_ANALYSIS = 5;
const ANALYSIS_WINDOW_DAYS = 60;
const MAX_TOPICS_PAYLOAD = 30;

type WeakTopicEntry = { id: string; title: string; priority: number };
type WeakTopicsMap = Record<string, WeakTopicEntry[]>;

const SYSTEM_PROMPT = `Você é o coach de estudos do LCF, plataforma de preparação para o Exame da OAB.
Analise os erros recentes do estudante e identifique os tópicos que mais precisam de revisão, agrupados por matéria.
Critérios de priorização: (1) frequência de erros, (2) dificuldade das questões erradas, (3) relevância para a 1ª fase da OAB.
Retorne APENAS um JSON válido, sem texto fora do JSON. Formato obrigatório:
{ "bySubject": { "<matéria>": [{ "id": "<topicId>", "title": "<título>", "priority": <1|2|3> }] } }
Máximo 3 tópicos por matéria, ordenados do mais ao menos prioritário. Priority 1 = mais urgente.`;

export async function runProfileAnalysis(userId: string): Promise<void> {
  const studyPlan = await db.studyPlan.findUnique({
    where: { userId },
    select: { analyzedAt: true },
  });
  if (!studyPlan) return;

  if (studyPlan.analyzedAt) {
    const daysSince = (Date.now() - studyPlan.analyzedAt.getTime()) / (1000 * 60 * 60 * 24);
    if (daysSince < STALENESS_DAYS) return;
  }

  const since = new Date(Date.now() - ANALYSIS_WINDOW_DAYS * 24 * 60 * 60 * 1000);

  const rows = await db.simuladoQuestion.findMany({
    where: {
      attempt: { userId },
      answeredAt: { gte: since },
      isCorrect: false,
      studentAnswer: { not: null },
    },
    include: {
      question: { select: { subject: true, topicId: true, difficulty: true } },
    },
  });

  const rowsWithTopic = rows.filter(r => r.question.topicId);
  if (rowsWithTopic.length < MIN_ERRORS_FOR_ANALYSIS) return;

  const agg = new Map<string, {
    topicId: string;
    subject: string;
    errorCount: number;
    difficulties: Record<string, number>;
  }>();

  for (const row of rowsWithTopic) {
    const topicId = row.question.topicId!;
    const existing = agg.get(topicId) ?? {
      topicId,
      subject: row.question.subject,
      errorCount: 0,
      difficulties: {},
    };
    existing.errorCount += 1;
    const diff = row.question.difficulty ?? 'medium';
    existing.difficulties[diff] = (existing.difficulties[diff] ?? 0) + 1;
    agg.set(topicId, existing);
  }

  const topicIds = Array.from(agg.keys());
  const topics = await db.topic.findMany({
    where: { id: { in: topicIds } },
    select: { id: true, title: true },
  });
  const titleMap = new Map(topics.map(t => [t.id, t.title]));

  const payload = Array.from(agg.values())
    .filter(a => titleMap.has(a.topicId))
    .sort((a, b) => b.errorCount - a.errorCount)
    .slice(0, MAX_TOPICS_PAYLOAD)
    .map(a => ({
      topicId: a.topicId,
      title: titleMap.get(a.topicId)!,
      subject: a.subject,
      errorCount: a.errorCount,
      dominantDifficulty: Object.entries(a.difficulties).sort((x, y) => y[1] - x[1])[0]?.[0] ?? 'medium',
    }));

  if (payload.length === 0) return;

  const client = new Anthropic();
  const userContent = `Erros recentes do estudante (últimos ${ANALYSIS_WINDOW_DAYS} dias):\n${JSON.stringify(payload)}`;

  let weakTopics: WeakTopicsMap;
  try {
    const response = await client.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 1024,
      system: SYSTEM_PROMPT,
      messages: [{ role: 'user', content: userContent }],
    });

    const text = response.content[0].type === 'text' ? response.content[0].text.trim() : '';
    const parsed = JSON.parse(text) as { bySubject: WeakTopicsMap };
    if (!parsed.bySubject || typeof parsed.bySubject !== 'object') return;
    weakTopics = parsed.bySubject;
  } catch {
    return;
  }

  await db.studyPlan.update({
    where: { userId },
    data: {
      weakTopics: weakTopics as object,
      analyzedAt: new Date(),
    },
  });
}
