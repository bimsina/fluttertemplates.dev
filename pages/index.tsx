import CustomContainedButton from "@/components/buttons/ContainedButton";
import BrowseWidgetsCTA from "@/components/homePageSections/BrowseWidgetsCTA";
import FeaturesSection from "@/components/homePageSections/FeaturesSection";
import HeroSection from "@/components/homePageSections/Hero";
import TemplatesGrid from "@/components/TemplatesGrid";
import HomePageHead from "@/head/SEOHead";
import TemplateCardProps from "@/models/template_card";
import getTemplatesList from "@/utils/getTemplatesList";
import { Button, Divider, Grid, Typography } from "@material-ui/core";
import { ArrowForwardIosRounded } from "@material-ui/icons";
import React from "react";

export default function Home({
  templates,
}: {
  templates: TemplateCardProps[];
}) {
  return (
    <div
      style={{
        margin: "1rem",
      }}
    >
      <HomePageHead />
      <HeroSection />
      <FeaturesSection />
      <BrowseWidgetsCTA />
    </div>
  );
}

interface TemplateSectionProps {
  title: string;
  subtitle: string;
  catId: string;
  templates: TemplateCardProps[];
}

function SingleTemplatesCategorySection(props: TemplateSectionProps) {
  return (
    <div>
      <Grid
        container
        direction="row"
        justifyContent="space-between"
        alignItems="center"
      >
        <Grid item xs={8}>
          <div>
            <Typography
              variant="h5"
              style={{
                fontWeight: "bold",
                marginTop: "1.1rem",
                marginBottom: "0.4rem",
                fontSize: "1.2rem",
              }}
            >
              {props.title}
            </Typography>

            <Typography
              variant="caption"
              style={{
                opacity: 0.7,
              }}
            >
              {props.subtitle}
            </Typography>
          </div>
        </Grid>

        <Grid item>
          <Button
            variant="outlined"
            href={`/templates?catId=${props.catId}`}
            style={{
              fontSize: "0.8rem",
            }}
          >
            Browse More
            <ArrowForwardIosRounded
              style={{
                fontSize: "0.7rem",
                marginBottom: "-0.075rem",
              }}
            />
          </Button>
        </Grid>
      </Grid>

      <Divider
        style={{
          marginTop: "0.8rem",
          marginBottom: "1.1rem",
          opacity: 0.3,
        }}
      />
      <TemplatesGrid
        templates={props.templates}
        limit={true}
        selectedCatId={props.catId}
        isFromHome={true}
      />
    </div>
  );
}

export async function getStaticProps() {
  const _data = getTemplatesList();
  return _data;
}
