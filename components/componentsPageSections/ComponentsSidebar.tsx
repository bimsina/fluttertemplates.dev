import {
  List,
  ListItem,
  ListItemText,
  Typography,
  useTheme,
} from "@material-ui/core";
import { ComponentGroup, ComponentSubgroup } from "../api/fetchComponents";

const drawerWidth = 220;

interface ComponentsSidebarProps {
  componentGroups: ComponentGroup[];
  selectedSubGroup?: ComponentSubgroup;
  onSubGroupSelected: (subGroup: ComponentSubgroup) => void;
}
function ComponentsSidebar(props: ComponentsSidebarProps) {
  const theme = useTheme();
  return (
    <div
      style={{
        width: `${drawerWidth}px`,
        marginTop: "3rem",
      }}
    >
      <List>
        {props.componentGroups.map((item, index) => (
          <div key={`group_${index}`}>
            <Typography
              style={{
                fontWeight: "bold",
              }}
            >
              {item.title}
            </Typography>
            <List>
              {item.component_subgroups.map((item, index) => (
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
export default ComponentsSidebar;
