import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { glob } from 'astro/loaders';

const categoriesCollection = defineCollection({
  loader: glob({ pattern: "*.json", base: "./src/content/categories" }),
  schema: z.object({
    title: z.string(),
    docs: z.array(
      z.object({
        title: z.string(),
        source: z.string(),
        slug: z.string(),
      })
    ),
  })
});

export const collections = {
  'categories': categoriesCollection,
};