import { Check, Copy } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

export default function CopyCommand({
  command,
  className,
}: {
  command: string;
  className?: string;
}) {
  const [copied, setCopied] = useState(false);

  const copy = async () => {
    await navigator.clipboard.writeText(command);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1600);
  };

  return (
    <button
      type="button"
      onClick={copy}
      aria-label={`Copy command: ${command}`}
      className={cn(
        "border-border bg-card hover:border-primary/40 group flex h-11 min-w-0 cursor-pointer items-center gap-3 rounded-xl border pr-3 pl-4 text-left transition-colors",
        className,
      )}
    >
      <code className="min-w-0 flex-1 truncate font-mono text-xs sm:text-[0.8rem]">
        {command}
      </code>
      <span className="text-muted-foreground group-hover:text-foreground shrink-0">
        {copied ? <Check className="size-4" /> : <Copy className="size-4" />}
      </span>
      <span className="sr-only" aria-live="polite">
        {copied ? "Copied" : ""}
      </span>
    </button>
  );
}
