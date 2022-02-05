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
import { CircularProgress, Grid } from "@material-ui/core";
import WidgetsSidebar from "@/components/widgetsPageSections/WidgetsSidebar";
import WidgetsList from "@/components/widgetsPageSections/WidgetsList";
import WidgetPageHead from "@/head/WidgetPageHead";
import { useRouter } from "next/router";

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

  const [selectedSubGroup, setSelectedSubGroup] = useState<Widgetsubgroup>();
  const router = useRouter();

  useEffect(() => {
    const _fetchComponents = async () => {
      const _params = router.query ?? [];
      let _selectedSubGroupId = "";

      if (Array.isArray(_params.id)) {
        if ((_params.id?.length ?? 0) === 2) {
          _selectedSubGroupId = _params.id.join("/");
        }
      }

      let _groups: WidgetGroup[] = [];
      allDocsNestedData.files.map((group) => {
        let _subgroups: Widgetsubgroup[] = [];
        group.files.map((subgroup) => {
          let _widgets: Widget[] = [];
          subgroup.files.map((widget) => {
            _widgets.push({
              title: widget.matter.title,
              demoUrl: widget.matter.demoUrl!,
              codeUrl: widget.matter.codeUrl!,
              rawCodeUrl: widget.matter.rawCodeUrl!,
            });
          });

          const _subGroup: Widgetsubgroup = {
            title: subgroup.matter.title,
            widgets: _widgets,
            id: subgroup.id,
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
        _groups.push(_group);
      });

      const _response: WidgetsResponse = {
        widget_groups: _groups,
      };

      setComponentsResponse(_response);
      if (!selectedSubGroup) {
        setSelectedSubGroup(_response.widget_groups[0].widget_subgroups[0]);
      }
      setIsLoading(false);
    };
    _fetchComponents();
  }, [router.query]);

  return (
    <>
      <WidgetPageHead
        title={postData.frontmatter.title}
        description={postData.frontmatter.description}
      />

      {isLoading ? (
        <Grid
          container
          alignContent="center"
          style={{
            display: "flex",
            justifyContent: "center",
            height: "80vh",
          }}
        >
          <Grid item>
            <CircularProgress size="1.5rem" thickness={8} color="secondary" />
          </Grid>
        </Grid>
      ) : (
        <Grid container direction="row" justifyContent="center">
          <Grid item>
            <WidgetsSidebar
              selectedSubGroup={selectedSubGroup}
              onSubGroupSelected={(subGroup) => {
                setSelectedSubGroup(subGroup);
              }}
              widgetGroups={componentsResponse?.widget_groups ?? []}
            />
          </Grid>
          <Grid item xs={12} md={8} lg={8}>
            {selectedSubGroup ? (
              <WidgetsList componentSubgroup={selectedSubGroup} />
            ) : (
              <div></div>
            )}
          </Grid>
        </Grid>
      )}
    </>
  );
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
