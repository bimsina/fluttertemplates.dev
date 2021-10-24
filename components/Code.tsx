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
import CustomButton from "./custom_button";

interface CodeParams {
  codeGistUrl?: string;
  fullCodeUrl?: string;
}

function Code(params: CodeParams) {
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
    if (params.codeGistUrl) {
      fetch(params.codeGistUrl)
        .then((response) => response.text())
        .then((textString) => {
          setCode(textString);
        });
    }
  }, [params.codeGistUrl]);

  return (
    <div>
      {code && params.codeGistUrl && (
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
              maxWidth: "95vw",
              maxHeight: "55vh",
              width: "100%",
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
              fontSize="small"
              style={{
                marginBottom: "-2px",
                marginRight: "2px",
              }}
            />
            Copy
          </Button>
        </div>
      )}

      {!code && params.codeGistUrl && (
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

      {params.fullCodeUrl && (
        <Grid
          container
          direction="row"
          justifyContent="center"
          alignItems="center"
          style={{
            height: params.codeGistUrl ? "100%" : "70vh",
          }}
        >
          <Grid item>
            <a
              aria-label="Download Code"
              href={params.fullCodeUrl}
              target="_blank"
              rel="noopener noreferrer"
            >
              <CustomButton>
                <GitHub
                  fontSize="small"
                  style={{
                    marginRight: "8px",
                  }}
                />
                Full Source code
              </CustomButton>
            </a>
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

export default Code;
