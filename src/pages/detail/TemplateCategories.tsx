import React, { useEffect } from "react";
import { Chip, Grid } from "@material-ui/core";
import Category from "../../models/Category";
import { Skeleton } from "@material-ui/lab";
import { fetchCategories } from "../../utils/fetchcategories";
import "../../App.css";

interface TemplateCategoriesListProps {
  categories: string[];
}

export default function TemplateCategories(props: TemplateCategoriesListProps) {
  const [categories, setCategories] = React.useState<Category[]>([]);
  const [isLoading, setIsLoading] = React.useState(true);

  useEffect(() => {
    _fetchCategories();
  }, []);

  async function _fetchCategories() {
    setIsLoading(true);

    let _categories = await fetchCategories();
    _categories = _categories.filter((element) => {
      if (props.categories.includes(element.id)) {
        return true;
      } else return false;
    });
    setCategories(_categories);
    setIsLoading(false);
  }

  if (!isLoading)
    return (
      <div
        className="categories-list"
        style={{
          marginBottom: "-40px",
        }}
      >
        {categories.map((val) => {
          return (
            <Chip
              label={val.title}
              component="a"
              variant="default"
              clickable
              style={{
                margin: "4px",
              }}
              key={val.id}
              onClick={() => {
                // props.onChange(val.id);
              }}
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
