import { Grid } from "@material-ui/core";
import { GitHub } from "@material-ui/icons";
import React from "react";
import CustomContainedButton from "./buttons/ContainedButton";
import CodeBlock from "./shared/CodeBlock";

interface CodeParams {
  codeGistUrl?: string;
  fullCodeUrl?: string;
}

function Code(params: CodeParams) {
  return (
    <div>
      {params.codeGistUrl && (
        <CodeBlock url={params.codeGistUrl} height="50vh" />
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
              <CustomContainedButton
                label="Full Source Code"
                icon={<GitHub />}
              />
            </a>
          </Grid>
        </Grid>
      )}
    </div>
  );
}

export default Code;
