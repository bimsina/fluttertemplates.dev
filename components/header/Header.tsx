import {
  Button,
  IconButton,
  Typography,
  Container,
  AppBar,
  Toolbar,
  useTheme,
  useMediaQuery,
  Drawer,
  ListItem,
  Grid,
  Box,
} from "@material-ui/core";
import {
  Brightness7Rounded,
  MenuRounded,
  NightsStayRounded,
} from "@material-ui/icons";
import { GITHUB_LINK } from "../../constants";
import React, { useState } from "react";
import CustomFlatButton from "../buttons/FlatButton";

interface HeaderProps {
  isDarkMode: boolean;
  onThemeChange: VoidFunction;
}
export default function Header(props: HeaderProps) {
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);

  const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const [drawer, setDrawer] = useState(false);

  const theme = useTheme();
  const _isNotMobile = useMediaQuery(theme.breakpoints.up("sm"));

  const toggleDrawer = () => () => {
    setDrawer(!drawer);
  };

  return (
    <AppBar position="sticky" color="primary" elevation={0}>
      <Toolbar>
        <Container maxWidth="lg">
          <Grid
            container
            spacing={3}
            direction="row"
            justifyContent="center"
            alignItems="center"
          >
            <Box display="flex" flexGrow={_isNotMobile ? 0 : 1}>
              <Button href="/">
                <img
                  src="/favicon.svg"
                  alt="Flutter UI Templates Logo"
                  style={{
                    height: "2.5rem",
                    width: "2.5rem",
                    marginRight: "0.5rem",
                  }}
                />
                {_isNotMobile && (
                  <Grid container>
                    <Typography
                      style={{
                        color: theme.palette.secondary.main,
                        textTransform: "capitalize",
                        maxLines: 1,
                        fontSize: "1.3rem",
                        fontWeight: "bold",
                        marginLeft: "4px",
                      }}
                    >
                      Flutter
                    </Typography>

                    <Typography
                      color="inherit"
                      style={{
                        textTransform: "capitalize",
                        maxLines: 1,
                        fontSize: "1.3rem",
                        fontWeight: "bold",
                        marginLeft: "4px",
                      }}
                    >
                      Templates
                    </Typography>
                  </Grid>
                )}
              </Button>
            </Box>

            {_isNotMobile && (
              <Box display="flex" flexGrow={1}>
                <Grid
                  container
                  direction="row"
                  justifyContent="flex-end"
                  alignItems="center"
                >
                  {commonNav.map((item, index) => (
                    <Grid item key={`nav_${index}`}>
                      {item}
                    </Grid>
                  ))}
                </Grid>
              </Box>
            )}

            <Grid item>
              <IconButton
                aria-label="Theme Toggle Button"
                onClick={props.onThemeChange}
              >
                {props.isDarkMode ? (
                  <Brightness7Rounded />
                ) : (
                  <NightsStayRounded />
                )}
              </IconButton>
            </Grid>

            {!_isNotMobile && (
              <Grid item>{displayMobile(drawer, toggleDrawer())}</Grid>
            )}
          </Grid>
        </Container>
      </Toolbar>
    </AppBar>
    // </div>
  );
}

const displayMobile = (isOpen: boolean, onToggle: any) => {
  return (
    <div>
      <IconButton onClick={onToggle}>
        <MenuRounded />
      </IconButton>
      <Drawer open={isOpen} anchor="bottom" onClose={onToggle}>
        {commonNav.map((item) => (
          <ListItem
            key={item.props.href}
            style={{
              padding: 16,
              justifyContent: "center",
            }}
          >
            {item}
          </ListItem>
        ))}
      </Drawer>
    </div>
  );
};

const commonNav: any[] = [
  <CustomFlatButton href="/widgets" label="Widgets" />,
  <CustomFlatButton href="/templates" label="Templates" />,
  <CustomFlatButton href={GITHUB_LINK} label="GitHub" />,
];
