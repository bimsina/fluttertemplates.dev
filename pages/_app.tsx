import Header from "@/components/Header";
import Footer from "@/components/Footer";
import "@/styles/globals.css";
import {
  Container,
  createTheme,
  CssBaseline,
  ThemeProvider,
} from "@material-ui/core";
import { Brightness7Rounded, NightsStayRounded } from "@material-ui/icons";
import type { AppProps } from "next/app";
import React, { useEffect, useMemo, useState } from "react";

function MyApp({ Component, pageProps }: AppProps) {
  const [darkMode, setDarkMode] = useState<boolean>(false);
  const icon = darkMode ? <Brightness7Rounded /> : <NightsStayRounded />;

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
            main: "#24292e",
          },
          secondary: {
            main: darkMode ? "#2ca44f" : "#2ca44f",
          },
          background: {
            default: darkMode ? "#000409" : "#f6f8fa",
            paper: darkMode ? "#0d1117" : "#ffffff",
          },
        },
        typography: {
          fontFamily: ["Ubuntu"].join(","),
        },
      }),
    [darkMode]
  );

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />

      <Header
        icon={icon}
        onChange={() => {
          localStorage.setItem("dark", (!darkMode).toString());
          setDarkMode(!darkMode);
        }}
      />
      <Container
        maxWidth="lg"
        style={{
          minHeight: "95vh",
        }}
      >
        <Component {...pageProps} />
      </Container>

      <Footer />
    </ThemeProvider>
  );
}
export default MyApp;
