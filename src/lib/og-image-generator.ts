import { readFile } from "node:fs/promises";
import { createElement as h } from "react";
import satori from "satori";
import sharp from "sharp";

interface OgImageOptions {
  label?: string;
  title: string;
  titleFontSize?: number;
  titleLineHeight?: number;
}

let fontBold: Buffer | null = null;
let fontRegular: Buffer | null = null;

async function loadFonts() {
  if (!fontBold || !fontRegular) {
    fontBold = await readFile(
      "./node_modules/@fontsource/inter/files/inter-latin-600-normal.woff",
    );
    fontRegular = await readFile(
      "./node_modules/@fontsource/inter/files/inter-latin-400-normal.woff",
    );
  }

  return { fontBold, fontRegular };
}

function createOgElement({
  label,
  title,
  titleFontSize = 62,
  titleLineHeight = 1.2,
}: OgImageOptions) {
  return h(
    "div",
    {
      style: {
        height: "100%",
        width: "100%",
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#f8fbff",
        position: "relative",
      },
    },
    h("div", {
      style: {
        position: "absolute",
        inset: "36px",
        borderRadius: "28px",
        border: "1px solid #d8e5f2",
        backgroundColor: "rgba(255,255,255,0.82)",
      },
    }),
    h("div", {
      style: {
        position: "absolute",
        inset: "36px",
        borderRadius: "28px",
        border: "1px solid rgba(255,255,255,0.7)",
      },
    }),
    h(
      "div",
      {
        style: {
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          textAlign: "center",
          maxWidth: "920px",
          paddingLeft: "40px",
          paddingRight: "40px",
        },
      },
      h(
        "div",
        {
          style: {
            fontSize: 20,
            color: "#0369a1",
            marginBottom: 22,
            fontWeight: 600,
            fontFamily: "Inter",
            textTransform: "uppercase",
            letterSpacing: "0.14em",
            backgroundColor: "#e0f2fe",
            border: "1px solid #bae6fd",
            padding: "8px 14px",
            borderRadius: "9999px",
          },
        },
        label,
      ),
      h(
        "div",
        {
          style: {
            fontSize: titleFontSize,
            fontWeight: 600,
            color: "#1e293b",
            lineHeight: titleLineHeight,
            fontFamily: "Inter",
            letterSpacing: "-0.02em",
          },
        },
        title,
      ),
    ),
    h(
      "div",
      {
        style: {
          position: "absolute",
          bottom: "68px",
          fontSize: 18,
          color: "#475569",
          fontFamily: "Inter",
          fontWeight: 500,
          letterSpacing: "0.02em",
        },
      },
      "fluttertemplates.dev",
    ),
  );
}

async function generateSvg(options: OgImageOptions): Promise<string> {
  const { fontBold, fontRegular } = await loadFonts();
  const element = createOgElement(options);

  return satori(element, {
    width: 1200,
    height: 630,
    fonts: [
      {
        name: "Inter",
        data: fontBold,
        weight: 600,
        style: "normal",
      },
      {
        name: "Inter",
        data: fontRegular,
        weight: 400,
        style: "normal",
      },
    ],
  });
}

export async function generateOgImage(
  options: OgImageOptions,
): Promise<Response> {
  const svg = await generateSvg(options);
  const png = await sharp(Buffer.from(svg)).png().toBuffer();

  return new Response(new Uint8Array(png), {
    headers: {
      "Content-Type": "image/png",
      "Cache-Control": "public, max-age=31536000, immutable",
    },
  });
}
