import { Fullscreen } from "lucide-react";
import { useTheme } from "../hooks/useTheme";
import { useRef } from "react";

export default function FlutterAppIframe({
  app = "core",
  theme: initialTheme,
  path,
  className,
  skipUrlFormatting = false,
  enableShowFullScreenButton = false,
}: {
  app?: string;
  theme?: "light" | "dark";
  path?: string;
  className?: string;
  skipUrlFormatting?: boolean;
  enableShowFullScreenButton?: boolean;
}) {
  const theme = useTheme(initialTheme);

  const iframeRef = useRef<HTMLIFrameElement>(null);

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

  return (
    <div className="flex flex-col gap-2 items-center justify-center">
      <div className={className}>
        <iframe src={url} width="100%" height="100%" ref={iframeRef}></iframe>
      </div>
      {enableShowFullScreenButton && (
        <button
          className="border border-primary text-primary px-4 py-2 rounded-md flex items-center gap-2 text-sm hover:bg-primary hover:text-primary-foreground transition-all duration-300 cursor-pointer"
          onClick={() => {
            iframeRef.current?.requestFullscreen();
          }}
        >
          <Fullscreen />
          Full Screen
        </button>
      )}
    </div>
  );
}
