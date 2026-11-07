import type { APIRoute } from "astro";
import { generateOgImage } from "@/lib/og-image-generator";

export const GET: APIRoute = async () => {
  return generateOgImage({
    label: "Widgets",
    title: "Runnable Flutter screens with source you can copy",
    titleFontSize: 52,
    titleLineHeight: 1.25,
  });
};
