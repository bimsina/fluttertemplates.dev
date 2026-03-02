import type { APIRoute } from "astro";
import { getCollection } from "astro:content";
import { generateOgImage } from "@/lib/og-image-generator";

export async function getStaticPaths() {
  const templates = await getCollection("templates");

  return templates.map((template) => ({
    params: { slug: template.id },
    props: {
      title: template.data.title,
    },
  }));
}

export const GET: APIRoute = async ({ props }) => {
  return generateOgImage({
    label: "Template",
    title: props.title,
    titleFontSize: 58,
    titleLineHeight: 1.2,
  });
};
