import { WidgetsResponse } from "@/models/widget";

import WidgetsListPage from "../../../components/WidgetsListPage";
import {
  getWidgetStaticPaths,
  getWidgetStaticProps,
} from "@/utils/getWidgetsStaticProps";
import { CustomPost } from "@/utils/widgets/helper";

export default function WidgetsPage({
  postData,
  componentsResponse,
}: {
  postData: CustomPost;
  componentsResponse: WidgetsResponse;
}) {
  if (postData.frontmatter)
    return (
      <WidgetsListPage
        postData={postData}
        componentsResponse={componentsResponse}
      />
    );
  else return <></>;
}

export const getStaticProps = async ({
  params,
}: {
  params: {
    group?: string;
    subGroup?: string;
  };
}) => {
  return await getWidgetStaticProps({
    params,
    isSubGroup: true,
  });
};

export const getStaticPaths = async () => {
  return await getWidgetStaticPaths(true);
};
