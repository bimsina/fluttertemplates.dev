// @ts-check
import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";
import pagefind from "astro-pagefind";
import icon from "astro-icon";
import swup from "@swup/astro";
import react from "@astrojs/react";

export default defineConfig({
  site: "https://fluttertemplates.dev",
  prefetch: {
    prefetchAll: true,
    defaultStrategy: "hover",
  },
  integrations: [
    mdx(),
    sitemap(),
    icon(),
    react(),
    pagefind(),
    swup({
      theme: false,
      animationClass: "transition-",
      native: true,
      preload: {
        hover: true,
        visible: true,
      },
      containers: ["main"],
      fragments: [
        {
          from: "/widgets/:slug*",
          to: "/widgets/:slug*",
          containers: ["#widgets-content"],
        },
      ],
    }),
  ],
  vite: {
    plugins: [tailwindcss()],
  },
});
