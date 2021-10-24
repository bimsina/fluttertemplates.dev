import {
  Button,
  IconButton,
  Typography,
  Container,
  Avatar,
  Menu,
  MenuItem,
  AppBar,
  Toolbar,
} from "@material-ui/core";
import firebase from "@/firebase/clientApp";
import { useAuthState } from "react-firebase-hooks/auth";
import React from "react";

interface HeaderProps {
  icon: any;
  onChange: VoidFunction;
}
export default function Header(props: HeaderProps) {
  const [user, loading, error] = useAuthState(firebase.auth());
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);

  const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  return (
    // <div
    //   style={{
    //     background: "#01102c",
    //     height: "60px",
    //     padding: "4px",
    //   }}
    // >

    <AppBar position="static" color="primary" elevation={0}>
      <Toolbar>
        <Container maxWidth="lg">
          <div
            style={{
              display: "flex",
              height: "100%",
              justifyContent: "space-between",
            }}
          >
            <Button href="/">
              <img
                src="/favicon.svg"
                alt="Flutter UI Templates Logo"
                style={{
                  height: "2.5rem",
                  width: "2.5rem",
                }}
              />

              <Typography
                color="inherit"
                style={{
                  textTransform: "capitalize",
                  fontSize: "1.3rem",
                  fontWeight: "bold",
                  marginLeft: "4px",
                }}
              >
                Templates
              </Typography>
            </Button>

            <div
              style={{
                display: "flex",
                justifyContent: "center",
              }}
            >
              <IconButton
                aria-label="Theme Toggle Button"
                onClick={props.onChange}
              >
                {props.icon}
              </IconButton>

              {!user && !loading && (
                <Button
                  href="/login"
                  style={{
                    display: "flex",
                    textTransform: "capitalize",
                  }}
                >
                  Log In
                </Button>
              )}

              {user && (
                <div>
                  <IconButton onClick={handleClick}>
                    <Avatar
                      style={{
                        width: "2rem",
                        height: "2rem",
                      }}
                      alt={user.displayName ?? "Profile Image"}
                      src={user.photoURL ?? ""}
                    />
                  </IconButton>
                  <Menu
                    id="simple-menu"
                    anchorEl={anchorEl}
                    keepMounted
                    open={Boolean(anchorEl)}
                    onClose={handleClose}
                    style={{
                      marginTop: "2rem",
                    }}
                  >
                    <MenuItem
                      onClick={() => {
                        firebase.auth().signOut();
                        handleClose();
                      }}
                    >
                      Logout
                    </MenuItem>
                  </Menu>
                </div>
              )}
            </div>
          </div>
        </Container>
      </Toolbar>
    </AppBar>
    // </div>
  );
}
