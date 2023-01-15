import React from "react";
import TemplateCardProps from "@/models/template_card";
import getTemplatePaths from "@/utils/getTemplatePaths";
import { getTemplateListWithId, StaticProps } from "@/utils/getTemplateWithId";
import TemplateDetailPage from "@/components/TemplateDetailPage";
import Footer from "@/components/footer/Footer";

export default function TemplatePage(props: TemplateCardProps) {
  return (
    <>
      <TemplateDetailPage {...props} />

      <Footer />
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
