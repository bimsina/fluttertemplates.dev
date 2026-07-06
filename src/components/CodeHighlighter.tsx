import SyntaxHighlighter from "react-syntax-highlighter/dist/esm/prism-light";
import dart from "react-syntax-highlighter/dist/esm/languages/prism/dart";
import okaidia from "react-syntax-highlighter/dist/esm/styles/prism/okaidia";
import prism from "react-syntax-highlighter/dist/esm/styles/prism/prism";

SyntaxHighlighter.registerLanguage("dart", dart);

export default function CodeHighlighter({
  content,
  theme,
}: {
  content: string;
  theme: "dark" | "light";
}) {
  return (
    <SyntaxHighlighter
      language="dart"
      style={theme === "dark" ? okaidia : prism}
      customStyle={{
        margin: 0,
        height: "100%",
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
