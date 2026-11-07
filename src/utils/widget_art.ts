export type WidgetArtKind =
  | "amount"
  | "audio"
  | "bars"
  | "calendar"
  | "chips"
  | "call"
  | "card"
  | "chat"
  | "conference"
  | "empty"
  | "form"
  | "grid"
  | "heat"
  | "kanban"
  | "line"
  | "list"
  | "map"
  | "nav"
  | "rail"
  | "onboarding"
  | "pin"
  | "plans"
  | "player"
  | "product"
  | "profile"
  | "ring"
  | "search"
  | "signature"
  | "stars"
  | "steps"
  | "swatches"
  | "sheet"
  | "table"
  | "timer"
  | "tabs"
  | "ticket"
  | "toggles"
  | "upload"
  | "video"
  | "wallet";

// First match wins, so the specific patterns come before the broad ones.
const RULES: [RegExp, WidgetArtKind][] = [
  [/heatmap/, "heat"],
  [/color_picker/, "swatches"],
  [/rating|review/, "stars"],
  [/upload/, "upload"],
  [/signature/, "signature"],
  [/tag_input|category/, "chips"],
  [/multi_step|stepper|survey|quiz/, "steps"],
  [/rail|sidebar|drawer|split_view/, "rail"],
  [/tab/, "tabs"],
  [/conference/, "conference"],
  [/voice_call|video_call/, "call"],
  [/audio|podcast|voice_assistant|voice_search|visualizer/, "audio"],
  [/video|lesson_player/, "video"],
  [/wallet/, "wallet"],
  [/send_money|currency|unit_converter|bill_payment/, "amount"],
  [/ticket|boarding/, "ticket"],
  [/kanban|pipeline|funnel/, "kanban"],
  [/otp|pin_lock|two_factor|biometric/, "pin"],
  [/calendar|date_range|booking|planner|schedule/, "calendar"],
  [/map|directions|location|ride_tracking|delivery_tracking|place_detail/, "map"],
  [/line_chart|sparkline|energy|trend/, "line"],
  [/donut|fitness|water|sleep|bmi|habit|progress/, "ring"],
  [/timer|stopwatch|pomodoro|clock|thermostat|counter/, "timer"],
  [
    /bar_chart|chart|budget|expense|usage|stats|kpi|report|dashboard|visualizer|weather/,
    "bars",
  ],
  [/table|comparison|api_keys|calculator|converter/, "table"],
  [/credit_card/, "card"],
  [/pricing|paywall|subscription/, "plans"],
  [
    /chat|\bdm_|message|comment|typing|prompt|rich_response|reactions|model_picker/,
    "chat",
  ],
  [/player|music/, "player"],
  [/search|recent|filter|suggestion|autocomplete|auto_complete/, "search"],
  [/product_detail|listing_detail|recipe|restaurant_detail|event_detail/, "product"],
  [
    /grid|gallery|album|photo|masonry|catalog|carousel|image|stories|destination|hotel|browser|menu|flashcard|cards$/,
    "grid",
  ],
  [/settings|toggle|privacy|controls|light|permissions|integrations/, "toggles"],
  [
    /sheet|dialog|popup|snackbar|toast|banner|dropdown|swipe|confirmation/,
    "sheet",
  ],
  [/nav|_bar|bottom|rail|drawer|sidebar|sliver|tab|split_view/, "nav"],
  [/onboarding|welcome|value_prop|feature_carousel/, "onboarding"],
  [/empty|error|maintenance|splash|loading|shimmer/, "empty"],
  [/profile|team|seller|lead|about|contact_page/, "profile"],
  [
    /sign|login|form|input|edit|checkout|payment|contact|survey|reset|forgot|magic|verification|upload|tag|color|rating|create|quiz|stepper|slider|notes/,
    "form",
  ],
];

// Only the widget's own name counts, not its category's.
export function widgetArtKind(id: string): WidgetArtKind {
  const name = id.slice(id.lastIndexOf("/") + 1);
  return RULES.find(([pattern]) => pattern.test(name))?.[1] ?? "list";
}

const STATE_ICONS: [RegExp, string][] = [
  [/connection/, "mdi:wifi-off"],
  [/no_data/, "mdi:inbox-outline"],
  [/404/, "mdi:map-marker-question-outline"],
  [/500/, "mdi:alert-circle-outline"],
  [/maintenance/, "mdi:wrench-outline"],
  [/splash/, "mdi:flash"],
  [/shimmer|loading/, "mdi:dots-horizontal"],
];

export function widgetArtIcon(id: string) {
  return STATE_ICONS.find(([pattern]) => pattern.test(id))?.[1];
}

// A stable small number from the id, so similar widgets don't look identical.
export function widgetArtSeed(id: string) {
  let hash = 0;
  for (const char of id) hash = (hash * 31 + char.charCodeAt(0)) | 0;
  return Math.abs(hash);
}
