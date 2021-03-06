import TemplateCardProps from "@/models/template_card";
import React from "react";

export default function TemplateCard(props: TemplateCardProps) {
  return (
    <a href={`/templates/${props.id}`} className="cursor-pointer">
      <div className=" bg-card dark:bg-darkCard rounded-lg border-2 border-transparent hover:border-primary">
        <img
          className="rounded-t-lg"
          src={props.frontmatter.image}
          alt={props.frontmatter.title}
        />

        <h5 className="text-md tracking-tight text-gray-900 dark:text-gray-200 p-4">
          {props.frontmatter.title}
        </h5>
      </div>
    </a>
  );
}
