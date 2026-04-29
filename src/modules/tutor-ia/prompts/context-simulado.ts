export interface QuestionBundle {
  statement: string;
  options: { A: string; B: string; C: string; D: string };
  correct_answer: string;
  student_answer: string;
  subject: string;
  board: string;
  year: number;
}

export function buildSimuladoContext(bundle: QuestionBundle): string {
  const opts = Object.entries(bundle.options)
    .map(([k, v]) => `${k}) ${v}`)
    .join('\n');

  return `O aluno errou a seguinte questão:

ENUNCIADO: ${bundle.statement}

ALTERNATIVAS:
${opts}

GABARITO: ${bundle.correct_answer}) ${bundle.options[bundle.correct_answer as keyof typeof bundle.options]}
RESPOSTA DO ALUNO: ${bundle.student_answer}) ${bundle.options[bundle.student_answer as keyof typeof bundle.options]}

MATÉRIA: ${bundle.subject} | BANCA: ${bundle.board} | ANO: ${bundle.year}

Explique por que a resposta correta está certa e a do aluno está errada.
Use lookup_article para fundamentar com o texto legal exato.`;
}
