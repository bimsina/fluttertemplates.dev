import { Check, Sparkles } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

export default function CopyPromptButton({
  prompt,
  className,
}: {
  prompt: string;
  className?: string;
}) {
  const [copied, setCopied] = useState(false);

  const copy = async () => {
    await navigator.clipboard.writeText(prompt);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 2000);
  };

  return (
    <button
      type="button"
      onClick={copy}
      className={cn(
        "interactive-button border-border bg-card text-foreground hover:bg-muted inline-flex h-11 cursor-pointer items-center justify-center gap-2 rounded-xl border px-5 text-sm font-semibold",
        className,
      )}
    >
      {copied ? <Check className="size-4" /> : <Sparkles className="size-4" />}
      <span aria-live="polite">{copied ? "Prompt copied" : "Copy prompt"}</span>
    </button>
  );
}
