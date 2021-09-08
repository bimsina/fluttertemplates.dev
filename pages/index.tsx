import React from "react";
import { Typography, Grid, Divider, IconButton, Card } from "@material-ui/core";
import CustomButton from "@/components/custom_button";
import TemplateCardProps from "@/models/template_card";
import getTemplatesList from "@/utils/getTemplatesList";
import TemplatesGrid from "@/components/TemplatesGrid";
import HomePageHead from "@/head/HomePageHead";
import {
  ArrowDownward,
  ArrowForwardIosRounded,
  Code,
} from "@material-ui/icons";
import FeaturesSection from "@/components/FeaturesSection";

export default function Home({
  templates,
}: {
  templates: TemplateCardProps[];
}) {
  return (
    <div>
      <HomePageHead />

      <HeroSection />

      <FeaturesSection />

      <div id="templates">
        <SingleTemplatesCategorySection
          title="Full Apps"
          subtitle="Complete App UIs to kickstart you app development process."
          catId="full-app"
          templates={templates}
        />
        <SingleTemplatesCategorySection
          title="Micro Interactions"
          subtitle="Small interaction examples that make your app stand out among the croud."
          catId="micro-interaction"
          templates={templates}
        />
      </div>

      <Grid
        container
        direction="row"
        justifyContent="center"
        alignItems="center"
        style={{
          marginBottom: "2rem",
        }}
      >
        <Grid item>
          <CustomButton
            variant="contained"
            color="primary"
            href="/templates"
            aria-label="Browse Templates"
          >
            Browse All Templates
          </CustomButton>
        </Grid>
      </Grid>
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
          <CustomButton
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
          </CustomButton>
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

function HeroSection() {
  return (
    <Grid
      container
      justifyContent="center"
      alignItems="center"
      style={{
        width: "100%",
      }}
    >
      <Grid item md={6}>
        <Grid
          container
          direction="column"
          justifyContent="center"
          alignItems="flex-start"
          spacing={4}
          style={{
            padding: "2rem",
          }}
        >
          <Grid>
            <Typography
              variant="h1"
              style={{
                fontWeight: "bold",
                fontSize: "2.5rem",
              }}
            >
              Flutter UI Templates
            </Typography>
          </Grid>

          <Grid
            style={{
              marginTop: "2rem",
              marginBottom: "2rem",
            }}
          >
            <Typography
              variant="h2"
              style={{
                fontSize: "16px",
                lineHeight: "1.4",
              }}
            >
              Don’t you hate it when you pay hundreds of dollars for a flutter
              template which has limited functionalities? Don’t worry, we got
              your back. Here you will find a collection of mobile application
              UI templates for Android, iOS and Web, built using Google’s
              Flutter Mobile App SDK. All you need to do is copy-paste our code
              into your flutter app. Easy right?
            </Typography>
          </Grid>

          <Grid>
            <CustomButton
              variant="contained"
              color="primary"
              href="#templates"
              disableElevation
              aria-label="Lets start"
              style={{
                fontSize: "1rem",
              }}
            >
              Let’s get started!
            </CustomButton>
          </Grid>
        </Grid>
      </Grid>

      <Grid item md={6}>
        <img
          src="/home_hero.svg"
          alt="hero"
          style={{
            width: "100%",
            height: "85vh",
            objectFit: "scale-down",
          }}
        />
      </Grid>
    </Grid>
  );
}

export async function getStaticProps() {
  const _data = getTemplatesList();
  return _data;
}
