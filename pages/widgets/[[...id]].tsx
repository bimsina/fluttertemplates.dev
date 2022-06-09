import path from "path";
import {
  getFolderNestedData,
  getPathList,
  getPostData,
} from "../../utils/widgets/helper";

import { NestedFolder } from "@/utils/widgets/models";
import { useEffect, useState } from "react";
import {
  Widget,
  WidgetGroup,
  WidgetsResponse,
  Widgetsubgroup,
} from "@/models/widget";

import { useRouter } from "next/router";
import WidgetPageHead from "@/head/WidgetPageHead";
import CircularProgress from "@/components/shared/CircularProgress";
import WidgetsList from "@/components/widgetsPageSections/WidgetsList";
import { MdChevronRight, MdHome } from "react-icons/md";

export default function Docs({
  postData,
  allDocsNestedData,
}: {
  postData: any;
  allDocsNestedData: NestedFolder;
}) {
  const [isLoading, setIsLoading] = useState(true);
  const [componentsResponse, setComponentsResponse] =
    useState<WidgetsResponse>();

  const [selectedSubGroup, setSelectedSubGroup] =
    useState<Widgetsubgroup | null>();

  const [selectedGroup, setSelectedGroup] = useState<WidgetGroup | null>();

  const router = useRouter();

  useEffect(() => {
    _fetchComponents();
  }, [router.query]);

  const _fetchComponents = async () => {
    const _params = router.query ?? [];
    let _selectedSubGroupId = "";
    let _selectedGroupId = "";
    let _selectedGroup: WidgetGroup | null = null;

    if (_params.id?.length === 1) {
      _selectedGroupId = _params.id[0];
    }

    if (_params.id?.length === 2) {
      _selectedGroupId = _params.id[0];
      _selectedSubGroupId = ((_params.id ?? []) as string[]).join("/");
    }

    let _groups: WidgetGroup[] = [];
    allDocsNestedData.files.map((group) => {
      let _subgroups: Widgetsubgroup[] = [];
      group.files.map((subgroup) => {
        let _widgets: Widget[] = [];
        subgroup.files.map((widget) => {
          _widgets.push({
            id: widget.id,
            title: widget.matter.title,
            demoUrl: widget.matter.demoUrl!,
            codeUrl: widget.matter.codeUrl!,
            rawCodeUrl: widget.matter.rawCodeUrl!,
            description: widget.matter.description ?? "",
          });
        });

        const _subGroup: Widgetsubgroup = {
          title: subgroup.matter.title,
          widgets: _widgets,
          id: subgroup.id,
          image: subgroup.matter.image,
          description: subgroup.matter.description ?? "",
        };
        if (_selectedSubGroupId === subgroup.id) {
          setSelectedSubGroup(_subGroup);
        }
        _subgroups.push(_subGroup);
      });
      const _group: WidgetGroup = {
        title: group.matter.title,
        widget_subgroups: _subgroups,
        id: group.id,
      };

      if (_selectedGroupId === group.id) {
        _selectedGroup = _group;
      }

      _groups.push(_group);
    });

    const _response: WidgetsResponse = {
      widget_groups: _groups,
    };

    setComponentsResponse(_response);
    setSelectedGroup(_selectedGroup);

    // if (_selectedSubGroupId === "") {
    //   if (_selectedGroup) {
    //     setSelectedSubGroup(_selectedGroup!.widget_subgroups[0]);
    //   } else {
    //     setSelectedSubGroup(_response.widget_groups[0].widget_subgroups[0]);
    //   }
    // }
    setIsLoading(false);
  };

  return (
    <>
      <WidgetPageHead
        title={postData.frontmatter.title}
        description={`${
          postData.frontmatter.description
            ? postData.frontmatter.description + " - "
            : ""
        }${selectedSubGroup?.widgets
          .map((item) => item.description)
          .join(" ")}`}
      />

      <div className="inline-flex w-full justify-center">
        <div className="max-w-5xl w-full">
          {renderNav()}

          {isLoading ? (
            <div className="w-full h-[80vh]">
              <CircularProgress />
            </div>
          ) : (
            <>
              {renderContent()}
              {selectedGroup && selectedSubGroup && (
                <WidgetsList componentSubgroup={selectedSubGroup} />
              )}
            </>
          )}
        </div>
      </div>
    </>
  );

  function renderNav() {
    return (
      <>
        {selectedGroup && selectedSubGroup && (
          <nav
            className="flex text-sm font-medium text-gray-700 dark:text-gray-200 px-4"
            aria-label="Breadcrumb"
          >
            <ol className="inline-flex items-center space-x-1 md:space-x-3">
              <li className="inline-flex items-center">
                <a href="/widgets" className="inline-flex items-center ">
                  <MdHome className="text-xl mr-2" />
                  Widgets
                </a>
              </li>
              <li>
                <div className="flex items-center">
                  <MdChevronRight />
                  <div className="group inline-block relative">
                    <button className="py-2 px-4 rounded inline-flex items-center">
                      {selectedGroup.title}
                    </button>
                    <ul className="absolute hidden text-gray-700 dark:text-gray-200 pt-1 group-hover:block z-10 bg-card dark:bg-darkCard shadow-lg ml-3">
                      {componentsResponse?.widget_groups.map((group) => {
                        return (
                          <li className="" key={`group${group.id}`}>
                            <button
                              className="rounded-sm hover:bg-background dark:hover:bg-darkBackground py-2 px-4 block whitespace-no-wrap w-full text-left"
                              onClick={() => {
                                if (group.id === selectedGroup.id) return;
                                setSelectedGroup(group);
                                setSelectedSubGroup(group.widget_subgroups[0]);
                              }}
                            >
                              {group.title}
                            </button>
                          </li>
                        );
                      })}
                    </ul>
                  </div>
                </div>
              </li>
              <li aria-current="page">
                <div className="flex items-center">
                  <MdChevronRight />
                  <div className="group inline-block relative">
                    <button className="py-2 px-4 rounded inline-flex items-center">
                      {selectedSubGroup.title}
                    </button>
                    <ul className="absolute hidden text-gray-700 dark:text-gray-200 pt-1 group-hover:block z-10 bg-card dark:bg-darkCard shadow-lg ml-3">
                      {selectedGroup?.widget_subgroups.map((subgroup) => {
                        return (
                          <li className="" key={`group${subgroup.id}`}>
                            <button
                              className="rounded-sm hover:bg-card py-2 px-4 block whitespace-no-wrap w-full text-left"
                              // href={`/widgets/${subgroup.id}`}
                              onClick={() => {
                                if (subgroup.id === selectedSubGroup.id) return;
                                setSelectedSubGroup(subgroup);
                              }}
                            >
                              {subgroup.title}
                            </button>
                          </li>
                        );
                      })}
                    </ul>
                  </div>
                </div>
              </li>
            </ol>
          </nav>
        )}
      </>
    );
  }

  function renderContent() {
    return (
      <>
        {!(selectedGroup && selectedSubGroup) && (
          <div className="grid grid-cols-1 py-4">
            {(componentsResponse?.widget_groups ?? []).map(
              (widget, index: number) => {
                return (
                  <div className="flex flex-col" key={`widget_group${index}`}>
                    <h4 className="font-bold mb-2 px-8 lg:px-0">
                      {widget.title}
                    </h4>
                    <div className="grid lg:grid-cols-4 md:grid-cols-3 grid-cols-2 gap-4 pb-8 px-8 lg:px-0">
                      {widget.widget_subgroups.map((subgroup, idx) => {
                        return (
                          <a
                            href={`/widgets/${subgroup.id}`}
                            className="cursor-pointer"
                            key={`widget_subgroup${idx}`}
                          >
                            <div className="bg-background dark:bg-darkCard rounded-lg border-2 border-card dark:border-darkCard hover:border-primary dark:hover:border-primary transition-all">
                              <img
                                className="rounded-t-lg bg-primaryLight bg-opacity-10"
                                src={
                                  subgroup.image ?? "images/widgets/default.svg"
                                }
                                alt={subgroup.title}
                              />

                              <h5 className="text-md tracking-tight text-gray-900 dark:text-gray-50 p-4">
                                {subgroup.title}
                              </h5>
                              {/* <p className="truncate px-2 pb-2 text-sm text-gray-500">
                                {subgroup.description}
                              </p> */}
                            </div>
                          </a>
                        );
                      })}
                    </div>
                  </div>
                );
              }
            )}
          </div>
        )}
      </>
    );
  }
}

const WIDGETS_ROOT = path.join(process.cwd(), "/widgets");

const pageFileCache: any = {};

export const getStaticProps = async ({ params }: { params: any }) => {
  // Retrieve full path from a cache. Generate cache if it doesnt exist.
  // id is undefined at index '/', set slugpath as '' instead
  let slugPath;
  if (params.id) {
    slugPath = params.id.join("/");
  } else {
    slugPath = "";
  }
  if (!pageFileCache[slugPath]) {
    await getStaticPaths();
  }
  const markdownFile = pageFileCache[slugPath];

  // Get postdata for the slug and markdown file
  const postData = await getPostData(slugPath, markdownFile);

  const allDocsNestedData = await getFolderNestedData("widgets");

  return {
    props: {
      postData,
      allDocsNestedData,
    },
  };
};

// Get static paths being a wrapper around the getPathList
export const getStaticPaths = async () => {
  let paths = await getPathList(WIDGETS_ROOT, WIDGETS_ROOT, pageFileCache);

  return {
    paths,
    fallback: false,
  };
};
