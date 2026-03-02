import type { WidgetGroupType } from "@/types";
import { getGroupedWidgets } from "./get_grouped_widgets";

export interface PageEntry {
  type: "category" | "widget";
  id: string;
  title: string;
  url: string;
}

function flattenPages(groups: WidgetGroupType[]): PageEntry[] {
  const entries: PageEntry[] = [];

  function traverse(group: WidgetGroupType) {
    if (group.indexFile) {
      entries.push({
        type: "category",
        id: group.indexFile.id,
        title: group.indexFile.data.title,
        url: `/widgets/${group.indexFile.id}`,
      });
    }

    for (const item of group.items) {
      if (item.filePath?.endsWith("index.md")) continue;
      entries.push({
        type: "widget",
        id: item.id,
        title: item.data.title,
        url: `/widgets/${item.id}`,
      });
    }

    if (group.children) {
      for (const child of group.children) {
        traverse(child);
      }
    }
  }

  for (const group of groups) {
    traverse(group);
  }

  return entries;
}

let cachedSequence: PageEntry[] | null = null;

export async function getWidgetPageSequence(): Promise<PageEntry[]> {
  if (cachedSequence) return cachedSequence;
  const groups = await getGroupedWidgets();
  cachedSequence = flattenPages(groups);
  return cachedSequence;
}

export async function getPrevNext(
  currentId: string,
): Promise<{ prev?: PageEntry; next?: PageEntry }> {
  const sequence = await getWidgetPageSequence();
  const index = sequence.findIndex((entry) => entry.id === currentId);
  if (index < 0) return {};

  return {
    prev: index > 0 ? sequence[index - 1] : undefined,
    next: index < sequence.length - 1 ? sequence[index + 1] : undefined,
  };
}
