import fs from "fs-extra";
import path from "path";
import matter from "gray-matter";
import { MatterData, NestedFolder } from "./models";

interface CustomPath {
  params: { id: string[] };
}

// Wrapper to flatten and return nested path list as flat array expected by next
export async function getPathList(
  folder: string,
  ogPath: string,
  pageFileCache: Record<string, string>
): Promise<CustomPath[]> {
  let nestedPaths = await getNestedPathList(folder, ogPath, pageFileCache);
  return flatten(nestedPaths).filter((x: any) => !!x);
}

// Recursivly scan the documentation folder. This includes any extra resolution magic
// such as index.md acting as the folder index
export async function getNestedPathList(
  folder: string,
  ogPath: string,
  pageFileCache: Record<string, string>
): Promise<any> {
  return (
    await Promise.all(
      (
        await fs.readdir(folder)
      ).map(async (file) => {
        const joined = path.join(folder, file);

        //  Call recursively if a directory
        if ((await fs.stat(joined)).isDirectory()) {
          return getNestedPathList(joined, ogPath, pageFileCache);
        }

        // If a content markdown is found
        if (joined.endsWith(".md")) {
          let alteredPath = joined
            .slice(folder.length + 1)
            .replace(/\.md$/, "")
            .replace(/\index$/, "");

          // In recursive depths, add folder name and trim any stray '/'
          if (folder !== ogPath) {
            alteredPath = folder.replace(ogPath, "") + "/" + alteredPath;
          }
          alteredPath = trimChar(alteredPath, "/");

          pageFileCache[alteredPath] = joined;
          return {
            params: {
              id: alteredPath.split("/"),
            },
          };
        } else {
          return null;
        }
      })
    )
  ).filter((x) => !!x);
}

export interface CustomPost {
  id: string;
  frontmatter: {
    [key: string]: any;
  };
}

export async function getPostData(id: any, fullPath: any): Promise<CustomPost> {
  const fileContents = fs.readFileSync(fullPath, "utf8");

  // Use gray-matter to parse the post metadata section

  const { data: frontmatter } = matter(fileContents);

  return {
    id,
    frontmatter,
  };
}

export async function getSortedFlatData(folder: any) {
  let fullFolderPath = path.join(process.cwd(), "/" + folder);
  // Get file names under /posts
  const pageFileCache: any = {};
  const paths = await getPathList(
    fullFolderPath,
    fullFolderPath,
    pageFileCache
  );

  const allPostsData: {
    id: string;
  }[] = paths
    .map((p) => p.params.id.join("/"))
    .map((fileName) => {
      const id = fileName;

      // Read markdown file as string
      const fullPath = pageFileCache[id];
      const fileContents = fs.readFileSync(fullPath, "utf8");

      // Use gray-matter to parse the post metadata section
      const matterResult = matter(fileContents);

      // Combine the data with the id
      return {
        id,
        ...matterResult.data,
      };
    });
  // Sort posts by date
  return allPostsData.sort((a, b) => {
    if (a.id > b.id) {
      return 1;
    } else {
      return -1;
    }
  });
}

function nestData(
  paths: any,
  pageFileCache: Record<string, string>,
  start = [""]
): NestedFolder {
  let files: NestedFolder[] = [];
  let startPath = pageFileCache[start.join("/")];

  // Remove the element start by compairing ID array
  paths = paths.filter((p: any) => {
    return (
      Array.isArray(p) ||
      !(
        p.params.id.length === start.length &&
        p.params.id.every((value: any, index: any) => value === start[index])
      )
    );
  });

  for (let path of paths) {
    if (!Array.isArray(path)) {
      let id = path.params.id.join("/");
      let fullPath = pageFileCache[id];

      // Use gray-matter to parse the post metadata section
      const fileContents = fs.readFileSync(fullPath, "utf8");
      const matterResult = matter(fileContents);
      const _matterData: MatterData = {
        title: matterResult.data.title,
        codeUrl: matterResult.data.codeUrl ?? null,
        description: matterResult.data.description ?? null,
        rawCodeUrl: matterResult.data.rawCodeUrl ?? null,
        demoUrl: matterResult.data.demoUrl ?? null,
      };

      files.push({
        type: "file",
        id: id,
        path: pageFileCache[id],
        matter: _matterData,
        files: [],
      });
    } else {
      // New start will have smallest id length
      let newStart = path.reduce((str, p) => {
        if (!Array.isArray(p)) {
          if (Array.isArray(str)) {
            return p;
          }
          return str.params.id.length < p.params.id.length ? str : p;
        }
        return str;
      }).params.id;

      files.push(nestData(path, pageFileCache, newStart));
    }
  }

  // Use gray-matter to parse the post metadata section
  const fileContents = fs.readFileSync(startPath, "utf8");
  const matterResult = matter(fileContents);
  const _matterData: MatterData = {
    title: matterResult.data.title,
    image: matterResult.data.image ?? null,
    codeUrl: matterResult.data.codeUrl ?? null,
    description: matterResult.data.description ?? null,
    rawCodeUrl: matterResult.data.rawCodeUrl ?? null,
    demoUrl: matterResult.data.demoUrl ?? null,
  };

  return {
    type: "folder",
    id: start.join("/"),
    path: startPath,
    matter: _matterData,
    files: files,
  };
}

export async function getFolderNestedData(
  folder: string
): Promise<NestedFolder> {
  let fullFolderPath = path.join(process.cwd(), "/" + folder);

  const pageFileCache = {};
  const paths = await getNestedPathList(
    fullFolderPath,
    fullFolderPath,
    pageFileCache
  );

  return nestData(paths, { ...pageFileCache });
}

// Escape special characters for use in a regular expression
var escapeRegExp = function (strToEscape: any) {
  return strToEscape.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
};

// Trim Characters at the start and the end
var trimChar = function (origString: any, charToTrim: any) {
  charToTrim = escapeRegExp(charToTrim);
  var regEx = new RegExp("^[" + charToTrim + "]+|[" + charToTrim + "]+$", "g");
  return origString.replace(regEx, "");
};

// Flattens nested arrays
function flatten(items: any) {
  const flat: any = [];

  items.forEach((item: any) => {
    if (Array.isArray(item)) {
      flat.push(...flatten(item));
    } else {
      flat.push(item);
    }
  });

  return flat;
}
