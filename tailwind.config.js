const colors = require("tailwindcss/colors");

module.exports = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: "class",
  theme: {
    colors: {
      blue: colors.fuchsia,
      gray: colors.gray,
      white: colors.white,
      green: colors.green,
      purple: colors.purple,
      black: colors.black,
      transparent: colors.transparent,
      primary: "#0669d7",
      primaryLight: "#e2e4f4",
      secondary: "#0468d7",
      background: "#ffffff",
      card: "#f8f9fa",
      borderColor: "#D0D0D0",
      darkBorderColor: "#303030",

      darkBackground: "#0f172b",
      darkCard: "#1e293b",
    },
    extend: {
      aspectRatio: {
        phone: "9/16",
      },
    },
  },
  plugins: [],
};
