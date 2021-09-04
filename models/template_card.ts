import TemplateFrontmatterProps from "./template_frontmatter";

export default interface TemplateCardProps {
  id: string;
  frontmatter: TemplateFrontmatterProps;
  allCategories?: string[];
}
