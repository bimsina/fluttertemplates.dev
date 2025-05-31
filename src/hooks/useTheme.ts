import { useState, useEffect } from "react";

export function useTheme(initialTheme?: "light" | "dark") {
  const [theme, setTheme] = useState<"light" | "dark">(initialTheme ?? "light");

  useEffect(() => {
    const getThemePreference = () => {
      if (
        typeof localStorage !== "undefined" &&
        localStorage.getItem("theme")
      ) {
        return localStorage.getItem("theme") as "light" | "dark";
      }
      return window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light";
    };

    // Set initial theme
    setTheme(getThemePreference());

    // Listen for theme changes
    const observer = new MutationObserver(() => {
      const isDark = document.documentElement.classList.contains("dark");
      setTheme(isDark ? "dark" : "light");
    });

    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class"],
    });

    return () => observer.disconnect();
  }, []);

  return theme;
}
