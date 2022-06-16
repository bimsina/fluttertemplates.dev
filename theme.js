(function initTheme() {
  var theme = localStorage.getItem("theme") || "light";
  if (theme === "dark") {
    console.log("dark theme");
    document.querySelector("html").classList.add("dark");
    document.querySelector("html").style.setProperty("color-scheme", "dark");
  }
})();
