// KB estática com os 1.883 tópicos do Manual.
// Resolve queries do modo "direct" sem chamar LLM quando o tópico existe no banco.
//
// Pré-requisito: coluna content_tsv e índice GIN na tabela topics.
// Se ainda não existir, rodar back/prisma/migrations/apply_topics_fts.sql no Supabase.
import { db } from '../../../shared/db';

export interface KbResult {
  hit: true;
  topicId: string;
  topicTitle: string;
  subject: string;
  message: string;
}

export interface KbMiss {
  hit: false;
}

export type KbLookup = KbResult | KbMiss;

const LAW_CODE_TO_SUBJECT: Record<string, string> = {
  CC:   'Civil',
  CF:   'Constitucional',
  CP:   'Penal',
  CPC:  'Processual Civil',
  CPP:  'Processual Penal',
  CLT:  'Trabalhista',
  CTN:  'Tributário',
  CDC:  'Consumidor',
  EOAB: 'Ética OAB',
};

const STOP_WORDS = new Set([
  'o', 'a', 'os', 'as', 'um', 'uma', 'de', 'do', 'da', 'em', 'no',
  'na', 'e', 'que', 'se', 'para', 'por', 'com', 'me', 'te', 'eu',
]);

// Extrai tokens BM25 removendo acentos, stopwords e chars não-alfanuméricos.
function extractTokens(query: string): string {
  return query
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter((t) => t.length > 2 && !STOP_WORDS.has(t))
    .join(' & ');
}

export class KbService {
  /**
   * Tenta resolver a query via KB de tópicos do Manual.
   * Retorna KbResult se encontrar tópico com rank suficiente.
   * Retorna KbMiss se não encontrar, query muito curta, ou se content_tsv não existir.
   */
  async lookup(query: string): Promise<KbLookup> {
    const tokens = extractTokens(query);

    // Exige ao menos 2 tokens significativos para evitar falsos positivos
    if (!tokens || tokens.split(' & ').length < 2) {
      return { hit: false };
    }

    let rows: Array<{
      id: string;
      title: string;
      law_code: string;
      content: string;
      rank: number;
    }>;

    try {
      rows = await db.$queryRaw<Array<{
        id: string;
        title: string;
        law_code: string;
        content: string;
        rank: number;
      }>>`
        SELECT
          id,
          title,
          law_code,
          content,
          ts_rank(content_tsv, to_tsquery('portuguese_unaccent', ${tokens})) AS rank
        FROM topics
        WHERE
          content_tsv @@ to_tsquery('portuguese_unaccent', ${tokens})
          AND content IS NOT NULL
        ORDER BY rank DESC
        LIMIT 1
      `;
    } catch {
      // Coluna content_tsv ainda não criada — fallback silencioso para LLM
      return { hit: false };
    }

    const top = rows[0];

    // Threshold de relevância — ajustar com dados reais de produção
    if (!top || top.rank < 0.05 || !top.content) {
      return { hit: false };
    }

    const subject = LAW_CODE_TO_SUBJECT[top.law_code] ?? 'Direito';
    const message = this.formatResponse(top.title, subject, top.content);

    return {
      hit: true,
      topicId: top.id,
      topicTitle: top.title,
      subject,
      message,
    };
  }

  private formatResponse(title: string, subject: string, content: string): string {
    return [
      `**${title}** — ${subject}`,
      '',
      content,
      '',
      `📖 Leia o tópico completo no Manual para ver os artigos vinculados.`,
    ].join('\n');
  }
}
