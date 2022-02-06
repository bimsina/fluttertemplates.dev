import { CircularProgress, Grid, Typography } from "@material-ui/core";
import React, { useEffect } from "react";
interface CustomIframeProps {
  url: string;
  style?: React.CSSProperties;
}

export default function CustomIframe(props: CustomIframeProps) {
  const [isLoading, setIsLoading] = React.useState(true);

  useEffect(() => {
    setTimeout(() => {
      setIsLoading(false);
    }, 10000);
  }, []);

  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
      }}
    >
      {isLoading && (
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
          <CircularProgress size="1.5rem" thickness={8} color="secondary" />
        </Grid>
      )}
      <iframe
        src={props.url}
        style={{
          height: "100%",
          width: "100%",
          position: "absolute",
          border: "none",
          ...props.style,
        }}
      ></iframe>
    </div>
  );
}
