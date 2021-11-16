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
            main: darkMode ? "#161b22" : "#ffffff",
          },
          secondary: {
            main: darkMode ? "#0468d7" : "#0468d7",
          },
          background: {
            default: darkMode ? "#161b22" : "#ffffff",
            paper: darkMode ? "#0d1117" : "#f1f3f4",
          },
        },
        typography: {
          fontFamily: ["Ubuntu"].join(","),
        },
        overrides: {
          MuiTab: {
            wrapper: {
              flexDirection: "row",
            },
          },
          // MuiCssBaseline: {
          //   "@global": {
          //     "*": {
          //       "scrollbar-width": "thick",
          //     },
          //     "*::-webkit-scrollbar": {
          //       width: "4px",
          //       height: "4px",
          //     },
          //     "*::-webkit-scrollbar-thumb": {
          //       backgroundColor: "yellow",
          //       outline: "0px",
          //     },
          //   },
          // },
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
