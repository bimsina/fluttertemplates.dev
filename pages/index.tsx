import BrowseComponentsCTA from "@/components/homePageSections/BrowseComponentsCTA";
import FeaturesSection from "@/components/homePageSections/FeaturesSection";
import HeroSection from "@/components/homePageSections/Hero";
import HomePageHead from "@/head/SEOHead";

import { Container } from "@material-ui/core";
import React from "react";

export default function Home() {
  return (
    <Container maxWidth="lg">
      <HomePageHead />
      <HeroSection />
      <FeaturesSection />
      <BrowseComponentsCTA />
    </Container>
  );
}
