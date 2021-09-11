import { Card, Grid, Typography } from "@material-ui/core";
import { BrushRounded, Code, VisibilityRounded } from "@material-ui/icons";
import React from "react";

export default function FeaturesSection() {
  return (
    <Grid
      container
      direction="column"
      justifyContent="center"
      alignItems="center"
      style={{
        marginTop: "2rem",
        marginBottom: "2rem",
        minHeight: "50vh",
      }}
    >
      <Grid item>
        <Typography
          variant="h2"
          style={{
            fontWeight: "bold",
            fontSize: "1.7rem",
            width: "100%",
          }}
        >
          Features
        </Typography>
      </Grid>

      <Grid item>
        <div
          style={{
            width: "80px",
            background: "#c4d33a",
            height: "4px",
            marginTop: "0.5rem",
            marginBottom: "2.5rem",
            borderRadius: "4px",
          }}
        ></div>
      </Grid>
      <Grid
        item
        style={{
          width: "100%",
        }}
      >
        <Grid
          container
          direction="row"
          alignItems="center"
          justifyContent="space-evenly"
          spacing={4}
        >
          <SingleFeature
            title="Completely Null Safe"
            description="All the templates are built with pre configured null safety."
            icon={
              <Code
                style={{
                  fontSize: "4rem",
                }}
              />
            }
          />
          <SingleFeature
            title="Readable Code"
            description="All the templates are built keeping code readability in mind."
            icon={
              <VisibilityRounded
                style={{
                  fontSize: "4rem",
                }}
              />
            }
          />
          <SingleFeature
            title="Beautiful design"
            description="Showcase the potential of Flutter through beautiful UI designs."
            icon={
              <BrushRounded
                style={{
                  fontSize: "4rem",
                }}
              />
            }
          />
        </Grid>
      </Grid>
    </Grid>
  );
}

interface SingleFeatureProps {
  title: string;
  description: string;
  icon: any;
}

function SingleFeature(props: SingleFeatureProps) {
  return (
    <Grid item>
      <Grid
        container
        direction="column"
        justifyContent="flex-start"
        alignItems="flex-start"
        spacing={1}
      >
        <Grid item>
          <Card
            elevation={0}
            style={{
              padding: "2rem",
              marginBottom: "0.5rem",
              // background: "#c4d33a20",
              borderRadius: "1.5rem",
              color: "#c4d33a",
            }}
          >
            {props.icon}
          </Card>
        </Grid>
        <Grid item>
          <Typography
            variant="h4"
            style={{
              fontSize: "1.2rem",
              fontWeight: "bold",
            }}
          >
            {props.title}
          </Typography>
        </Grid>
        <Grid
          item
          style={{
            maxWidth: "200px",
          }}
        >
          <Typography
            variant="caption"
            style={{
              fontSize: "1rem",
            }}
          >
            {props.description}
          </Typography>
        </Grid>
      </Grid>
    </Grid>
  );
}
