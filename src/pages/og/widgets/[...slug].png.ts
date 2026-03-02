import type { APIRoute } from "astro";
import { getCollection } from "astro:content";
import { generateOgImage } from "@/lib/og-image-generator";

export async function getStaticPaths() {
  const widgets = await getCollection("widgets");

  return widgets.map((widget) => ({
    params: { slug: widget.id },
    props: {
      title: widget.data.title,
      isGroup: widget.filePath?.endsWith("index.md") ?? false,
    },
  }));
}

export const GET: APIRoute = async ({ props }) => {
  return generateOgImage({
    label: props.isGroup ? "Widget Group" : "Widget",
    title: props.title,
    titleFontSize: 58,
    titleLineHeight: 1.2,
  });
};
