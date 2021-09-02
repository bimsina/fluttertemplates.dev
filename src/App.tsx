import React, { useEffect, useMemo, useState } from "react";
import {
  unstable_createMuiStrictModeTheme as createTheme,
  CssBaseline,
  ThemeProvider,
} from "@material-ui/core";

import { BrowserRouter as Router, Switch, Route, Link } from "react-router-dom";
import Navbar from "./components/navbar/Navbar";
import { Container } from "@material-ui/core";
import DetailPage from "./pages/detail/DetailPage";
import LoginPage from "./pages/login/LoginPage";
import { MdBrightness2, MdBrightness7 } from "react-icons/md";
import HomePage from "./pages/home/HomePage";
import PageNotFoundPage from "./pages/404/404Page";
import AdminPage from "./pages/admin/AdminPage";
import AdminCategories from "./pages/admin/AdminCategories";
import AdminAddTemplates from "./pages/admin/AdminAddtemplates";

function App() {
  const [darkMode, setDarkMode] = useState(true);
  const icon = darkMode ? <MdBrightness7 /> : <MdBrightness2 />;

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

      <Router>
        <Navbar
          icon={icon}
          onChange={() => {
            localStorage.setItem("dark", (!darkMode).toString());
            setDarkMode(!darkMode);
          }}
        />
        <Container maxWidth="lg">
          <Switch>
            <Route path="/detail/:id" exact>
              <DetailPage />
            </Route>
            <Route path="/login" exact>
              <LoginPage />
            </Route>

            <Route path="/admin" exact>
              <AdminPage />
            </Route>

            <Route path="/addCategories" exact>
              <AdminCategories />
            </Route>

            <Route path="/addTemplates" exact>
              <AdminAddTemplates />
            </Route>

            <Route path="/" exact>
              <HomePage />
            </Route>

            <Route>
              <PageNotFoundPage />
            </Route>
          </Switch>
        </Container>
      </Router>
    </ThemeProvider>
  );
}

export default App;
