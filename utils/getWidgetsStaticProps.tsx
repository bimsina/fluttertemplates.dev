import path from "path";
import getWidgetsList from "./getWidgetsList";
import { getPathList, getPostData } from "./widgets/helper";

const WIDGETS_ROOT = path.join(process.cwd(), "/widgets");

const pageFileCache: Record<string, string> = {};

export const getWidgetStaticProps = async ({
  params,
  isSubGroup = false,
}: {
  isSubGroup?: boolean;
  params: {
    group?: string;
    subGroup?: string;
    widgetId?: string;
  };
}) => {
  let slugPath: string = "";

  if (params.group) slugPath = params.group;
  if (params.subGroup) slugPath = slugPath + "/" + params.subGroup;
  if (params.widgetId) slugPath = slugPath + "/" + params.widgetId;

  if (!pageFileCache[slugPath]) {
    await getWidgetStaticPaths(isSubGroup);
  }
  const markdownFile = pageFileCache[slugPath];

  const postData = await getPostData(slugPath, markdownFile);

  const componentsResponse = await getWidgetsList();

  return {
    props: {
      postData,
      componentsResponse,
    },
  };
};

export const getWidgetStaticPaths = async (isSubGroup?: boolean) => {
  let paths = await getPathList(WIDGETS_ROOT, WIDGETS_ROOT, pageFileCache);

  const filtered = paths.filter((val) => {
    return val.params.id.length === (isSubGroup ? 3 : 2);
  });

  const _paths = filtered.map((val) => {
    return {
      params: {
        group: val.params.id[0],
        subGroup: val.params.id[1],
        widgetId: val.params.id[2],
      },
    };
  });

  return {
    paths: _paths,
    fallback: false,
  };
};
