import Link from "next/link";
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
    <div className="mb-4 flex flex-row flex-wrap overflow-x-auto text-sm ">
      {props.showAll && (
        <button
          className={`my-1 ml-2 cursor-pointer rounded-3xl border px-4 py-2 text-xs transition-all md:ml-0 ${
            props.selected === "all"
              ? "border-primary bg-primary text-background"
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
          <Link
            className={`my-1 ml-2 cursor-pointer rounded-3xl border px-4 py-2 text-xs transition-all ${
              props.selected.toLowerCase() === val.toLowerCase()
                ? "border-primary bg-primary text-background"
                : "bg-background dark:bg-darkBackground"
            }`}
            key={val}
            href={props.onChange ? {} : { pathname: `/templates?catId=${val}` }}
            onClick={() => {
              if (props.onChange) {
                props.onChange(val);
              }
            }}
          >
            {`#${val}`}
          </Link>
        );
      })}
    </div>
  );
}
