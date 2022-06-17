function initTheme() {
  var theme = localStorage.getItem("theme") || "light";
  console.log("theme", theme);
  if (theme === "dark") {
    console.log("dark theme");
    document.querySelector("html").classList.add("dark");
    document.querySelector("html").style.setProperty("color-scheme", "dark");
  }
}

console.log("Fetching theme");
initTheme();
