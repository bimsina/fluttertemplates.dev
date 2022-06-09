import Header from "@/components/header/Header";
import Footer from "@/components/footer/Footer";

import "@/styles/globals.css";

import type { AppProps } from "next/app";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";
import { ThemeProvider } from "next-themes";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <ThemeProvider attribute="class">
      <Header />
      <div className="min-h-screen pt-20">
        <Component {...pageProps} />
      </div>

      <SubmitProposalSection />

      <Footer />
    </ThemeProvider>
  );
}
export default MyApp;
