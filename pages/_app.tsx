import Header from "@/components/header/Header";
import Footer from "@/components/footer/Footer";

import "@/styles/globals.css";
import { createTheme, CssBaseline, ThemeProvider } from "@material-ui/core";
import type { AppProps } from "next/app";
import React, { useEffect, useMemo, useState } from "react";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";

function MyApp({ Component, pageProps }: AppProps) {
  const [darkMode, setDarkMode] = useState<boolean>(false);

  useEffect(() => {
    // Remove the server-side injected CSS.
    const jssStyles = document.querySelector("#jss-server-side");
    if (jssStyles) {
      jssStyles.parentElement?.removeChild(jssStyles);
    }

    const _item = localStorage.getItem("dark") ?? "false";
    setDarkMode(JSON.parse(_item));
  }, []);

  const theme = useMemo(
    () =>
      createTheme({
        palette: {
          type: darkMode ? "dark" : "light",
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
        typography: {
          fontFamily: "Work Sans",
        },
        overrides: {
          MuiTab: {
            wrapper: {
              flexDirection: "row",
            },
          },

          MuiCssBaseline: {
            "@global": {
              "*::-webkit-scrollbar": {
                width: "0.5em",
              },
              "*::-webkit-scrollbar-track": {
                backgroundColor: "transparent",
              },
              "*::-webkit-scrollbar-thumb": {
                borderRadius: "10px",
                backgroundColor: darkMode ? "#0468d7" : "#0468d7",
                border: "none",
              },
            },
          },
        },
      }),
    [darkMode]
  );

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />

      <Header
        isDarkMode={darkMode}
        onThemeChange={() => {
          localStorage.setItem("dark", (!darkMode).toString());
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
