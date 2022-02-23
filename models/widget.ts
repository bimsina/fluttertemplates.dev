export interface WidgetsResponse {
  widget_groups: WidgetGroup[];
}

export interface WidgetGroup {
  title: string;
  id: string;
  widget_subgroups: Widgetsubgroup[];
}

export interface Widgetsubgroup {
  title: string;
  id: string;
  widgets: Widget[];
}

export interface Widget {
  title: string;
  id: string;
  demoUrl: string;
  codeUrl: string;
  rawCodeUrl: string;
}
