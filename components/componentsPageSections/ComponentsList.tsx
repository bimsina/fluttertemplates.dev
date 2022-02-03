import { List, ListItem, ListItemText, Typography } from "@material-ui/core";
import { ComponentSubgroup } from "../api/fetchComponents";
import ComponentDemoBlock from "./ComponentDemoBlock";

interface ComponentsListProps {
  componentSubgroup: ComponentSubgroup;
}
function ComponentsList(props: ComponentsListProps) {
  return (
    <div
      style={{
        width: `100%`,
        marginTop: "1rem",
        marginLeft: "1rem",
      }}
    >
      <Typography
        variant="h4"
        style={{
          fontWeight: "bold",
        }}
      >
        {props.componentSubgroup.title}
      </Typography>
      <List>
        {props.componentSubgroup.components.map((item, index) => (
          <ComponentDemoBlock
            key={`component_${index}`}
            title={item.title}
            codeUrl={`https://github.com/fluttertemplates-dev/components/blob/master/lib/components/${item.path}.dart`}
            demoUrl={`https://fluttertemplates-dev.github.io/components/#/${item.path}`}
            rawCodeUrl={`https://raw.githubusercontent.com/fluttertemplates-dev/components/master/lib/components/${item.path}.dart`}
          />
        ))}
      </List>
    </div>
  );
}
export default ComponentsList;
