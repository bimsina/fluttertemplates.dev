import copy from "copy-to-clipboard";
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
  }, []);

  useEffect(() => {
    fetch(params.url)
      .then((response) => response.text())
      .then((textString) => {
        setCode(textString);
      });
  }, [params.url]);

  const renderSyntaxHighlighter = () => {
    if (!mounted) return <></>;

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
          className="absolute top-4 right-5 rounded-lg bg-primaryLight p-2 flex items-center text-primary"
          // style={{
          //   position: "absolute",
          //   top: "16px",
          //   right: "20px",
          //   borderRadius: "10rem",
          // }}
          onClick={() => {
            copy(code);
            setCopied(!copied);
          }}
        >
          {copied ? <MdDone /> : <MdCopyAll />}
          <div className="ml-1">{copied ? "Copied" : "Copy"}</div>
        </button>
      </div>

      {!code && (
        <div className="inline-flex justify-center min-h-[40vh]">
          <CircularProgress />
        </div>
      )}

      {/* <Snackbar
        open={open}
        autoHideDuration={4000}
        onClose={handleClose}
        message="Code copied successfully!"
        action={_snackBarAction}
        TransitionComponent={SlideTransition}
      /> */}
    </div>
  );
}

// function SlideTransition(props: SlideProps) {
//   return <Slide {...props} direction="right" />;
// }
export default CodeBlock;
