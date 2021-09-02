import React from "react";
import {
  Card,
  CardActionArea,
  CardContent,
  CardMedia,
  Grid,
} from "@material-ui/core";

import { Typography } from "@material-ui/core";
import CategoriesList from "./CategoriesList";
import { useCollectionOnce } from "react-firebase-hooks/firestore";
import firebase from "../../firebase/clientApp";
import { Skeleton } from "@material-ui/lab";

export default function TemplatesList() {
  const [snapshot, loading, error] = useCollectionOnce(
    firebase.firestore().collection("templates")
  );

  return (
    <div>
      <Typography
        variant="h5"
        style={{
          fontWeight: "bold",
        }}
      >
        All Apps
      </Typography>

      <CategoriesList />

      {loading && (
        <Grid container>
          {[0, 1, 2, 3].map((val) => {
            return (
              <Grid item md={3} xs={12} sm={6} key={val.toString()}>
                <Skeleton
                  variant="rect"
                  height="12rem"
                  style={{
                    margin: "0.8rem",
                    borderRadius: "0.5rem",
                  }}
                />
              </Grid>
            );
          })}
        </Grid>
      )}

      {!loading && (
        <Grid container>
          {snapshot?.docs.map((val) => {
            return (
              <Grid item md={3} xs={12} sm={6} key={val.id}>
                <Card
                  elevation={0}
                  style={{
                    margin: "16px",
                  }}
                >
                  <CardActionArea
                    onClick={() => (location.href = `/detail/${val.id}`)}
                  >
                    <CardMedia
                      image={
                        val?.data().imageUrl ??
                        "https://www.instamobile.io/wp-content/uploads/2021/06/taxi-app-react-native.png"
                      }
                      title={val.toString()}
                      style={{
                        height: "10rem",
                      }}
                    />
                    <CardContent>
                      <Typography gutterBottom variant="h6" component="h2">
                        {val?.data().title ?? "Title"}
                      </Typography>
                    </CardContent>
                  </CardActionArea>
                </Card>
              </Grid>
            );
          })}
        </Grid>
      )}
    </div>
  );
}
