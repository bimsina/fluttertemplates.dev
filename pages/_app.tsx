import Footer from "@/components/Footer";
import Header from "@/components/Header";
import "@/styles/globals.css";
import {
  CircularProgress,
  Container,
  createTheme,
  CssBaseline,
  Grid,
  ThemeProvider,
} from "@material-ui/core";
import { Brightness7Rounded, NightsStayRounded } from "@material-ui/icons";
import type { AppProps } from "next/app";
import React, { useEffect, useMemo, useState } from "react";

function MyApp({ Component, pageProps }: AppProps) {
  const [darkMode, setDarkMode] = useState<boolean | undefined>(undefined);
  const icon =
    darkMode == undefined || darkMode ? (
      <Brightness7Rounded />
    ) : (
      <NightsStayRounded />
    );

  useEffect(() => {
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

  if (darkMode == undefined)
    return (
      <Grid
        container
        direction="column"
        justifyContent="center"
        alignItems="center"
        style={{
          width: "100%",
          height: "100vh",
        }}
      >
        <Grid item>
          <CircularProgress size="1.5rem" thickness={8} />
        </Grid>
      </Grid>
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
