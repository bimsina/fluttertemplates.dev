import { Icon } from "@iconify/react";
import { useEffect, useMemo, useState } from "react";

function getWidgetPathFromUrl(): string {
  return typeof window === "undefined"
    ? ""
    : window.location.pathname.replace(/^\/widgets\/?/, "").replace(/\/$/, "");
}

export interface WidgetSidebarItem {
  id: string;
  title: string;
  icon?: string;
}

export interface WidgetSidebarGroup {
  id: string;
  title: string;
  icon?: string;
  items: WidgetSidebarItem[];
  children?: WidgetSidebarGroup[];
}

interface WidgetsSidebarProps {
  groups: WidgetSidebarGroup[];
  currentPath: string;
}

function groupContainsPath(group: WidgetSidebarGroup, path: string): boolean {
  if (path === group.id || path.startsWith(group.id + "/")) return true;
  return !!group.children?.some((c) => groupContainsPath(c, path));
}

function groupHasSearchMatch(group: WidgetSidebarGroup, q: string): boolean {
  if (group.title.toLowerCase().includes(q)) return true;
  if (group.items.some((item) => item.title.toLowerCase().includes(q)))
    return true;
  return !!group.children?.some((c) => groupHasSearchMatch(c, q));
}

function WidgetsNavGroup({
  group,
  currentPath,
  isNested = false,
  expandOnLoad = true,
  searchQuery,
}: {
  group: WidgetSidebarGroup;
  currentPath: string;
  isNested?: boolean;
  expandOnLoad?: boolean;
  searchQuery: string;
}) {
  const [isExpanded, setIsExpanded] = useState(expandOnLoad);

  const q = searchQuery.trim().toLowerCase();
  const isSearching = q.length > 0;

  const filteredItems = useMemo(() => {
    if (!isSearching) return group.items;
    return group.items.filter((item) => item.title.toLowerCase().includes(q));
  }, [group.items, q, isSearching]);

  const visibleChildren = useMemo(() => {
    if (!group.children?.length) return [];
    if (!isSearching) return group.children;
    return group.children.filter((child) => groupHasSearchMatch(child, q));
  }, [group.children, q, isSearching]);

  const isGroupActive =
    currentPath === group.id || currentPath.startsWith(group.id + "/");
  const hasVisibleContent =
    filteredItems.length > 0 ||
    visibleChildren.length > 0 ||
    (isSearching && group.title.toLowerCase().includes(q));
  const isVisible = !isSearching || hasVisibleContent;

  if (!isVisible) return null;

  return (
    <ul className="pt-2 pl-0">
      <li
        data-group-id={group.id}
        data-group-title={group.title}
        className={`${!isNested ? "mb-1" : ""} ${isGroupActive ? "sidebar-group-active" : ""}`}
      >
        <div className="group-header">
          <div className="flex w-full items-center justify-between">
            <a
              href={"/widgets/" + group.id}
              data-swup-preload
              className="group-header-link text-foreground hover:bg-muted/50 flex flex-1 cursor-pointer items-center gap-2 rounded-md px-4 py-3 font-medium transition-colors"
            >
              {group.icon && (
                <Icon icon={group.icon} className="size-4 shrink-0" />
              )}
              <span className="truncate text-sm">{group.title}</span>
            </a>
            <button
              type="button"
              className="text-foreground hover:bg-muted/50 rounded-md p-2 transition-colors"
              onClick={() => setIsExpanded(!isExpanded)}
              aria-expanded={isExpanded}
              aria-label="Toggle section"
            >
              <Icon
                icon="mdi:chevron-down"
                className="size-4 shrink-0 transition-transform duration-200"
                style={{
                  transform: isExpanded ? "rotate(180deg)" : "rotate(0deg)",
                }}
              />
            </button>
          </div>
        </div>

        <div
          className="overflow-hidden transition-all duration-200 ease-in-out"
          style={{ maxHeight: isExpanded ? 1000 : 0 }}
        >
          <ul className="space-y-1 pl-4">
            {filteredItems.map((item) => {
              const isItemActive = currentPath === item.id;
              return (
                <li key={item.id}>
                  <a
                    href={`/widgets/${item.id}`}
                    data-item-id={item.id}
                    data-item-title={item.title}
                    data-swup-preload
                    className={`hover:bg-muted/50 text-foreground flex items-center gap-2 rounded-md px-2 py-2 text-sm transition-colors ${
                      isItemActive ? "sidebar-active" : ""
                    }`}
                  >
                    {item.icon && (
                      <Icon icon={item.icon} className="size-4 shrink-0" />
                    )}
                    <span className="truncate">{item.title}</span>
                  </a>
                </li>
              );
            })}
            {visibleChildren.map((childGroup) => (
              <li key={childGroup.id}>
                <WidgetsNavGroup
                  group={childGroup}
                  currentPath={currentPath}
                  isNested
                  expandOnLoad={groupContainsPath(childGroup, currentPath)}
                  searchQuery={searchQuery}
                />
              </li>
            ))}
          </ul>
        </div>
      </li>
    </ul>
  );
}

export default function WidgetsSidebar({
  groups,
  currentPath: initialPath,
}: WidgetsSidebarProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPath, setCurrentPath] = useState(initialPath);

  useEffect(() => {
    const updateFromUrl = () => setCurrentPath(getWidgetPathFromUrl());
    updateFromUrl();
    document.addEventListener("swup:page:view", updateFromUrl);
    window.addEventListener("popstate", updateFromUrl);
    return () => {
      document.removeEventListener("swup:page:view", updateFromUrl);
      window.removeEventListener("popstate", updateFromUrl);
    };
  }, []);

  return (
    <aside
      id="widgets-sidebar"
      className="flex max-h-[70vh] w-full shrink-0 flex-col lg:sticky lg:top-24 lg:max-h-[calc(100vh-7rem)] lg:w-60"
      data-current-path={currentPath}
    >
      <div className="bg-background sticky top-0 z-10 shrink-0 pb-3">
        <div className="relative">
          <Icon
            icon="mdi:magnify"
            className="text-muted-foreground pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2"
          />
          <input
            type="search"
            id="widgets-sidebar-search"
            placeholder="Search widgets..."
            className="bg-muted placeholder:text-muted-foreground focus:ring-ring w-full rounded-xl border-0 py-2.5 pr-3 pl-9 text-sm focus:ring-2 focus:outline-none"
            autoComplete="off"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      <nav
        className="flex-1 overflow-y-auto overscroll-contain py-2"
        id="widgets-nav"
      >
        {groups.map((group) => (
          <WidgetsNavGroup
            key={group.id}
            group={group}
            currentPath={currentPath}
            isNested={false}
            expandOnLoad={groupContainsPath(group, currentPath)}
            searchQuery={searchQuery}
          />
        ))}
      </nav>
    </aside>
  );
}
