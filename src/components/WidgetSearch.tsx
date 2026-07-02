import { Icon } from "@iconify/react";
import { useEffect, useMemo, useRef, useState } from "react";

export interface WidgetSearchItem {
  id: string;
  title: string;
  category?: string;
  icon?: string;
  kind: "category" | "widget";
}

export default function WidgetSearch({
  items,
  count,
}: {
  items: WidgetSearchItem[];
  count?: number;
}) {
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(0);
  const rootRef = useRef<HTMLDivElement>(null);

  const results = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return [] as WidgetSearchItem[];
    return items
      .map((it) => {
        const t = it.title.toLowerCase();
        const c = (it.category ?? "").toLowerCase();
        let score = 0;
        if (t === q) score = 100;
        else if (t.startsWith(q)) score = 80;
        else if (t.includes(q)) score = 60;
        else if (c.includes(q)) score = 30;
        if (it.kind === "category" && score > 0) score += 6;
        return { it, score };
      })
      .filter((s) => s.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 8)
      .map((s) => s.it);
  }, [query, items]);

  useEffect(() => setActive(0), [query]);

  useEffect(() => {
    const onDocClick = (e: MouseEvent) => {
      if (!rootRef.current?.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", onDocClick);
    return () => document.removeEventListener("mousedown", onDocClick);
  }, []);

  const go = (it?: WidgetSearchItem) => {
    const target = it ?? results[active];
    if (target) window.location.href = `/widgets/${target.id}/`;
  };

  const onKey = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setActive((a) => Math.min(a + 1, results.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActive((a) => Math.max(a - 1, 0));
    } else if (e.key === "Enter") {
      e.preventDefault();
      go();
    } else if (e.key === "Escape") {
      setOpen(false);
    }
  };

  return (
    <div ref={rootRef} className="relative">
      <div className="relative">
        <Icon
          icon="mdi:magnify"
          className="text-muted-foreground pointer-events-none absolute top-1/2 left-4 size-5 -translate-y-1/2"
        />
        <input
          type="search"
          value={query}
          placeholder={
            count
              ? `Search ${count} widgets — try “otp”, “chart”, “onboarding”…`
              : "Search widgets and categories…"
          }
          onChange={(e) => {
            setQuery(e.target.value);
            setOpen(true);
          }}
          onFocus={() => setOpen(true)}
          onKeyDown={onKey}
          autoComplete="off"
          className="border-border bg-card focus:border-primary focus:ring-primary/20 w-full rounded-2xl border py-3.5 pr-4 pl-11 text-sm transition-colors focus:ring-4 focus:outline-none"
        />
      </div>

      {open && query.trim() && (
        <div className="border-border bg-popover absolute z-40 mt-2 w-full overflow-hidden rounded-2xl border">
          {results.length === 0 ? (
            <div className="text-muted-foreground px-4 py-6 text-center text-sm">
              No widgets match “{query.trim()}”.
            </div>
          ) : (
            <ul className="max-h-[22rem] overflow-y-auto p-1.5">
              {results.map((it, i) => (
                <li key={it.kind + it.id}>
                  <a
                    href={`/widgets/${it.id}/`}
                    data-swup-preload
                    onMouseEnter={() => setActive(i)}
                    className={`flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-colors ${
                      i === active ? "bg-accent text-accent-foreground" : ""
                    }`}
                  >
                    <span className="bg-muted text-muted-foreground flex size-8 flex-none items-center justify-center rounded-lg">
                      {it.icon && <Icon icon={it.icon} className="size-4" />}
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block truncate font-medium">
                        {it.title}
                      </span>
                      <span className="text-muted-foreground block truncate text-xs">
                        {it.kind === "category" ? "Category" : it.category}
                      </span>
                    </span>
                    <Icon
                      icon="mdi:arrow-top-right"
                      className="text-muted-foreground size-4 shrink-0"
                    />
                  </a>
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </div>
  );
}
