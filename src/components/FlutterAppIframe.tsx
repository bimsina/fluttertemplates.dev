import { Fullscreen } from "lucide-react";
import { useTheme } from "../hooks/useTheme";
import { useRef, useState, useEffect } from "react";

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
  const [isIOS, setIsIOS] = useState(false);
  const iframeRef = useRef<HTMLIFrameElement>(null);

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
    <div className="flex flex-col items-center justify-center gap-2">
      <div className={className}>
        <iframe
          src={url}
          width="100%"
          height="100%"
          ref={iframeRef}
          allow="fullscreen"
          allowFullScreen
        ></iframe>
      </div>
      {enableShowFullScreenButton && (
        <button
          className="border-primary text-primary hover:bg-primary hover:text-primary-foreground flex cursor-pointer items-center gap-2 rounded-md border px-4 py-2 text-sm transition-all duration-300"
          onClick={requestFullscreen}
        >
          <Fullscreen />
          Full Screen
        </button>
      )}
    </div>
  );
}
