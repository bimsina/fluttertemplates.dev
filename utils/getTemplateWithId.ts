import fs from "fs";
import matter from "gray-matter";
import path from "path";
import TemplateCardProps from "@/models/template_card";
import TemplateFrontmatterProps from "@/models/template_frontmatter";

export interface StaticProps {
  params: {
    id: string;
  };
}

export async function getTemplateListWithId(props: StaticProps) {
  const markDownWithMeta = fs.readFileSync(
    path.join("templates", `${props.params.id}.md`),
    "utf8"
  );
  const { data: frontmatter, content } = matter(markDownWithMeta);

  const _returnData: TemplateCardProps = {
    frontmatter: frontmatter as TemplateFrontmatterProps,
    id: props.params.id,
    content: content,
  };
  return {
    props: _returnData,
  };
}
