import { getCollection, type CollectionEntry } from "astro:content";

type WidgetEntry = CollectionEntry<"widgets">;

interface WidgetGroup {
  title: string;
  path: string;
  items: WidgetEntry[];
  indexFile: WidgetEntry | null;
  order: number;
  children?: WidgetGroup[];
}

function groupWidgetsByPath(widgets: WidgetEntry[]): WidgetGroup[] {
  // First, separate index files from regular widgets
  const indexFiles = new Map<string, WidgetEntry>();
  const regularWidgets: WidgetEntry[] = [];

  widgets.forEach((widget) => {
    if (widget.filePath && widget.filePath.endsWith("/index.md")) {
      // This is an index file for the group with id = widget.id
      indexFiles.set(widget.id, widget);
    } else {
      regularWidgets.push(widget);
    }
  });

  // Group regular widgets by their folder path
  const groups = new Map<string, WidgetGroup>();

  regularWidgets.forEach((widget) => {
    const pathParts = widget.id.split("/");

    if (pathParts.length === 1) {
      // Root level widget
      if (!groups.has(widget.id)) {
        groups.set(widget.id, {
          title: widget.data.title,
          path: widget.id,
          items: [],
          indexFile: null,
          order: widget.data.order,
        });
      }
      groups.get(widget.id)!.items.push(widget);
    } else {
      // Nested widget - group by folder
      const groupPath = pathParts.slice(0, -1).join("/");
      const folderName = pathParts[pathParts.length - 2];

      if (!groups.has(groupPath)) {
        groups.set(groupPath, {
          title: folderName,
          path: groupPath,
          items: [],
          indexFile: null,
          order: widget.data.order,
        });
      }

      groups.get(groupPath)!.items.push(widget);
    }
  });

  // Ensure all index files are represented as groups, even if they have no regular widgets
  for (const [groupPath, indexFile] of indexFiles.entries()) {
    if (!groups.has(groupPath)) {
      groups.set(groupPath, {
        title: indexFile.data.title,
        path: groupPath,
        items: [],
        indexFile: null,
        order: indexFile.data.order,
      });
    }
  }

  // After all groups are created, always assign the indexFile and title if it exists
  for (const [groupPath, group] of groups.entries()) {
    if (indexFiles.has(groupPath)) {
      group.indexFile = indexFiles.get(groupPath)!;
      group.title = indexFiles.get(groupPath)!.data.title;
      group.order = indexFiles.get(groupPath)!.data.order;
    }
  }

  // Build hierarchical structure - exclude groups that are children of other groups
  const allGroups = Array.from(groups.values());

  const topLevelGroups = allGroups.filter((group) => {
    // Root group is always top-level
    if (group.path === "") return true;

    // Check if this group's path is a child of any other group's path
    return !allGroups.some(
      (otherGroup) =>
        otherGroup !== group &&
        otherGroup.path !== "" &&
        group.path.startsWith(otherGroup.path + "/")
    );
  });

  // Recursively build nested structure
  function buildNestedGroups(parentPath: string): WidgetGroup[] {
    const children = allGroups.filter((group) => {
      if (group.path === parentPath) return false;
      if (parentPath === "") {
        // For root level, find groups with no parent
        return !group.path.includes("/") && group.path !== "";
      } else {
        // Find direct children only
        const relativePath = group.path.replace(parentPath + "/", "");
        return (
          group.path.startsWith(parentPath + "/") && !relativePath.includes("/")
        );
      }
    });

    return children
      .map((child) => ({
        ...child,
        items: child.items.sort((a, b) => a.data.order - b.data.order),
        children: buildNestedGroups(child.path),
      }))
      .sort((a, b) => a.order - b.order);
  }

  // Add children to top-level groups
  const result = topLevelGroups
    .map((group) => ({
      ...group,
      items: group.items.sort((a, b) => a.data.order - b.data.order),
      children: buildNestedGroups(group.path),
    }))
    .sort((a, b) => {
      // Root group first
      if (a.path === "") return -1;
      if (b.path === "") return 1;
      return a.order - b.order;
    });

  return result;
}

export async function getGroupedWidgets(): Promise<WidgetGroup[]> {
  const widgets = await getCollection("widgets");
  const allGroups = groupWidgetsByPath(widgets);

  // Only return true top-level groups (not root, not nested)
  const topLevelGroups = allGroups.filter(
    (group) => group.path && !group.path.includes("/")
  );

  // Recursively filter out empty groups and sort items
  function filterGroups(groups: WidgetGroup[]): WidgetGroup[] {
    return groups
      .map((group) => ({
        ...group,
        items: group.items.sort((a, b) => a.data.order - b.data.order),
        children: group.children ? filterGroups(group.children) : [],
      }))
      .filter(
        (group) =>
          group.items.length > 0 ||
          (group.children && group.children.length > 0) ||
          group.indexFile !== null
      )
      .sort((a, b) => a.order - b.order);
  }

  const filtered = filterGroups(topLevelGroups);
  return filtered.sort((a, b) => a.order - b.order);
}
