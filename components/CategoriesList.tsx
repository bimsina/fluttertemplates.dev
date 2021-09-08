import React, { useEffect } from "react";
import { Chip, Grid } from "@material-ui/core";

interface CategoriesListProps {
  categories: string[];
  selected: string;
  onChange?: (id: string) => void;
  isDetailPage?: boolean;
  showAll: boolean;
}

export default function CategoriesList(props: CategoriesListProps) {
  return (
    <div className="categories-list">
      {props.showAll && (
        <Chip
          label="#all"
          component="a"
          color={props.selected === "all" ? "primary" : "default"}
          variant="default"
          clickable
          style={{
            margin: "4px",
          }}
          key="all"
          onClick={() => {
            if (props.onChange) {
              props.onChange("all");
            }
          }}
        />
      )}
      {props.categories.map((val) => {
        return (
          <Chip
            label={`#${val}`}
            component="a"
            color={
              props.selected.toLowerCase() === val.toLowerCase()
                ? "primary"
                : "default"
            }
            variant="default"
            clickable
            style={{
              margin: "4px",
            }}
            key={val}
            href={props.onChange ? undefined : `/templates?catId=${val}`}
            onClick={() => {
              if (props.onChange) {
                props.onChange(val);
              }
            }}
          />
        );
      })}
    </div>
  );
}
