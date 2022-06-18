function initTheme() {
  var theme = localStorage.getItem("theme");
  console.log(theme);
  if (
    (theme === null || theme === "system") &&
    window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: dark)").matches
  ) {
    theme = "dark";
  } else {
    theme = "light";
  }
  console.log("theme", theme);
  if (theme === "dark") {
    console.log("dark theme");
    document.querySelector("html").classList.add("dark");
    document.querySelector("html").style.setProperty("color-scheme", "dark");
  }
}

console.log("Fetching theme");
initTheme();
