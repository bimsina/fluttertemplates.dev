import { getCollection } from "astro:content";
import { getGroupedWidgets } from "./get_grouped_widgets";

export async function getWidgetStats() {
  const widgets = await getCollection("widgets");
  const widgetCount = widgets.filter(
    (w) => !w.filePath?.endsWith("/index.md"),
  ).length;

  const groups = await getGroupedWidgets();
  const categoryCount = groups.length;

  return { widgetCount, categoryCount };
}
