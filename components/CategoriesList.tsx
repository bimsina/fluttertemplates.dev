import React, { useEffect } from "react";

interface CategoriesListProps {
  categories: string[];
  selected: string;
  onChange?: (id: string) => void;
  isDetailPage?: boolean;
  showAll: boolean;
}

export default function CategoriesList(props: CategoriesListProps) {
  return (
    <div className="text-sm mb-4 overflow-x-auto flex-wrap flex flex-row ">
      {props.showAll && (
        <button
          className={`border rounded-3xl px-4 py-2 my-1 text-xs cursor-pointer ml-2 md:ml-0 transition-all ${
            props.selected === "all"
              ? "bg-primary text-background border-primary"
              : "bg-background dark:bg-darkBackground"
          }`}
          key="all"
          onClick={() => {
            if (props.onChange) {
              props.onChange("all");
            }
          }}
        >
          #all
        </button>
      )}
      {props.categories.map((val) => {
        return (
          <a
            className={`border rounded-3xl px-4 py-2 ml-2 my-1 text-xs cursor-pointer transition-all ${
              props.selected.toLowerCase() === val.toLowerCase()
                ? "bg-primary text-background border-primary"
                : "bg-background dark:bg-darkBackground"
            }`}
            key={val}
            href={props.onChange ? undefined : `/templates?catId=${val}`}
            onClick={() => {
              if (props.onChange) {
                props.onChange(val);
              }
            }}
          >
            {`#${val}`}
          </a>
        );
      })}
    </div>
  );
}
