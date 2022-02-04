import React from "react";
import { Grid } from "@material-ui/core";

import { Typography } from "@material-ui/core";
import CustomContainedButton from "@/components/buttons/ContainedButton";
import HomePageHead from "@/head/SEOHead";
import { HomeRounded } from "@material-ui/icons";

export default function PageNotFoundPage() {
  return (
    <>
      <HomePageHead title="404 : Cant find the page you're looking for." />
      <Grid
        container
        direction="column"
        justifyContent="center"
        alignItems="center"
        spacing={4}
        style={{
          height: "80vh",
          width: "100%",
        }}
      >
        <Grid item>
          <img
            src="/404.svg"
            alt="404 : Cant find the page you're looking for."
            style={{
              height: "30vh",
            }}
          />
        </Grid>
        <Grid item>
          <Typography>Page Not Found</Typography>
        </Grid>
        <CustomContainedButton href="/" label="Go Home" />
      </Grid>
    </>
  );
}
