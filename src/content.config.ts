import { glob } from "astro/loaders";
import { defineCollection, z } from "astro:content";
import { appFolder, previewSizeEnum, templateType } from "./types";

const blog = defineCollection({
  loader: glob({ base: "./src/content/blog", pattern: "**/*.{md,mdx}" }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    heroImage: z.string().optional(),
  }),
});

const templates = defineCollection({
  loader: glob({ base: "./src/content/templates", pattern: "**/*.{md,mdx}" }),
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      description: z.string().optional(),
      type: templateType.optional(),
      app: appFolder.default("core"),
      heroImage: image().optional(),
      githubUrl: z.string().optional(),
      demoUrl: z.string().optional(),
      tags: z.array(z.string()).optional(),
    }),
});

const widgets = defineCollection({
  loader: glob({ base: "./src/content/widgets", pattern: "**/*.{md,mdx}" }),
  schema: z.object({
    title: z.string(),
    description: z.string().optional(),
    app: appFolder.default("core"),
    path: z.string().optional(),
    icon: z.string().optional(),
    order: z.number().default(0),
    previewSize: previewSizeEnum.default("mobile"),
    code_files: z
      .array(z.string())
      .default(["main.dart"])
      .superRefine((val) => {
        val.forEach((v) => {
          if (v.startsWith("/")) {
            throw new Error("Code files can't start with '/'");
          }
          if (v.endsWith("/")) {
            throw new Error("Code files can't end with '/'");
          }
          if (v.includes("..")) {
            throw new Error("Code files can't contain '..'");
          }
          if (v.includes("//")) {
            throw new Error("Code files can't contain '//'");
          }
          if (v.includes("/*")) {
            throw new Error("Code files can't contain '/*'");
          }
          if (v.includes("*/")) {
            throw new Error("Code files can't contain '*/'");
          }
          if (v.includes("*")) {
            throw new Error("Code files can't contain '*'");
          }
        });
      }),
  }),
});

export const collections = { blog, widgets, templates };
