import Header from "@/components/header/Header";
import Footer from "@/components/footer/Footer";
import { Analytics } from "@vercel/analytics/react";

import "@/styles/globals.css";

import type { AppProps } from "next/app";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";
import { ThemeProvider } from "next-themes";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <ThemeProvider attribute="class">
        <Header />
        <div className="min-h-screen pt-20 scroll-smooth">
          <Component {...pageProps} />
        </div>
      </ThemeProvider>
      <Analytics />
    </>
  );
}
export default MyApp;
