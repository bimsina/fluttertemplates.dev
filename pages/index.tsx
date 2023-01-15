import Footer from "@/components/footer/Footer";
import BrowseComponentsCTA from "@/components/homePageSections/BrowseComponentsCTA";
import FeaturesSection from "@/components/homePageSections/FeaturesSection";
import HeroSection from "@/components/homePageSections/Hero";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";
import HomePageHead from "@/head/SEOHead";

import React from "react";

export default function Home() {
  return (
    <>
      <HomePageHead />
      <div className="inline-flex justify-center items-center w-full">
        <div className="max-w-6xl">
          <HeroSection />

          <FeaturesSection />
          <BrowseComponentsCTA />
          <SubmitProposalSection />
          <Footer />
        </div>
      </div>
    </>
  );
}
