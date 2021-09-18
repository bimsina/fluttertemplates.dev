import Header from "@/components/Header";
import Footer from "@/components/Footer";
import "@/styles/globals.css";
import {
  CircularProgress,
  Container,
  createTheme,
  CssBaseline,
  Fab,
  ThemeProvider,
  Typography,
} from "@material-ui/core";
import {
  Brightness7Rounded,
  FreeBreakfastOutlined,
  HelpOutline,
  Home,
  NightsStayRounded,
} from "@material-ui/icons";
import type { AppProps } from "next/app";
import React, { useEffect, useMemo, useState } from "react";

function MyApp({ Component, pageProps }: AppProps) {
  const [darkMode, setDarkMode] = useState<boolean>(true);
  const icon = darkMode ? <Brightness7Rounded /> : <NightsStayRounded />;

  useEffect(() => {
    // Remove the server-side injected CSS.
    const jssStyles = document.querySelector("#jss-server-side");
    if (jssStyles) {
      jssStyles.parentElement?.removeChild(jssStyles);
    }

    const _item = localStorage.getItem("dark") ?? "true";
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
          background: {
            default: darkMode ? "#1c1e1f" : "#ffffff",
            paper: darkMode ? "#2b2e35" : "#f5f5f5",
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
      <a
        target="_blank"
        rel="noopener noreferrer"
        className="fab"
        href="https://www.buymeacoffee.com/bimsina"
      >
        <FreeBreakfastOutlined />
        <Typography
          style={{
            marginLeft: "4px",
            fontWeight: "bold",
          }}
        >
          Donate
        </Typography>
      </a>

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
