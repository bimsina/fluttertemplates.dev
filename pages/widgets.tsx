import React from "react";
import { Grid } from "@material-ui/core";

import { Typography } from "@material-ui/core";
import CustomContainedButton from "@/components/buttons/ContainedButton";
import HomePageHead from "@/head/SEOHead";
import { HomeRounded } from "@material-ui/icons";

export default function ComponentsPage() {
  return (
    <>
      <HomePageHead title="Browse production ready Flutter UI Components" />
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
            style={{
              height: "30vh",
            }}
          />
        </Grid>
        <Grid item>
          <Typography>Coming soon</Typography>
        </Grid>
        <CustomContainedButton href="/" label="Go Home" />
      </Grid>
    </>
  );
}
