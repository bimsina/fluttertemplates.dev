import React from "react";
import { Button, Grid, List, ListItem } from "@material-ui/core";

import { Typography } from "@material-ui/core";
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
            src="/no_packages.svg"
            alt="No Packages Used"
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
        <Grid item key={packageName}>
          <a
            href={packageName}
            target="_blank"
            rel="noopener noreferrer"
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
              <img
                src={`https://img.shields.io/pub/v/${packageName
                  .split("/")
                  .pop()}.svg`}
                alt={packageName}
                style={{
                  marginLeft: "8px",
                }}
              />
            </Button>
          </a>
        </Grid>
      ))}
    </Grid>
  );
}
