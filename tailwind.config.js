const colors = require("tailwindcss/colors");

module.exports = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    colors: {
      blue: colors.fuchsia,
      gray: colors.gray,
      white: colors.white,
      green: colors.green,
      purple: colors.purple,
      black: colors.black,
      transparent: colors.transparent,
      primary: "#1f27cf",
      primaryLight: "#e2e4f4",
      secondary: "#0468d7",
      background: "#ffffff",
      card: "#f1f3f4",
    },
    extend: {
      aspectRatio: {
        phone: "9/16",
      },
    },
  },
  plugins: [],
};
