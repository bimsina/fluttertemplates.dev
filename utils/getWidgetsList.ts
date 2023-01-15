import {
  Widget,
  WidgetGroup,
  WidgetsResponse,
  Widgetsubgroup,
} from "@/models/widget";

import { getFolderNestedData } from "./widgets/helper";

export default async function getWidgetsList(): Promise<WidgetsResponse> {
  const allDocsNestedData = await getFolderNestedData("widgets");

  const _groups: WidgetGroup[] = allDocsNestedData.files.map((group) => {
    const _subGroups: Widgetsubgroup[] = group.files.map((subgroup) => {
      const _widgets: Widget[] = subgroup.files.map((widget) => {
        return {
          id: widget.id,
          title: widget.matter.title,
          demoUrl: widget.matter.demoUrl!,
          codeUrl: widget.matter.codeUrl!,
          rawCodeUrl: widget.matter.rawCodeUrl!,
          description: widget.matter.description ?? "",
        };
      });

      const _subGroup: Widgetsubgroup = {
        title: subgroup.matter.title,
        widgets: _widgets,
        id: subgroup.id,
        image: subgroup.matter.image,
        description: subgroup.matter.description ?? "",
      };

      return _subGroup;
    });

    return {
      title: group.matter.title,
      widget_subgroups: _subGroups,
      id: group.id,
    };
  });

  const _response: WidgetsResponse = {
    widget_groups: _groups,
  };

  return _response;
}
