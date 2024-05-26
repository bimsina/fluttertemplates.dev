import React from "react";
import CustomContainedButton from "./buttons/ContainedButton";
import CodeBlock from "./shared/CodeBlock";
import { AiFillGithub } from "react-icons/ai";

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
        <div className="mt-4 inline-flex w-full items-center justify-center">
          <a
            aria-label="Download Code"
            href={params.fullCodeUrl}
            target="_blank"
            rel="noopener noreferrer"
          >
            <CustomContainedButton
              label="Full Source Code"
              endIcon={<AiFillGithub />}
            />
          </a>
        </div>
      )}
    </div>
  );
}

export default Code;
