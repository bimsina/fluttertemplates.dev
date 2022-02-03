import { Card, Container, Grid, Typography, useTheme } from "@material-ui/core";
import { ArrowForward } from "@material-ui/icons";
import React from "react";
import CustomContainedButton from "../buttons/ContainedButton";

export default function BrowseWidgetsCTA() {
  const theme = useTheme();

  return (
    <div
      style={{
        backgroundColor: `${theme.palette.secondary.main}20`,
        marginTop: "10rem",
        marginBottom: "10rem",
        padding: "2rem",
        borderRadius: "0.5rem",
      }}
    >
      <Grid
        container
        direction="row"
        justifyContent="center"
        alignItems="center"
        spacing={4}
      >
        <Grid item xs={12} md={6}>
          <Typography
            variant="h2"
            style={{
              fontSize: "1.8rem",
              fontWeight: "bold",
            }}
          >
            Explore production ready Flutter Widgets and Templates
          </Typography>
        </Grid>

        <Grid
          item
          xs={12}
          md={6}
          style={{
            display: "flex",
            justifyContent: "center",
          }}
        >
          <CustomContainedButton
            label="Browse Widgets"
            href="/widgets"
            icon={<ArrowForward fontSize="small" />}
          />
        </Grid>
      </Grid>
    </div>
  );
}
