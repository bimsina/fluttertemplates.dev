import {
  AppBar,
  Button,
  IconButton,
  Toolbar,
  Typography,
  Grid,
  Container,
  CircularProgress,
  Menu,
  MenuItem,
} from "@material-ui/core";
import React from "react";
import Logo from "../../favicon.svg";
import CustomButton from "../custom_button";
// Import useAuthStateHook
import { useAuthState } from "react-firebase-hooks/auth";
import firebase from "../../firebase/clientApp";
import { Avatar } from "@material-ui/core";

interface Navbarinterface {
  icon: any;
  onChange: VoidFunction;
}

function Navbar(props: Navbarinterface) {
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
                      src={Logo}
                      style={{
                        height: "2.5rem",
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

            {loading && <CircularProgress />}

            {user && (
              <div>
                <IconButton onClick={handleClick}>
                  <Avatar alt="Profile-image" src={user.photoURL ?? ""} />
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

export default Navbar;
