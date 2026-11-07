import { Check, Copy, RotateCcw } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { AGENT_PROMPT } from "@/consts";
import { cn } from "@/lib/utils";
import { AGENTS } from "./AgentOnboarding";

type Tab = "session" | "prompt" | "cli" | "mcp";
type Client = "claude" | "cursor" | "vscode";

const ASK = "Add a login screen and connect it to our AuthRepository";

// `command` and `output` lines match what the tools print.
const STEPS = [
  {
    label: "Searches the library",
    command: 'search_widgets("login")',
    output: "auth/login_hero  Login Screen",
  },
  {
    label: "Adds the source",
    command: 'add_widget(["auth/login_hero"])',
    output: "create: lib/fluttertemplates/auth/login_hero.dart",
  },
  {
    label: "Connects your code",
    command: "edit lib/main.dart",
    output: "onSignIn now calls AuthRepository.signIn()",
  },
  {
    label: "Checks the project",
    command: "flutter analyze",
    output: "No issues found!",
  },
];

// Real output from `fluttertemplates search` and `add`.
const CLI = `$ dart pub global activate fluttertemplates_dev

$ fluttertemplates search login
auth/login_hero  Login Screen
  A Flutter login screen with a hero illustration, validated email
  and password fields, remember-me, and sign-in callbacks.

$ fluttertemplates add auth/login_hero
created: lib/fluttertemplates/auth/login_hero.dart
created: lib/fluttertemplates/LICENSE

Use LoginHero from auth/login_hero:
  import 'package:my_app/fluttertemplates/auth/login_hero.dart';

  home: const LoginHero(),`;

const MCP: Record<Client, { label: string; hint: string; code: string }> = {
  claude: {
    label: "Claude Code",
    hint: "Run this in your project",
    code: "claude mcp add fluttertemplates -- fluttertemplates mcp",
  },
  cursor: {
    label: "Cursor",
    hint: ".cursor/mcp.json",
    code: `{
  "mcpServers": {
    "fluttertemplates": {
      "command": "fluttertemplates",
      "args": ["mcp"]
    }
  }
}`,
  },
  vscode: {
    label: "VS Code",
    hint: ".vscode/mcp.json",
    code: `{
  "servers": {
    "fluttertemplates": {
      "type": "stdio",
      "command": "fluttertemplates",
      "args": ["mcp"]
    }
  }
}`,
  },
};

function Pill({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      className={cn(
        "h-8 cursor-pointer rounded-lg px-3 text-[0.8rem] font-medium transition-colors",
        active
          ? "bg-editor-panel text-editor-fg"
          : "text-editor-muted hover:text-editor-fg",
      )}
    >
      {children}
    </button>
  );
}

function useCopied() {
  const [copied, setCopied] = useState(false);
  const copy = async (value: string) => {
    await navigator.clipboard.writeText(value);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1800);
  };
  return { copied, copy, reset: () => setCopied(false) };
}

