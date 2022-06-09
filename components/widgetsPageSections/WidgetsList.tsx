import { Widgetsubgroup } from "@/models/widget";
import WidgetDemoBlock from "./WidgetDemoBlock";

interface WidgetsListProps {
  componentSubgroup: Widgetsubgroup;
}
function WidgetsList(props: WidgetsListProps) {
  return (
    <div className="w-full mt-4 px-4">
      <div className="grid grid-cols-1 w-full">
        {props.componentSubgroup.widgets.map((item, index) => (
          <WidgetDemoBlock
            key={`widget_${index}_${item.title}`}
            title={item.title}
            codeUrl={item.codeUrl}
            demoUrl={item.demoUrl}
            rawCodeUrl={item.rawCodeUrl}
            description={item.description}
            id={item.id.split("/").slice(-1)[0]}
          />
        ))}
      </div>
    </div>
  );
}
export default WidgetsList;
