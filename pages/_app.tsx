import Footer from "@/components/Footer";
import Header from "@/components/Header";
import "@/styles/globals.css";
import {
  CircularProgress,
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
            main: darkMode ? "#ffffff" : "#030303",
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
