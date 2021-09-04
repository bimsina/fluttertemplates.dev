import "../styles/globals.css";
import type { AppProps } from "next/app";
import Header from "../components/Header";
import { useEffect, useMemo, useState } from "react";
import {
  createTheme,
  Container,
  ThemeProvider,
  CssBaseline,
} from "@material-ui/core";
import { Brightness5Rounded, NightsStayRounded } from "@material-ui/icons";

function MyApp({ Component, pageProps }: AppProps) {
  const [darkMode, setDarkMode] = useState(true);
  const icon = darkMode ? <Brightness5Rounded /> : <NightsStayRounded />;

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
      <Container maxWidth="lg">
        <Component {...pageProps} />
      </Container>
    </ThemeProvider>
  );
}
export default MyApp;
