import TemplateCardProps from "@/models/template_card";
import React from "react";

export default function TemplateCard(props: TemplateCardProps) {
  return (
    <a href={`/templates/${props.id}`} className="cursor-pointer">
      <div className=" rounded-lg border-2 border-transparent bg-card hover:border-primary dark:bg-darkCard">
        <img
          className="rounded-t-lg"
          src={props.frontmatter.image}
          alt={props.frontmatter.title}
        />

        <h5 className="text-md p-4 tracking-tight text-gray-900 dark:text-gray-200">
          {props.frontmatter.title}
        </h5>
      </div>
    </a>
  );
}
