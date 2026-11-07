import type { APIRoute } from "astro";
import { generateOgImage } from "@/lib/og-image-generator";

export const GET: APIRoute = async () => {
  return generateOgImage({
    label: "Flutter Templates",
    title: "Flutter UI templates and widgets with live previews",
    titleFontSize: 54,
    titleLineHeight: 1.25,
  });
};
