import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { glob } from 'astro/loaders';

const docSchema = z.object({
  title: z.string(),
  source: z.string().optional(),
  pdf: z.string().optional(),
  slug: z.string(),
}).refine((doc) => doc.source || doc.pdf, {
  message: 'Each doc must define either a source Typst file or a standalone pdf path.',
  path: ['source'],
});

const categoriesCollection = defineCollection({
  loader: glob({ pattern: "*.json", base: "./src/content/categories" }),
  schema: z.object({
    title: z.string(),
    docs: z.array(docSchema),
  })
});

export const collections = {
  'categories': categoriesCollection,
};