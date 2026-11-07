import { Code, Laptop, Maximize, Smartphone, Tablet } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import FlutterAppIframe, { type FlutterAppControls } from "./FlutterAppIframe";
import TemplateCodeEditor from "./TemplateCodeEditor";

export type View = "phone" | "tablet" | "desktop" | "code";

function ViewButton({
  active,
  onClick,
  className,
  children,
}: {
  active: boolean;
  onClick: () => void;
  className?: string;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      className={cn(
        "inline-flex h-8 cursor-pointer items-center gap-1.5 rounded-lg px-3 text-sm font-medium transition-colors",
        active
          ? "bg-card dark:bg-accent text-foreground shadow-sm"
          : "text-muted-foreground hover:text-foreground",
        className,
      )}
    >
      {children}
    </button>
  );
}

export default function TemplateWorkbench({
  title,
  path,
  skipUrlFormatting = false,
  registryUrl,
  codeRoot,
  files = [],
  initialView = "phone",
  showDesktop = false,
}: {
  title: string;
  path?: string;
  skipUrlFormatting?: boolean;
  // Where the file contents load from, and the prefix those paths carry.
  registryUrl?: string;
  codeRoot?: string;
  files?: string[];
  initialView?: View;
  showDesktop?: boolean;
}) {
  const hasCode = files.length > 0 && Boolean(registryUrl);
  const [view, setView] = useState<View>(initialView);
  const [selected, setSelected] = useState(
    files.includes("app.dart") ? "app.dart" : (files[0] ?? ""),
  );
  const [tabs, setTabs] = useState(selected ? [selected] : []);
  const [sources, setSources] = useState<Record<string, string> | null>(null);
  const [loadFailed, setLoadFailed] = useState(false);
  const app = useRef<FlutterAppControls>(null);
  const root = useRef<HTMLDivElement>(null);

  const source = sources?.[selected];

  useEffect(() => {
    if (view !== "code" || !registryUrl || sources) return;
    let cancelled = false;
    setLoadFailed(false);
    fetch(registryUrl)
      .then((response) => {
        if (!response.ok) throw new Error(String(response.status));
        return response.json();
      })
      .then((entry: { files: { path: string; content: string }[] }) => {
        if (cancelled) return;
        const prefix = codeRoot ? `${codeRoot}/` : "";
        setSources(
          Object.fromEntries(
            entry.files.map((file) => [
              file.path.startsWith(prefix)
                ? file.path.slice(prefix.length)
                : file.path,
              file.content,
            ]),
          ),
        );
      })
      .catch(() => {
        if (!cancelled) setLoadFailed(true);
      });
    return () => {
      cancelled = true;
    };
  }, [view, sources, registryUrl, codeRoot]);

  const selectFile = (next: string) => {
    setSelected(next);
    setTabs((open) => (open.includes(next) ? open : [...open, next]));
  };

  const closeTab = (path: string) => {
    const index = tabs.indexOf(path);
    const remaining = tabs.filter((tab) => tab !== path);
    setTabs(remaining);
    if (path === selected) {
      setSelected(remaining[Math.min(index, remaining.length - 1)]);
    }
  };

  // File names in the docs become links that open here.
  useEffect(() => {
    const docs = document.querySelector("[data-template-docs]");
    if (!hasCode || !docs) return;

    const resolve = (text: string) => {
      const matches = files.filter(
        (file) => file === text || file.endsWith(`/${text}`),
      );
      return matches.length === 1 ? matches[0] : undefined;
    };

    docs.querySelectorAll(":not(pre) > code").forEach((code) => {
      const target = resolve(code.textContent?.trim() ?? "");
      if (!target || code.parentElement?.closest("button")) return;
      const link = document.createElement("button");
      link.type = "button";
      link.className = "template-file-link";
      link.dataset.templateFile = target;
      link.title = "Open this file";
      code.replaceWith(link);
      link.append(code);
    });

    const onClick = (event: Event) => {
      const link = (event.target as Element).closest<HTMLElement>(
        "[data-template-file]",
      );
      if (!link?.dataset.templateFile) return;
      selectFile(link.dataset.templateFile);
      setView("code");
      root.current?.scrollIntoView({ block: "start" });
    };
    docs.addEventListener("click", onClick);
    return () => docs.removeEventListener("click", onClick);
  }, [files, hasCode]);

  return (
    <div
      ref={root}
      className="bg-muted/60 dark:bg-card/50 relative overflow-hidden rounded-2xl"
      data-pagefind-ignore="all"
    >
      <div className="relative flex h-14 items-center justify-center px-3">
        {hasCode && (
          <div className="bg-muted flex items-center gap-0.5 rounded-xl p-1">
            <ViewButton
              active={view === "phone"}
              onClick={() => setView("phone")}
            >
              <Smartphone className="size-3.5" />
              Phone
            </ViewButton>
            <ViewButton
              active={view === "tablet"}
              onClick={() => setView("tablet")}
              className="hidden lg:inline-flex"
            >
              <Tablet className="size-3.5 rotate-90" />
              Tablet
            </ViewButton>
            {showDesktop && (
              <ViewButton
                active={view === "desktop"}
                onClick={() => setView("desktop")}
                className="hidden xl:inline-flex"
              >
                <Laptop className="size-3.5" />
                Desktop
              </ViewButton>
            )}
            <ViewButton
              active={view === "code"}
              onClick={() => setView("code")}
            >
              <Code className="size-3.5" />
              Code
            </ViewButton>
          </div>
        )}
        {view !== "code" && (
          <button
            type="button"
            onClick={() => app.current?.requestFullscreen()}
            aria-label="Open the app in full screen"
            title="Full screen"
            className="text-muted-foreground hover:text-foreground absolute right-3 inline-flex size-9 cursor-pointer items-center justify-center rounded-lg transition-colors"
          >
            <Maximize className="size-4" />
          </button>
        )}
      </div>

      <div
        className={cn(
          "px-2 pb-2 sm:px-6 sm:pb-8",
          view === "code" && "invisible absolute inset-x-0",
        )}
      >
        <FlutterAppIframe
          controlRef={app}
          path={path}
          skipUrlFormatting={skipUrlFormatting}
          className={cn(
            "bg-background ring-border h-[640px] max-w-full overflow-clip ring-1 transition-[width] duration-300 motion-reduce:transition-none md:h-[660px]",
            "rounded-[14px]",
            view === "desktop"
              ? "w-[1024px]"
              : view === "tablet"
                ? "w-[820px]"
                : "w-[375px]",
          )}
        />
      </div>

      {view === "code" && (
        <div className="px-2 pb-2 sm:px-6 sm:pb-8">
          <TemplateCodeEditor
            project={codeRoot?.split("/").pop() ?? title}
            files={files}
            tabs={tabs}
            selected={selected}
            source={source}
            loadFailed={loadFailed}
            onSelect={selectFile}
            onClose={closeTab}
          />
        </div>
      )}
    </div>
  );
}
