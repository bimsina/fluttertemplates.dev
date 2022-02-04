export interface WidgetsResponse {
  widget_groups: WidgetGroup[];
}

export interface WidgetGroup {
  title: string;
  widget_subgroups: Widgetsubgroup[];
}

export interface Widgetsubgroup {
  title: string;
  widgets: Widget[];
}

export interface Widget {
  title: string;
  demoUrl: string;
  codeUrl: string;
  rawCodeUrl: string;
}
