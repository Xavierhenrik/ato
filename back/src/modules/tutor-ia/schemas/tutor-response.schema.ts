import { z } from 'zod';

export const CitationSchema = z.object({
  full_reference: z.string(),
  content: z.string(),
  law_name: z.string(),
  certainty: z.enum(['verified', 'not_found']),
  manual_topic_id: z.string().optional(),
});

export const TutorResponseSchema = z.object({
  message: z.string(),
  sources: z.array(CitationSchema),
  confidence: z.enum(['high', 'medium', 'low']),
  disclaimer: z.string().optional(),
  mode: z.enum(['reading', 'simulado', 'direct']),
});

export type Citation = z.infer<typeof CitationSchema>;
export type TutorResponse = z.infer<typeof TutorResponseSchema>;
