import fs from "fs";
import path from "path";

export default async function getTemplatePaths() {
  const files = fs.readdirSync(path.join("templates"));

  const paths = files.map((file) => ({
    params: { id: file.replace(".md", "") },
  }));

  return {
    paths,
    fallback: false,
  };
}
