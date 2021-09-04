import Head from "next/head";
import TemplateCard from "../../components/TemplateCard";
import React from "react";
import { Typography, Grid, Container } from "@material-ui/core";
import CustomButton from "../../components/custom_button";
import TemplateCardProps from "../../models/template_card";
import getTemplatesList from "../../utils/getTemplatesList";
import TemplatesGrid from "../../components/TemplatesGrid";
import HomePageHead from "../../head/HomePageHead";

export default function TemplatesList({
  templates,
}: {
  templates: TemplateCardProps[];
}) {
  return (
    <div>
      <HomePageHead />

      <TemplatesGrid templates={templates} limit={false} />
    </div>
  );

  function reduceTemplates(templates: TemplateCardProps[]): string[] {
    let _return: string[] = [];
    templates.forEach((template: TemplateCardProps) => {
      _return.push(...template.frontmatter.categories);
    });
    return Array.from(new Set(_return));
  }
}

export async function getStaticProps() {
  const _data = getTemplatesList();
  return _data;
}
