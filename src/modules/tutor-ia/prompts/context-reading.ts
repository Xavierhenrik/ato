export function buildReadingContext(topicTitle: string, topicContent: string): string {
  return `O aluno está lendo o seguinte tópico do Manual:

TÍTULO: ${topicTitle}

CONTEÚDO:
${topicContent}

Priorize este conteúdo nas suas respostas. Use lookup_article para verificar qualquer artigo citado neste tópico antes de discuti-lo.`;
}
