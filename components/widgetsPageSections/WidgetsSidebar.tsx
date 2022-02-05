import { WidgetGroup, Widgetsubgroup } from "@/models/widget";
import { List, ListItem, Typography, useTheme } from "@material-ui/core";
import Link from "next/link";

const drawerWidth = 220;

interface WidgetSidebarProps {
  widgetGroups: WidgetGroup[];
  selectedSubGroup?: Widgetsubgroup;
  onSubGroupSelected: (subGroup: Widgetsubgroup) => void;
}
function WidgetsSidebar(props: WidgetSidebarProps) {
  const theme = useTheme();
  return (
    <div
      style={{
        width: `${drawerWidth}px`,
        marginTop: "3rem",
      }}
    >
      <List>
        {props.widgetGroups.map((group) => (
          <div key={`group_${group}`}>
            <Typography
              style={{
                fontWeight: "bold",
              }}
            >
              {group.title}
            </Typography>
            <List>
              {group.widget_subgroups.map((subgroup, index) => (
                <Link
                  href={`/widgets/${subgroup.id}`}
                  replace
                  key={`sub_group_${index}`}
                >
                  <a>
                    <ListItem
                      button
                      // onClick={() => props.onSubGroupSelected(item)}
                      style={{
                        backgroundColor:
                          props.selectedSubGroup?.title === subgroup.title
                            ? `${theme.palette.secondary.main}10`
                            : "",
                      }}
                    >
                      <Typography
                        style={{
                          color:
                            props.selectedSubGroup?.title === subgroup.title
                              ? theme.palette.secondary.main
                              : "",
                        }}
                      >
                        {subgroup.title}
                      </Typography>
                    </ListItem>
                  </a>
                </Link>
              ))}
            </List>
          </div>
        ))}
      </List>
    </div>
  );
}
export default WidgetsSidebar;
