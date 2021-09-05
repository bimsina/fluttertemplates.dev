import {
  Button,
  CircularProgress,
  Container,
  Grid,
  Paper,
} from "@material-ui/core";
import React from "react";
import CustomButton from "@/components/custom_button";
import StyledFirebaseAuth from "react-firebaseui/StyledFirebaseAuth";
import firebase from "@/firebase/clientApp";
import { useAuthState } from "react-firebase-hooks/auth";
import { Typography } from "@material-ui/core";
import HomePageHead from "@/head/HomePageHead";

const uiConfig = {
  signInSuccessUrl: "/",
  signInOptions: [
    firebase.auth.GithubAuthProvider.PROVIDER_ID,
    firebase.auth.GoogleAuthProvider.PROVIDER_ID,
  ],
};

export default function LoginPage() {
  const [user, loading, error] = useAuthState(firebase.auth());

  return (
    <>
      <HomePageHead title="Login to Flutter UI templates" />
      <Container
        maxWidth="xs"
        style={{
          height: "90vh",
          display: "flex",
          alignItems: "center",
        }}
      >
        <Paper
          elevation={0}
          style={{
            width: "100%",
            padding: "24px",
          }}
        >
          <Grid
            container
            direction="column"
            justifyContent="center"
            alignItems="center"
            spacing={2}
          >
            <Grid item>
              <img
                src="/login.svg"
                style={{
                  height: "30vh",
                  objectFit: "scale-down",
                }}
              />
            </Grid>

            <Grid item>
              {!user && !loading && (
                <StyledFirebaseAuth
                  uiConfig={uiConfig}
                  firebaseAuth={firebase.auth()}
                />
              )}
              {user && !loading && (
                <div>
                  <Grid
                    container
                    direction="column"
                    justifyContent="center"
                    alignItems="center"
                    spacing={2}
                  >
                    <Grid item>
                      <Typography>You are already logged in.</Typography>
                    </Grid>
                    <Grid item>
                      <CustomButton
                        variant="contained"
                        color="primary"
                        onClick={() => {
                          firebase.auth().signOut();
                        }}
                      >
                        Log Out
                      </CustomButton>
                    </Grid>
                  </Grid>
                </div>
              )}

              {loading && <CircularProgress />}
            </Grid>
            {/* <LoginButton
            color="#333333"
            icon={<AiFillGithub size={24} />}
            title={"Login With GitHub"}
          />

          <LoginButton
            color="#4284f4"
            icon={<AiFillGoogleCircle size={24} />}
            title={"Sign in With Google"}
          />

          <LoginButton
            color="#405dad"
            icon={<AiFillFacebook size={24} />}
            title={"Continue With Facebook"}
          /> */}
          </Grid>
        </Paper>
      </Container>
    </>
  );
}
