import { WidgetGroup, Widgetsubgroup } from "@/models/widget";
import { List, ListItem, Typography, useTheme } from "@mui/material";
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
              variant="body1"
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
                      style={{
                        borderRadius: "0 1rem 1rem 0",
                        backgroundColor:
                          props.selectedSubGroup?.title === subgroup.title
                            ? `${theme.palette.secondary.main}10`
                            : "",
                      }}
                    >
                      <Typography
                        variant="body2"
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
