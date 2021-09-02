import React, { useEffect } from "react";
import { Chip, Grid } from "@material-ui/core";
import Category from "../../models/Category";
import firebase from "../../firebase/clientApp";
import { Skeleton } from "@material-ui/lab";
import { fetchCategories } from "../../utils/fetchcategories";

export default function CategoriesList() {
  const [categories, setCategories] = React.useState<Category[]>([]);
  const [isLoading, setIsLoading] = React.useState(true);

  useEffect(() => {
    _fetchCategories();
  }, []);

  async function _fetchCategories() {
    setIsLoading(true);

    const _categories = await fetchCategories();
    setCategories(_categories);
    setIsLoading(false);
  }

  if (!isLoading)
    return (
      <div
        style={{
          display: "flex",
          flexDirection: "row",
          marginTop: "0.5rem",
          marginBottom: "1rem",
        }}
      >
        {categories.map((val) => {
          return (
            <Chip
              label={val.title}
              component="a"
              // color={nums.indexOf(val) === 0 ? "primary" : "default"}
              variant="default"
              clickable
              style={{
                margin: "4px",
              }}
              key={val.id}
            />
          );
        })}
      </div>
    );
  else
    return (
      <Grid
        container
        spacing={1}
        style={{
          marginTop: "0.5rem",
          marginBottom: "1rem",
        }}
      >
        {[1, 2, 3].map((val) => {
          return (
            <Grid item key={val.toString()}>
              <Skeleton
                variant="rect"
                width={120}
                height={30}
                style={{
                  borderRadius: "20px",
                }}
              />
            </Grid>
          );
        })}
      </Grid>
    );
}
