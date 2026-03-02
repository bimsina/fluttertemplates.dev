import type { APIRoute } from "astro";
import { generateOgImage } from "@/lib/og-image-generator";

export const GET: APIRoute = async () => {
  return generateOgImage({
    label: "Templates",
    title: "Full Flutter app templates for fast shipping",
    titleFontSize: 56,
    titleLineHeight: 1.2,
  });
};
