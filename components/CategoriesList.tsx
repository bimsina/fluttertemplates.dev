import React, { useEffect } from "react";
import { Chip, Grid } from "@material-ui/core";

interface CategoriesListProps {
  categories: string[];
  selected: string;
  onChange: (id: string) => void;
}

export default function CategoriesList(props: CategoriesListProps) {
  return (
    <div className="categories-list">
      <Chip
        label="All"
        component="a"
        color={props.selected === "all" ? "primary" : "default"}
        variant="default"
        clickable
        style={{
          margin: "4px",
        }}
        key="all"
        onClick={() => {
          props.onChange("all");
        }}
      />
      {props.categories.map((val) => {
        return (
          <Chip
            label={val}
            component="a"
            color={props.selected === val ? "primary" : "default"}
            variant="default"
            clickable
            style={{
              margin: "4px",
            }}
            key={val}
            onClick={() => {
              props.onChange(val);
            }}
          />
        );
      })}
    </div>
  );
}
