import { useTheme } from "next-themes";
import React, { useEffect, useState } from "react";
import { MdCopyAll, MdDone } from "react-icons/md";
import SyntaxHighlighter from "react-syntax-highlighter";
import { github, dracula } from "react-syntax-highlighter/dist/cjs/styles/hljs";
import CircularProgress from "./CircularProgress";

interface CodeBlockParams {
  url: string;
  height?: string;
}

function CodeBlock(params: CodeBlockParams) {
  const { theme, systemTheme } = useTheme();

  const [code, setCode] = useState("");

  const [copied, setCopied] = React.useState(false);

  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    fetch(params.url)
      .then((response) => response.text())
      .then((textString) => {
        setCode(textString);
      });
  }, [params.url]);

  const renderSyntaxHighlighter = () => {
    if (!mounted) return null;

    return (
      <SyntaxHighlighter
        language="dart"
        style={
          theme === "system"
            ? systemTheme === "dark"
              ? dracula
              : github
            : theme === "dark"
              ? dracula
              : github
        }
        showLineNumbers={false}
        customStyle={{
          maxHeight: `${params.height}`,
          fontSize: "0.95rem",
        }}
      >
        {code}
      </SyntaxHighlighter>
    );
  };

  return (
    <div>
      <div
        style={{
          position: "relative",
        }}
      >
        {renderSyntaxHighlighter()}
        <button
          aria-label="Copy"
          className="absolute right-5 top-4 flex items-center rounded-lg bg-primaryLight p-2 text-primary"
          onClick={() => {
            navigator.clipboard.writeText(code);
            setCopied(!copied);
          }}
        >
          {copied ? <MdDone /> : <MdCopyAll />}
          <div className="ml-1">{copied ? "Copied" : "Copy"}</div>
        </button>
      </div>

      {!code && (
        <div className="inline-flex min-h-[40vh] justify-center">
          <CircularProgress />
        </div>
      )}
    </div>
  );
}

export default CodeBlock;
