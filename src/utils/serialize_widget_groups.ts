import type { WidgetSidebarGroup } from "@/components/WidgetsSidebar";
import type { CollectionEntry } from "astro:content";

interface WidgetGroup {
  title: string;
  path: string;
  items: CollectionEntry<"widgets">[];
  indexFile: CollectionEntry<"widgets"> | null;
  order: number;
  children?: WidgetGroup[];
}

export function serializeWidgetGroupsForSidebar(
  groups: WidgetGroup[],
): WidgetSidebarGroup[] {
  return groups.map((group) => {
    const id = group.indexFile?.id ?? group.path;
    const title = group.indexFile?.data?.title ?? group.title;
    const icon = group.indexFile?.data?.icon;

    const items = group.items
      .filter((item) => !item.filePath?.endsWith("index.md"))
      .map((item) => ({
        id: item.id,
        title: item.data.title,
        icon: item.data.icon,
      }));

    const children = group.children?.length
      ? serializeWidgetGroupsForSidebar(group.children)
      : undefined;

    return {
      id,
      title,
      icon,
      items,
      children,
    };
  });
}
