import fs from "fs";
import matter from "gray-matter";
import path from "path";

export default async function getTemplatesList() {
  // get files from directory
  const files = fs.readdirSync(path.join("templates"));

  // Get slug and content from files
  const templates = files.map((fileName) => {
    const id = fileName.replace(".md", "");

    // Get frontmatter
    const markDownWithMeta = fs.readFileSync(
      path.join("templates", fileName),
      "utf-8",
    );
    const { data: frontmatter } = matter(markDownWithMeta);
    return { id, frontmatter };
  });

  return {
    props: {
      templates,
    },
  };
}
