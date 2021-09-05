import React from "react";
import TemplateDetailPage from "@/components/TemplateDetailPage";
import TemplateCardProps from "@/models/template_card";
import getTemplatePaths from "@/utils/getTemplatePaths";
import { getTemplateListWithId, StaticProps } from "@/utils/getTemplateWithId";

export default function TemplatePage(props: TemplateCardProps) {
  return (
    <>
      <TemplateDetailPage {...props.frontmatter} />
    </>
  );
}

export async function getStaticPaths() {
  const _data = await getTemplatePaths();
  return _data;
}

export async function getStaticProps(props: StaticProps) {
  const _data = await getTemplateListWithId(props);
  return _data;
}
