import {
  Button,
  CircularProgress,
  Grid,
  Snackbar,
  useTheme,
} from "@material-ui/core";
import { FileCopyRounded, GitHub } from "@material-ui/icons";
import copy from "copy-to-clipboard";
import React, { useEffect, useState } from "react";
import SyntaxHighlighter from "react-syntax-highlighter";
import { dracula, github } from "react-syntax-highlighter/dist/cjs/styles/hljs";

interface CodeBlockParams {
  url: string;
  height?: string;
}

function CodeBlock(params: CodeBlockParams) {
  const [code, setCode] = useState("");
  const isDarkTheme = useTheme().palette.type === "dark";

  const [open, setOpen] = React.useState(false);

  const handleClose = (
    event: React.SyntheticEvent | React.MouseEvent,
    reason?: string
  ) => {
    setOpen(false);
  };

  useEffect(() => {
    fetch(params.url)
      .then((response) => response.text())
      .then((textString) => {
        setCode(textString);
      });
  }, [params.url]);

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
          }}
          onClick={() => {
            copy(code);
            setOpen(true);
          }}
        >
          <FileCopyRounded
            style={{
              fontSize: "1rem",
              marginRight: "2px",
            }}
          />
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
        anchorOrigin={{
          vertical: "bottom",
          horizontal: "left",
        }}
        open={open}
        autoHideDuration={4000}
        onClose={handleClose}
        message="Code copied successfully!"
      />
    </div>
  );
}

export default CodeBlock;
