import React, { useEffect, useState } from "react";
import { CircularProgress, Grid } from "@material-ui/core";
import { useCollectionOnce } from "react-firebase-hooks/firestore";
import firebase from "../../firebase/clientApp";
import "firebase/auth";
import "firebase/firestore";
import { Redirect, useHistory } from "react-router-dom";
import { checkifIsAdmin } from "../../utils/isAdmin";

export interface AdminWrapperProps {
  children: JSX.Element;
}

const adminWrapper = (props: AdminWrapperProps) => {
  const [isLoading, setIsLoading] = useState(true);
  const [isAdmin, setIsAdmin] = useState(false);

  const history = useHistory();

  useEffect(() => {
    fetchUser();
  }, []);

  function fetchUser() {
    firebase.auth().onAuthStateChanged((_currentUser) => {
      if (_currentUser) {
        checkAdmin(_currentUser.uid);
      } else {
        history.push("/");
      }
    });
  }

  async function checkAdmin(id: string) {
    const _isAdmin = await checkifIsAdmin(id);

    if (_isAdmin) {
      setIsLoading(false);
      setIsAdmin(true);
    } else {
      history.push("/");
    }
  }

  if (!isLoading && isAdmin) return props.children;
  else if (!isLoading && !isAdmin) return <div>Not admin</div>;
  else
    return (
      <Grid
        container
        direction="column"
        justifyContent="center"
        alignItems="center"
        spacing={2}
        style={{
          height: "90vh",
          width: "100%",
        }}
      >
        <CircularProgress />
      </Grid>
    );
};

export default adminWrapper;
