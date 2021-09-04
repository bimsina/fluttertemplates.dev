import Head from "next/head";
import TemplateCard from "../components/TemplateCard";
import React from "react";
import { Typography, Grid } from "@material-ui/core";
import CustomButton from "../components/custom_button";
import TemplateCardProps from "../models/template_card";
import getTemplatesList from "../utils/getTemplatesList";
import TemplatesGrid from "../components/TemplatesGrid";
import HomePageHead from "../head/HomePageHead";

export default function Home({
  templates,
}: {
  templates: TemplateCardProps[];
}) {
  return (
    <div>
      <HomePageHead />

      <HeroSection />

      <div id="templates">
        <TemplatesGrid templates={templates} limit={true} />
      </div>
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
            <Typography>
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
              style={{
                fontSize: "1.1rem",
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
