import { useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";

// Past this distance from the top of the window, a heading counts as read.
const OFFSET = 120;

export default function TableOfContents({
  headings,
}: {
  headings: { slug: string; text: string }[];
}) {
  const [active, setActive] = useState(headings[0]?.slug);
  const nav = useRef<HTMLElement>(null);

  useEffect(() => {
    const targets = headings.flatMap((heading) => {
      const element = document.getElementById(heading.slug);
      return element ? [{ slug: heading.slug, element }] : [];
    });

    let frame = 0;
    const update = () => {
      frame = 0;
      const atEnd =
        window.innerHeight + window.scrollY >=
        document.documentElement.scrollHeight - 2;
      if (atEnd) {
        setActive(targets.at(-1)?.slug);
        return;
      }
      let current = targets[0]?.slug;
      for (const target of targets) {
        if (target.element.getBoundingClientRect().top > OFFSET) break;
        current = target.slug;
      }
      setActive(current);
    };
    const onScroll = () => {
      if (!frame) frame = requestAnimationFrame(update);
    };

    update();
    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    return () => {
      cancelAnimationFrame(frame);
      window.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
    };
  }, [headings]);

  // Keeps the current entry in view when the list is taller than the window.
  useEffect(() => {
    const list = nav.current;
    const link = list?.querySelector<HTMLElement>('[aria-current="true"]');
    if (!list || !link) return;
    const top = link.offsetTop - list.offsetTop;
    if (top < list.scrollTop) list.scrollTop = top - 8;
    else if (top + link.offsetHeight > list.scrollTop + list.clientHeight) {
      list.scrollTop = top + link.offsetHeight - list.clientHeight + 8;
    }
  }, [active]);

  return (
    <nav
      ref={nav}
      aria-label="On this page"
      className="sticky top-24 hidden max-h-[calc(100vh-7rem)] self-start overflow-y-auto xl:block"
      data-pagefind-ignore
    >
      <p className="text-sm font-semibold">On this page</p>
      <ul className="border-border mt-3 flex flex-col border-l text-sm">
        {headings.map((heading) => (
          <li key={heading.slug}>
            <a
              href={`#${heading.slug}`}
              aria-current={heading.slug === active ? "true" : undefined}
              className={cn(
                "-ml-px block border-l-2 py-1.5 pl-3 transition-colors",
                heading.slug === active
                  ? "border-primary text-foreground font-medium"
                  : "text-muted-foreground hover:text-foreground border-transparent",
              )}
            >
              {heading.text}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}
