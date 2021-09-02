import React from "react";
import { Grid } from "@material-ui/core";
import HeroImage from "../../assets/home_hero.svg";
import { Typography } from "@material-ui/core";

import CustomButton from "../../components/custom_button";
import TemplatesList from "./TemplatesList";

export default function HomePage() {
  return (
    <div>
      <HeroSection />
      <TemplatesList />
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
        // height: "90vh",
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
              variant="h4"
              style={{
                fontWeight: "bold",
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
              Don't you hate it when you pay hundreds of dollars for a flutter
              template which has limited functionalities? Don't worry, we got
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
              href="/detail/1234"
              disableElevation
              style={{
                fontSize: "1.1rem",
              }}
            >
              Lets get started!
            </CustomButton>
          </Grid>
        </Grid>
      </Grid>

      <Grid item md={6}>
        <img
          src={HeroImage}
          style={{
            width: "100%",
            maxHeight: "85vh",
            objectFit: "scale-down",
          }}
        />
      </Grid>
    </Grid>
  );
}
