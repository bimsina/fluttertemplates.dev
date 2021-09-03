import React from "react";
import { Button, Grid, List, ListItem } from "@material-ui/core";
import PageNotFoundImage from "../../assets/404.svg";

import { Typography } from "@material-ui/core";
import CustomButton from "../../components/custom_button";
import { Link } from "@material-ui/icons";

interface Props {
  packages: string[];
}

export default function PackagesUsed(params: Props) {
  return (
    <Grid
      container
      direction="column"
      justifyContent="center"
      alignItems="center"
      spacing={1}
      style={{
        height: "80%",
        width: "100%",
      }}
    >
      {params.packages.length === 0 && (
        <Grid item>
          <img
            src={PageNotFoundImage}
            style={{
              height: "30vh",
            }}
          />
        </Grid>
      )}
      {params.packages.length === 0 && (
        <Grid item>
          <Typography>No Packages Used</Typography>
        </Grid>
      )}

      {params.packages.map((packageName) => (
        <Grid item>
          <a
            href={packageName}
            target="_blank"
            referrerPolicy="no-referrer"
            style={{
              color: "transparent",
            }}
          >
            <Button
              style={{
                textTransform: "none",
              }}
            >
              <Link
                fontSize="small"
                style={{
                  marginRight: "8px",
                }}
              />
              {packageName.split("/").pop()?.toLowerCase()}
            </Button>
          </a>
        </Grid>
      ))}
    </Grid>
  );
}
