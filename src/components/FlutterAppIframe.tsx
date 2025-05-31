import { useTheme } from "../hooks/useTheme";

export default function FlutterAppIframe({
  app = "core",
  theme: initialTheme,
  path,
  className,
  skipUrlFormatting = false,
}: {
  app?: string;
  theme?: "light" | "dark";
  path?: string;
  className?: string;
  skipUrlFormatting?: boolean;
}) {
  const theme = useTheme(initialTheme);

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
    <iframe src={url} width="100%" height="100%" className={className}></iframe>
  );
}
