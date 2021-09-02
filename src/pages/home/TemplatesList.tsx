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
import PageNotFoundImage from "../../assets/404.svg";

import Product from "../../models/Product";

export default function TemplatesList() {
  // const [snapshot, loading, error] = useCollectionOnce(
  //   firebase.firestore().collection("templates")
  // );
  const [templates, setTemplates] = React.useState<Product[]>([]);
  const [selectedcat, setSelectedCat] = React.useState("all");
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    _fetchtemplates();
  }, [selectedcat]);

  function _fetchtemplates() {
    console.log("fetching");
    setLoading(true);
    let _collection = firebase.firestore().collection("templates");
    if (selectedcat !== "all") {
      _collection
        .where("categories", "array-contains", selectedcat)
        .get()
        .then((snap) => {
          console.log(snap);
          setLoading(false);

          let _prods: Product[] = [];
          snap.docs.forEach((doc) => {
            const _single = doc.data() as Product;
            _single.id = doc.id;
            _prods.push(_single);
          });
          setTemplates(_prods);
        });
    } else {
      _collection.get().then((snap) => {
        setLoading(false);
        let _prods: Product[] = [];
        snap.docs.forEach((doc) => {
          const _single = doc.data() as Product;
          _single.id = doc.id;
          _prods.push(_single);
        });

        setTemplates(_prods);
      });
    }
  }

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

      <CategoriesList
        selectedId={selectedcat}
        onChange={(val) => {
          setSelectedCat(val);
        }}
      />

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
          {(templates.length ?? 0) === 0 ? (
            <Grid
              container
              direction="column"
              justifyContent="center"
              alignItems="center"
              spacing={4}
              style={{
                height: "40vh",
                width: "100%",
              }}
            >
              <Grid item>
                <img
                  src={PageNotFoundImage}
                  style={{
                    height: "25vh",
                  }}
                />
              </Grid>
              <Grid item>
                <Typography>No templates found</Typography>
              </Grid>
            </Grid>
          ) : (
            templates.map((val) => {
              return (
                <Grid item md={3} xs={12} sm={6} key={val.id}>
                  <a
                    href={`/detail/${val.id}`}
                    style={{
                      color: "transparent",
                    }}
                  >
                    <Card
                      elevation={0}
                      style={{
                        margin: "16px",
                      }}
                    >
                      <CardActionArea>
                        <CardMedia
                          image={
                            val?.imageUrl ??
                            "https://www.instamobile.io/wp-content/uploads/2021/06/taxi-app-react-native.png"
                          }
                          title={val.toString()}
                          style={{
                            height: "10rem",
                          }}
                        />
                        <CardContent>
                          <Typography gutterBottom variant="h6" component="h2">
                            {val?.title ?? "Title"}
                          </Typography>
                        </CardContent>
                      </CardActionArea>
                    </Card>
                  </a>
                </Grid>
              );
            })
          )}
        </Grid>
      )}
    </div>
  );
}
