export interface NestedFolder {
  type: "file" | "folder";
  id: string;
  path: string;
  matter: MatterData;
  files: NestedFolder[];
}

export interface MatterData {
  title: string;
  image?: string;
  description?: string;
  rawCodeUrl?: string;
  demoUrl?: string;
  codeUrl?: string;
  packages?: string[];
}
