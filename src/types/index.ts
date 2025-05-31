import { z, type CollectionEntry } from "astro:content";

export type WidgetEntry = CollectionEntry<"widgets">;

export interface WidgetItem {
  id: string;
  data: {
    title: string;
    description: string;
  };
}

export interface WidgetGroupType {
  title: string;
  path: string;
  items: WidgetEntry[];
  indexFile: WidgetEntry | null;
  children?: WidgetGroupType[];
}

export const templateType = z.enum([
  "micro-interaction",
  "full-app",
  "ui-kit",
  "single-page",
  "clone",
]);

export const appFolder = z.enum(["core"]);
