import Header from "@/components/header/Header";
import Footer from "@/components/footer/Footer";

import "@/styles/globals.css";

import type { AppProps } from "next/app";
import React, { useEffect, useMemo, useState } from "react";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";
import { createTheme, CssBaseline, Theme, ThemeProvider } from "@mui/material";

function MyApp({ Component, pageProps }: AppProps) {
  const [darkMode, setDarkMode] = useState<boolean>(false);

  useEffect(() => {
    const _item = localStorage.getItem("darkMode") ?? "false";
    setDarkMode(JSON.parse(_item));

    // Remove the server-side injected CSS.
    const jssStyles = document.querySelector("#jss-server-side");
    if (jssStyles) {
      jssStyles.parentElement?.removeChild(jssStyles);
    }
  }, []);

  const theme: Theme = useMemo(
    () =>
      createTheme({
        palette: {
          mode: darkMode ? "dark" : "light",
          primary: {
            main: darkMode ? "#222432" : "#ffffff",
          },
          secondary: {
            main: darkMode ? "#0468d7" : "#0468d7",
          },
          background: {
            default: darkMode ? "#222432" : "#ffffff",
            paper: darkMode ? "#22293d" : "#f1f3f4",
          },
        },
      }),
    [darkMode]
  );

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline enableColorScheme />

      <Header
        isDarkMode={darkMode}
        onThemeChange={() => {
          localStorage.setItem("darkMode", (!darkMode).toString());
          setDarkMode(!darkMode);
        }}
      />
      <div
        style={{
          minHeight: "80vh",
        }}
      >
        <Component {...pageProps} />
      </div>

      <SubmitProposalSection />

      <Footer />
    </ThemeProvider>
  );
}
export default MyApp;
