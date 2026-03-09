import { Fullscreen } from "lucide-react";
import { useTheme } from "../hooks/useTheme";
import { useRef, useState, useEffect } from "react";
import { cn } from "@/lib/utils";

const FLUTTER_PREVIEW_READY_EVENT = "flutter-preview-ready";

export default function FlutterAppIframe({
  app = "core",
  theme: initialTheme,
  path,
  className,
  skipUrlFormatting = false,
  enableShowFullScreenButton = false,
  fullScreenButtonLabel = "Open in full screen",
}: {
  app?: string;
  theme?: "light" | "dark";
  path?: string;
  className?: string;
  skipUrlFormatting?: boolean;
  enableShowFullScreenButton?: boolean;
  fullScreenButtonLabel?: string;
}) {
  const theme = useTheme(initialTheme);
  const [isIOS, setIsIOS] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const fallbackTimerRef = useRef<number | null>(null);

  useEffect(() => {
    setIsIOS(
      /iPad|iPhone|iPod/.test(navigator.userAgent) && !(window as any).MSStream,
    );
  }, []);

  const queryParams = new URLSearchParams();

  if (path) {
    queryParams.set("path", path ?? "/");
  }
  queryParams.set("theme", theme);

  const url = skipUrlFormatting
    ? path
    : import.meta.env.DEV
      ? `http://localhost:8989/?${queryParams.toString()}`
      : `/flutter_apps/${app}/index.html?${queryParams.toString()}`;

  useEffect(() => {
    setIsLoading(true);
    if (fallbackTimerRef.current) {
      window.clearTimeout(fallbackTimerRef.current);
      fallbackTimerRef.current = null;
    }
  }, [url]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.source !== iframeRef.current?.contentWindow) return;
      if (
        typeof event.data !== "object" ||
        event.data === null ||
        !("type" in event.data) ||
        event.data.type !== FLUTTER_PREVIEW_READY_EVENT
      ) {
        return;
      }

      if (fallbackTimerRef.current) {
        window.clearTimeout(fallbackTimerRef.current);
        fallbackTimerRef.current = null;
      }
      setIsLoading(false);
    };

    window.addEventListener("message", handleMessage);

    return () => {
      window.removeEventListener("message", handleMessage);
      if (fallbackTimerRef.current) {
        window.clearTimeout(fallbackTimerRef.current);
        fallbackTimerRef.current = null;
      }
    };
  }, []);

  const requestFullscreen = () => {
    const element = iframeRef.current;
    if (!element) return;

    if (isIOS) {
      // iOS specific handling
      if ((element as any).webkitEnterFullscreen) {
        (element as any).webkitEnterFullscreen();
      } else if ((element as any).webkitRequestFullscreen) {
        (element as any).webkitRequestFullscreen();
      } else {
        // Fallback for iOS: try to make the iframe take up the full viewport
        element.style.position = "fixed";
        element.style.top = "0";
        element.style.left = "0";
        element.style.width = "100%";
        element.style.height = "100%";
        element.style.zIndex = "9999";
      }
    } else {
      // Non-iOS devices
      if (element.requestFullscreen) {
        element.requestFullscreen();
      } else if ((element as any).webkitRequestFullscreen) {
        (element as any).webkitRequestFullscreen();
      } else if ((element as any).msRequestFullscreen) {
        (element as any).msRequestFullscreen();
      } else if ((element as any).mozRequestFullScreen) {
        (element as any).mozRequestFullScreen();
      }
    }
  };

  return (
    <div className="flex flex-col items-center justify-center gap-3">
      <div className={cn("relative isolate overflow-hidden", className)}>
        {isLoading && (
          <div className="from-background/96 via-background/88 to-background/94 absolute inset-0 z-10 flex items-center justify-center bg-linear-to-b px-6 backdrop-blur-sm">
            <div className="border-border/70 bg-card/88 relative flex min-w-[220px] flex-col items-center gap-3 rounded-[1.75rem] border px-6 py-5 text-center shadow-xl">
              <div className="bg-primary/12 absolute inset-x-10 top-1 h-16 rounded-full blur-2xl" />
              <div className="relative flex h-12 w-12 items-center justify-center">
                <div className="border-primary/15 absolute inset-0 rounded-full border-[3px]" />
                <div className="border-primary absolute inset-0 animate-spin rounded-full border-[3px] border-t-transparent" />
              </div>
              <div className="relative space-y-1">
                <p className="text-foreground text-sm font-semibold">
                  Loading preview
                </p>
                <p className="text-muted-foreground text-xs">
                  Starting the Flutter app
                </p>
              </div>
              <div className="relative flex w-full items-center gap-2">
                <span className="bg-muted h-2 flex-1 rounded-full" />
                <span className="bg-primary/60 h-2 w-14 animate-pulse rounded-full" />
                <span className="bg-muted h-2 flex-1 rounded-full" />
              </div>
            </div>
          </div>
        )}
        <iframe
          className="h-full w-full border-0 bg-transparent"
          src={url}
          width="100%"
          height="100%"
          ref={iframeRef}
          allow="fullscreen"
          allowFullScreen
          loading="lazy"
          title="Flutter app preview"
          onLoad={() => {
            if (fallbackTimerRef.current) {
              window.clearTimeout(fallbackTimerRef.current);
            }
            fallbackTimerRef.current = window.setTimeout(() => {
              setIsLoading(false);
              fallbackTimerRef.current = null;
            }, 4000);
          }}
        ></iframe>
      </div>
      {enableShowFullScreenButton && (
        <button
          className="border-border/80 bg-card/75 text-muted-foreground hover:text-foreground hover:border-primary/30 hover:bg-accent/40 inline-flex h-9 cursor-pointer items-center gap-2 rounded-full border px-3.5 text-xs font-medium tracking-[0.01em] backdrop-blur-sm transition-all duration-200"
          onClick={requestFullscreen}
        >
          <Fullscreen className="size-3.5" />
          {fullScreenButtonLabel}
        </button>
      )}
    </div>
  );
}
