import { WidgetGroup, Widgetsubgroup } from "@/models/widget";
import {
  List,
  ListItem,
  ListItemText,
  Typography,
  useTheme,
} from "@material-ui/core";

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
        {props.widgetGroups.map((item, index) => (
          <div key={`group_${index}`}>
            <Typography
              style={{
                fontWeight: "bold",
              }}
            >
              {item.title}
            </Typography>
            <List>
              {item.widget_subgroups.map((item, index) => (
                <ListItem
                  button
                  key={`sub_group_${index}`}
                  onClick={() => props.onSubGroupSelected(item)}
                  style={{
                    backgroundColor:
                      props.selectedSubGroup?.title === item.title
                        ? `${theme.palette.secondary.main}10`
                        : "",
                  }}
                >
                  <Typography
                    style={{
                      color:
                        props.selectedSubGroup?.title === item.title
                          ? theme.palette.secondary.main
                          : "",
                    }}
                  >
                    {item.title}
                  </Typography>
                </ListItem>
              ))}
            </List>
          </div>
        ))}
      </List>
    </div>
  );
}
export default WidgetsSidebar;
