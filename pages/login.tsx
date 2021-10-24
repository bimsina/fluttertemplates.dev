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
                src="/favicon.svg"
                alt="Flutter UI Templates Logo"
                style={{
                  height: "15vh",
                  margin: "1.5rem",
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

              {loading && <CircularProgress color="secondary" />}
            </Grid>
          </Grid>
        </Paper>
      </Container>
    </>
  );
}