export default function AgentSection() {
  const [tab, setTab] = useState<Tab>("session");
  const [client, setClient] = useState<Client>("claude");
  // The server renders the finished session, for no-JS and reduced motion.
  const [typed, setTyped] = useState(ASK.length);
  const [step, setStep] = useState(STEPS.length);
  const [run, setRun] = useState(0);
  const panel = useRef<HTMLDivElement>(null);
  const setup = useCopied();
  const code = useCopied();

  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const element = panel.current;
    if (!element) return;

    const timers: number[] = [];
    const play = () => {
      setTyped(0);
      setStep(0);
      for (let i = 1; i <= ASK.length; i += 1) {
        timers.push(window.setTimeout(() => setTyped(i), i * 22));
      }
      STEPS.forEach((_, i) => {
        timers.push(
          window.setTimeout(
            () => setStep(i + 1),
            ASK.length * 22 + 500 + i * 850,
          ),
        );
      });
    };

    if (run > 0) {
      play();
      return () => timers.forEach(window.clearTimeout);
    }

    const rect = element.getBoundingClientRect();
    if (rect.top < window.innerHeight * 0.7) return;
    setTyped(0);
    setStep(0);
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return;
        observer.disconnect();
        play();
      },
      { threshold: 0.5 },
    );
    observer.observe(element);
    return () => {
      observer.disconnect();
      timers.forEach(window.clearTimeout);
    };
  }, [run]);

  const select = (next: Tab) => {
    setTab(next);
    code.reset();
  };

  const text =
    tab === "prompt"
      ? AGENT_PROMPT
      : tab === "mcp"
        ? MCP[client].code
        : tab === "cli"
          ? CLI
          : "";

  return (
    <div className="bg-muted/60 dark:bg-card/50 grid items-center gap-8 rounded-2xl p-4 sm:p-8 lg:grid-cols-[minmax(0,0.85fr)_minmax(0,1.15fr)] lg:gap-12 lg:p-12">
      <div className="max-lg:px-1 max-lg:pt-2">
        <h2 className="text-2xl font-bold tracking-tight md:text-4xl">
          Or let your agent do it.
        </h2>
        <p className="text-muted-foreground mt-3 md:text-lg">
          One prompt sets up your coding agent. After that, ask for a screen.
          It finds a real one, adds the source, and fits it to your code.
        </p>
        <button
          type="button"
          onClick={() => setup.copy(AGENT_PROMPT)}
          className="interactive-button bg-primary text-primary-foreground mt-6 inline-flex h-11 cursor-pointer items-center gap-2 rounded-xl px-5 text-sm font-semibold hover:opacity-95"
        >
          {setup.copied ? (
            <Check className="size-4" />
          ) : (
            <Copy className="size-4" />
          )}
          <span aria-live="polite">
            {setup.copied ? "Prompt copied" : "Copy setup prompt"}
          </span>
        </button>
        <div className="text-muted-foreground mt-6 flex flex-wrap items-center gap-x-3 gap-y-2 text-sm">
          <span>Works with</span>
          <span className="flex items-center gap-2.5">
            {AGENTS.map((agent) => (
              <svg
                key={agent.name}
                viewBox="0 0 24 24"
                role="img"
                aria-label={agent.name}
                className="text-foreground size-[1.125rem]"
                fill={agent.color}
              >
                <path d={agent.path} />
              </svg>
            ))}
          </span>
          <span>and any MCP client</span>
        </div>
      </div>

      <div
        ref={panel}
        className="bg-editor text-editor-fg ring-editor-line min-w-0 overflow-hidden rounded-[14px] ring-1"
      >
        <div className="flex items-center justify-between gap-2 p-1.5">
          <div className="flex gap-0.5">
            <Pill active={tab === "session"} onClick={() => select("session")}>
              Example
            </Pill>
            <Pill active={tab === "prompt"} onClick={() => select("prompt")}>
              Prompt
            </Pill>
            <Pill active={tab === "cli"} onClick={() => select("cli")}>
              CLI
            </Pill>
            <Pill active={tab === "mcp"} onClick={() => select("mcp")}>
              MCP
            </Pill>
          </div>
          {tab === "session" ? (
            <button
              type="button"
              onClick={() => setRun((value) => value + 1)}
              aria-label="Replay the example"
              title="Replay"
              className="text-editor-muted hover:text-editor-fg inline-flex size-8 cursor-pointer items-center justify-center rounded-lg"
            >
              <RotateCcw className="size-3.5" />
            </button>
          ) : (
            <button
              type="button"
              onClick={() =>
                code.copy(
                  tab === "cli"
                    ? "dart pub global activate fluttertemplates_dev"
                    : text,
                )
              }
              aria-label={
                tab === "cli" ? "Copy the install command" : "Copy this"
              }
              title="Copy"
              className="text-editor-muted hover:text-editor-fg inline-flex size-8 cursor-pointer items-center justify-center rounded-lg"
            >
              {code.copied ? (
                <Check className="size-3.5" />
              ) : (
                <Copy className="size-3.5" />
              )}
            </button>
          )}
        </div>

        <div className="h-[25rem] overflow-auto">
          {tab === "session" && (
            <div className="flex flex-col gap-4 p-4 text-[0.8rem]">
              <p className="bg-editor-panel ml-auto max-w-[85%] rounded-xl rounded-br px-3.5 py-2.5 leading-relaxed">
                {ASK.slice(0, typed)}
                {typed < ASK.length && (
                  <span className="bg-editor-fg ml-0.5 inline-block h-3.5 w-px animate-pulse align-middle" />
                )}
              </p>
              <ol className="flex flex-col gap-3.5">
                {STEPS.map((item, i) => (
                  <li
                    key={item.label}
                    className={cn(
                      "flex gap-3 transition-opacity duration-300",
                      i < step ? "opacity-100" : "opacity-0",
                    )}
                  >
                    <span className="bg-editor-selected text-editor-fg mt-0.5 flex size-5 shrink-0 items-center justify-center rounded-full">
                      <Check className="size-3" />
                    </span>
                    <div className="min-w-0">
                      <p className="font-medium">{item.label}</p>
                      <p className="text-editor-muted mt-1 font-mono text-xs break-words">
                        {item.command}
                      </p>
                      <p className="mt-0.5 font-mono text-xs break-words text-[var(--code-string)]">
                        {item.output}
                      </p>
                    </div>
                  </li>
                ))}
              </ol>
            </div>
          )}

          {tab === "mcp" && (
            <div className="flex flex-wrap items-center gap-1 px-1.5 pt-1">
              {(Object.keys(MCP) as Client[]).map((key) => (
                <Pill
                  key={key}
                  active={client === key}
                  onClick={() => {
                    setClient(key);
                    code.reset();
                  }}
                >
                  {MCP[key].label}
                </Pill>
              ))}
              <span className="text-editor-muted ml-auto px-2.5 font-mono text-xs max-sm:hidden">
                {MCP[client].hint}
              </span>
            </div>
          )}

          {tab !== "session" && (
            <pre className="p-4 font-mono text-[0.8rem] leading-relaxed whitespace-pre-wrap">
              {text}
            </pre>
          )}
        </div>
      </div>
    </div>
  );
}
