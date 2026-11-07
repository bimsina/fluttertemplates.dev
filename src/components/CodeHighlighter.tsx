import type { CSSProperties } from "react";
import SyntaxHighlighter from "react-syntax-highlighter/dist/esm/prism-light";
import dart from "react-syntax-highlighter/dist/esm/languages/prism/dart";
import okaidia from "react-syntax-highlighter/dist/esm/styles/prism/okaidia";
import prism from "react-syntax-highlighter/dist/esm/styles/prism/prism";

SyntaxHighlighter.registerLanguage("dart", dart);

const color = (name: string): CSSProperties => ({ color: `var(--code-${name})` });

// Colors come from CSS variables, so one theme follows light and dark.
const editorTheme: Record<string, CSSProperties> = {
  'code[class*="language-"]': { color: "var(--editor-fg)" },
  'pre[class*="language-"]': { color: "var(--editor-fg)" },
  comment: { ...color("comment"), fontStyle: "normal" },
  prolog: color("comment"),
  doctype: color("comment"),
  punctuation: color("punctuation"),
  operator: color("punctuation"),
  keyword: color("keyword"),
  boolean: color("number"),
  number: color("number"),
  string: color("string"),
  char: color("string"),
  "string-literal": color("string"),
  "class-name": color("class"),
  builtin: color("class"),
  function: color("function"),
  metadata: color("metadata"),
  annotation: color("metadata"),
  interpolation: { color: "var(--editor-fg)" },
};

export default function CodeHighlighter({
  content,
  theme,
}: {
  content: string;
  theme: "dark" | "light" | "editor";
}) {
  const editor = theme === "editor";
  return (
    <SyntaxHighlighter
      language="dart"
      style={editor ? editorTheme : theme === "dark" ? okaidia : prism}
      showLineNumbers={editor}
      lineNumberStyle={{
        minWidth: "3em",
        paddingRight: "1.25em",
        color: "var(--editor-muted)",
        opacity: 0.7,
      }}
      customStyle={{
        margin: 0,
        height: editor ? undefined : "100%",
        padding: editor ? "0.5rem 1rem 1.5rem 0" : undefined,
        borderRadius: "0.5rem",
        background: "transparent",
      }}
      codeTagProps={{
        style: { fontFamily: "var(--font-mono)" },
      }}
    >
      {content}
    </SyntaxHighlighter>
  );
}
