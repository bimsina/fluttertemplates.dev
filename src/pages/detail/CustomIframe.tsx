import { CircularProgress, Grid, Typography } from "@material-ui/core";
import React from "react";
interface CustomIframeProps {
  url: string;
}

export default function CustomIframe(props: CustomIframeProps) {
  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
      }}
    >
      <Grid
        container
        direction="column"
        justifyContent="center"
        alignItems="center"
        style={{
          height: "100%",
          width: "100%",
          position: "absolute",
        }}
      >
        <CircularProgress />
        <Typography
          variant="h6"
          style={{
            marginTop: "16px",
          }}
        >
          App is being loaded
        </Typography>
      </Grid>
      <iframe
        src={props.url}
        style={{
          height: "100%",
          width: "100%",
          borderRadius: "16px",
          border: "4px solid grey",
          position: "absolute",
        }}
      ></iframe>
    </div>
  );
}
