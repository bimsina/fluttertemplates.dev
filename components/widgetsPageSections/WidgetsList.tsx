import { Widgetsubgroup } from "@/models/widget";
import { List, Typography } from "@material-ui/core";
import WidgetDemoBlock from "./WidgetDemoBlock";

interface WidgetsListProps {
  componentSubgroup: Widgetsubgroup;
}
function WidgetsList(props: WidgetsListProps) {
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
        {props.componentSubgroup.widgets.map((item, index) => (
          <WidgetDemoBlock
            key={`widget_${index}_${item.title}`}
            title={item.title}
            codeUrl={item.codeUrl}
            demoUrl={item.demoUrl}
            rawCodeUrl={item.rawCodeUrl}
          />
        ))}
      </List>
    </div>
  );
}
export default WidgetsList;