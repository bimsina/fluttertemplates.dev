import { preparePresortedFileTreeInput } from "@pierre/trees";
import { FileTree, useFileTree } from "@pierre/trees/react";
import { useEffect, useRef } from "react";
import type { CSSProperties } from "react";
import { DART_ICON_PATH } from "./DartIcon";

// The tree renders in a shadow root, so the site's colors go in through its
// override variables.
const treeStyle = {
  height: "100%",
  "--trees-bg-override": "var(--editor-panel)",
  "--trees-bg-muted-override": "var(--editor-line)",
  "--trees-fg-override": "var(--editor-fg)",
  "--trees-fg-muted-override": "var(--editor-muted)",
  "--trees-selected-bg-override": "var(--editor-selected)",
  "--trees-selected-fg-override": "var(--editor-fg)",
  "--trees-border-color-override": "var(--editor-line)",
  "--trees-accent-override": "var(--primary)",
  "--trees-focus-ring-color-override": "var(--ring)",
  "--trees-font-family-override": "var(--font-sans)",
  "--trees-font-size-override": "13px",
} as CSSProperties;

const dartSprite = `<svg xmlns="http://www.w3.org/2000/svg" style="display:none"><symbol id="template-dart" viewBox="0 0 24 24"><path fill="var(--editor-dart)" d="${DART_ICON_PATH}"/></symbol></svg>`;

export default function TemplateFileTree({
  files,
  selected,
  onSelect,
}: {
  files: string[];
  selected: string;
  onSelect: (path: string) => void;
}) {
  const latest = useRef({ files, selected, onSelect });
  latest.current = { files, selected, onSelect };

  const { model } = useFileTree({
    // Registry order keeps app.dart, the entry point, at the top.
    preparedInput: preparePresortedFileTreeInput(files),
    initialExpansion: "open",
    initialSelectedPaths: [selected],
    density: "compact",
    icons: {
      set: "minimal",
      spriteSheet: dartSprite,
      byFileExtension: {
        dart: { name: "template-dart", viewBox: "0 0 24 24" },
      },
    },
    onSelectionChange: (paths) => {
      const next = paths.at(-1);
      const { files, selected, onSelect } = latest.current;
      if (next && next !== selected && files.includes(next)) onSelect(next);
    },
  });

  // Doc links change the file from outside the tree.
  useEffect(() => {
    const current = model.getSelectedPaths();
    if (current.length === 1 && current[0] === selected) return;
    current.forEach((path) => model.getItem(path)?.deselect());
    model.getItem(selected)?.select();
    model.scrollToPath(selected, { focus: false });
  }, [model, selected]);

  return <FileTree model={model} style={treeStyle} />;
}
