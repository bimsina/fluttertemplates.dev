import Link from "next/link";
import {
  AppBar,
  Button,
  IconButton,
  Toolbar,
  Typography,
  Grid,
  Container,
  CircularProgress,
  Avatar,
  Menu,
  MenuItem,
} from "@material-ui/core";
import firebase from "@/firebase/clientApp";
import { useAuthState } from "react-firebase-hooks/auth";
import React from "react";
import CustomButton from "@/components/custom_button";
import { AccountCircleRounded } from "@material-ui/icons";

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
    <div
      style={{
        background: "#1b1921",
      }}
    >
      <AppBar position="static" color="transparent" elevation={0}>
        <Container maxWidth="lg">
          <Toolbar>
            <div
              style={{
                flexGrow: 1,
              }}
            >
              <Button
                href="/"
                style={{
                  marginTop: "8px",
                }}
              >
                <Grid container alignItems="center">
                  <Grid item>
                    <img
                      src="/favicon.svg"
                      alt="Flutter UI Templates Logo"
                      style={{
                        height: "2.5rem",
                        width: "auto",
                      }}
                    />
                  </Grid>
                  <Grid item>
                    <Typography
                      color="inherit"
                      style={{
                        textTransform: "capitalize",
                        fontSize: "1.3rem",
                        fontWeight: "bold",
                        marginLeft: "4px",
                        color: "white",
                      }}
                    >
                      Templates
                    </Typography>
                  </Grid>
                </Grid>
              </Button>
            </div>

            <IconButton
              onClick={props.onChange}
              style={{
                color: "white",
              }}
            >
              {props.icon}
            </IconButton>

            {!user && !loading && (
              <CustomButton
                href="/login"
                style={{
                  color: "white",
                }}
              >
                Log In
              </CustomButton>
            )}

            {loading && (
              <AccountCircleRounded
                style={{
                  color: "white",
                }}
              />
            )}

            {user && (
              <div>
                <IconButton onClick={handleClick}>
                  <Avatar
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
          </Toolbar>
        </Container>
      </AppBar>
    </div>
  );
}
