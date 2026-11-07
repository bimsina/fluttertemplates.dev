import { Check, ChevronDown, Copy, X } from "lucide-react";
import { lazy, Suspense, useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";
import DartIcon from "./DartIcon";

const CodeHighlighter = lazy(() => import("./CodeHighlighter"));
const TemplateFileTree = lazy(() => import("./TemplateFileTree"));

function basename(path: string) {
  return path.slice(path.lastIndexOf("/") + 1);
}

export default function TemplateCodeEditor({
  project,
  files,
  tabs,
  selected,
  source,
  loadFailed,
  onSelect,
  onClose,
}: {
  project: string;
  files: string[];
  tabs: string[];
  selected: string;
  source?: string;
  loadFailed: boolean;
  onSelect: (path: string) => void;
  onClose: (path: string) => void;
}) {
  const [copied, setCopied] = useState(false);
  const tabStrip = useRef<HTMLDivElement>(null);
  const codeScroller = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setCopied(false);
    codeScroller.current?.scrollTo({ top: 0, left: 0 });

    // Scrolls the strip only: scrollIntoView would also move the page.
    const strip = tabStrip.current;
    const tab = strip?.querySelector<HTMLElement>('[aria-selected="true"]');
    if (!strip || !tab) return;
    const left = tab.offsetLeft - strip.offsetLeft;
    if (left < strip.scrollLeft) strip.scrollLeft = left;
    else if (left + tab.offsetWidth > strip.scrollLeft + strip.clientWidth) {
      strip.scrollLeft = left + tab.offsetWidth - strip.clientWidth;
    }
  }, [selected]);

  const copySource = async () => {
    if (source === undefined) return;
    await navigator.clipboard.writeText(source);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1600);
  };

  return (
    <div className="bg-editor text-editor-fg ring-editor-line flex h-[640px] gap-1.5 overflow-hidden rounded-[14px] p-1.5 ring-1 md:h-[660px]">
      {files.length > 1 && (
      <div className="bg-editor-panel ring-editor-line hidden w-72 shrink-0 flex-col overflow-hidden rounded-[10px] ring-1 md:flex">
        <div className="flex h-11 shrink-0 items-center gap-3 px-4">
          <span className="flex gap-1.5" aria-hidden="true">
            <span className="size-2.5 rounded-full bg-[#ff5f57]" />
            <span className="size-2.5 rounded-full bg-[#febc2e]" />
            <span className="size-2.5 rounded-full bg-[#28c840]" />
          </span>
          <p className="truncate text-sm font-medium">{project}</p>
        </div>
        <div className="min-h-0 flex-1">
          <Suspense fallback={null}>
            <TemplateFileTree
              files={files}
              selected={selected}
              onSelect={onSelect}
            />
          </Suspense>
        </div>
      </div>
      )}

      <div className="flex min-w-0 flex-1 flex-col">
        <div className="flex h-11 shrink-0 items-center gap-2">
          <div
            ref={tabStrip}
            role="tablist"
            aria-label="Open files"
            className="relative hidden min-w-0 flex-1 gap-1 overflow-x-auto [scrollbar-width:none] md:flex"
          >
            {tabs.map((tab) => {
              const active = tab === selected;
              return (
                <div
                  key={tab}
                  title={tab}
                  className={cn(
                    "group flex h-8 shrink-0 items-center rounded-lg text-[0.8rem] transition-colors",
                    active
                      ? "bg-editor-panel text-editor-fg"
                      : "text-editor-muted hover:text-editor-fg",
                  )}
                >
                  <button
                    type="button"
                    role="tab"
                    aria-selected={active}
                    onClick={() => onSelect(tab)}
                    className="flex h-full cursor-pointer items-center gap-2 pl-2.5"
                  >
                    <DartIcon className="size-3.5 shrink-0" />
                    {basename(tab)}
                  </button>
                  {tabs.length > 1 ? (
                    <button
                      type="button"
                      onClick={() => onClose(tab)}
                      aria-label={`Close ${basename(tab)}`}
                      className={cn(
                        "hover:bg-editor-line mx-1 inline-flex size-5 cursor-pointer items-center justify-center rounded opacity-0 group-hover:opacity-100 focus-visible:opacity-100",
                        active && "opacity-100",
                      )}
                    >
                      <X className="size-3" />
                    </button>
                  ) : (
                    <span className="w-2.5" />
                  )}
                </div>
              );
            })}
          </div>

          <div className="relative min-w-0 flex-1 md:hidden">
            <select
              aria-label="Source file"
              value={selected}
              onChange={(event) => onSelect(event.target.value)}
              className="w-full cursor-pointer appearance-none truncate bg-transparent pr-6 pl-2.5 font-mono text-xs outline-none"
            >
              {files.map((file) => (
                <option key={file} value={file}>
                  {file}
                </option>
              ))}
            </select>
            <ChevronDown className="text-editor-muted pointer-events-none absolute top-1/2 right-0 size-3.5 -translate-y-1/2" />
          </div>

          <button
            type="button"
            onClick={copySource}
            disabled={source === undefined}
            aria-label="Copy this file"
            title="Copy this file"
            className="text-editor-muted hover:text-editor-fg inline-flex size-8 shrink-0 cursor-pointer items-center justify-center rounded-lg transition-colors disabled:cursor-default disabled:opacity-40"
          >
            {copied ? (
              <Check className="size-3.5" />
            ) : (
              <Copy className="size-3.5" />
            )}
          </button>
        </div>

        <div
          ref={codeScroller}
          tabIndex={0}
          aria-label={`Source of ${selected}`}
          role="region"
          className="min-h-0 flex-1 overflow-auto text-[0.8rem] leading-relaxed outline-none"
        >
          {source !== undefined ? (
            <Suspense fallback={<pre className="p-4 font-mono">{source}</pre>}>
              <CodeHighlighter content={source} theme="editor" />
            </Suspense>
          ) : (
            <p className="text-editor-muted p-4 text-sm">
              {loadFailed ? "The source didn't load." : "Loading source"}
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
