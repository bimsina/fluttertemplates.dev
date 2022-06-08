import Header from "@/components/header/Header";
import Footer from "@/components/footer/Footer";

import "@/styles/globals.css";

import type { AppProps } from "next/app";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Header />
      <div className="min-h-screen pt-20">
        <Component {...pageProps} />
      </div>

      <SubmitProposalSection />

      <Footer />
    </>
  );
}
export default MyApp;
