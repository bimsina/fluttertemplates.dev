import React from "react";
import { Grid } from "@material-ui/core";

import { Typography } from "@material-ui/core";
import CustomButton from "../components/custom_button";

export default function PageNotFoundPage() {
  return (
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
        <Typography>Page Not Found</Typography>
      </Grid>
      <CustomButton href="/" variant="contained" color="primary">
        Go Home
      </CustomButton>
    </Grid>
  );
}
