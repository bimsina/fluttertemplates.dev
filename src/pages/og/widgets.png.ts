import type { APIRoute } from "astro";
import { generateOgImage } from "@/lib/og-image-generator";

export const GET: APIRoute = async () => {
  return generateOgImage({
    label: "Widgets",
    title: "Runnables snippets and production-ready Flutter components",
    titleFontSize: 52,
    titleLineHeight: 1.25,
  });
};
