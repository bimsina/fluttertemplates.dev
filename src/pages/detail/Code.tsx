import { CircularProgress, Grid, useTheme } from "@material-ui/core";
import React, { useEffect, useState } from "react";
import SyntaxHighlighter from "react-syntax-highlighter";
import {
  arduinoLight,
  dracula,
  github,
  githubGist,
} from "react-syntax-highlighter/dist/esm/styles/hljs";

function Code(params: { url: string }) {
  const [code, setCode] = useState("");
  const isDarkTheme = useTheme().palette.type === "dark";

  useEffect(() => {
    // Update the document title using the browser API
    fetch(params.url)
      .then((response) => response.text())
      .then((textString) => {
        setCode(textString);
      });
  }, []);

  return (
    <div>
      {code ? (
        <SyntaxHighlighter
          language="dart"
          style={!isDarkTheme ? github : dracula}
          showLineNumbers={false}
          customStyle={{ maxWidth: "95vw", maxHeight: "60vh" }}
        >
          {code}
        </SyntaxHighlighter>
      ) : (
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
            <CircularProgress size="1.5rem" thickness={8} />
          </Grid>
        </Grid>
      )}
    </div>
  );
}

export default Code;
