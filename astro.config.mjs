// @ts-check
import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";
import pagefind from "astro-pagefind";
import icon from "astro-icon";

import react from "@astrojs/react";

// https://astro.build/config
export default defineConfig({
  build: {
    format: "file",
  },
  site: "https://fluttertemplates.dev",
  integrations: [mdx(), sitemap(), icon(), react(), pagefind()],

  vite: {
    plugins: [tailwindcss()],
  },
});
