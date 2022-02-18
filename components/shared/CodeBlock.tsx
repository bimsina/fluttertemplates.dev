import {
  Button,
  CircularProgress,
  Grid,
  IconButton,
  Snackbar,
  useTheme,
} from "@mui/material";
import { Close, FileCopyRounded, GitHub } from "@mui/icons-material";
import copy from "copy-to-clipboard";
import React, { useEffect, useState } from "react";
import SyntaxHighlighter from "react-syntax-highlighter";
import { dracula, github } from "react-syntax-highlighter/dist/cjs/styles/hljs";
import Slide, { SlideProps } from "@mui/material/Slide";

interface CodeBlockParams {
  url: string;
  height?: string;
}

function CodeBlock(params: CodeBlockParams) {
  const [code, setCode] = useState("");
  const isDarkTheme = useTheme().palette.mode === "dark";

  const [open, setOpen] = React.useState(false);

  const handleClose = (
    event: React.SyntheticEvent | Event,
    reason?: string
  ) => {
    if (reason === "clickaway") {
      return;
    }

    setOpen(false);
  };

  useEffect(() => {
    fetch(params.url)
      .then((response) => response.text())
      .then((textString) => {
        setCode(textString);
      });
  }, [params.url]);

  const _snackBarAction = (
    <React.Fragment>
      <IconButton
        size="small"
        aria-label="close"
        color="inherit"
        onClick={handleClose}
      >
        <Close fontSize="small" />
      </IconButton>
    </React.Fragment>
  );

  return (
    <div>
      <div
        style={{
          position: "relative",
        }}
      >
        <SyntaxHighlighter
          language="dart"
          style={!isDarkTheme ? github : dracula}
          showLineNumbers={false}
          customStyle={{
            maxHeight: `${params.height}`,
            fontSize: "0.95rem",
          }}
        >
          {code}
        </SyntaxHighlighter>

        <Button
          aria-label="Copy"
          size="medium"
          variant="contained"
          color="secondary"
          disableElevation
          style={{
            position: "absolute",
            top: "16px",
            right: "20px",
            borderRadius: "10rem",
          }}
          startIcon={<FileCopyRounded />}
          onClick={() => {
            copy(code);
            setOpen(true);
          }}
        >
          Copy
        </Button>
      </div>

      {!code && (
        <Grid
          container
          direction="column"
          justifyContent="center"
          alignItems="center"
          style={{
            minHeight: "40vh",
          }}
        >
          <Grid item>
            <CircularProgress size="1.5rem" thickness={8} color="secondary" />
          </Grid>
        </Grid>
      )}

      <Snackbar
        open={open}
        autoHideDuration={4000}
        onClose={handleClose}
        message="Code copied successfully!"
        action={_snackBarAction}
        TransitionComponent={SlideTransition}
      />
    </div>
  );
}

function SlideTransition(props: SlideProps) {
  return <Slide {...props} direction="right" />;
}
export default CodeBlock;
