---
title: Line Chart
description: A Flutter line chart drawn with CustomPaint, comparing two periods of revenue with a crosshair tooltip, range switcher and toggleable series.
app: core
path: /analytics/line_chart
code_files: ["analytics/line_chart.dart"]
---

A single `_LinePainter` draws the grid, axis labels, both series and the area wash, and exposes `xFor` so the gesture code and the tooltip agree on where each point sits. Hover, tap and horizontal drag all feed `_updateHover`, which maps the pointer to the nearest day. The tooltip is a regular `Positioned` widget that flips sides near the right edge. To use real data, replace `_revenue` with your own list of daily values and keep both lists the same length. Change `_axisMoney` and `_money` for other units, and extend `_niceMax` if your values need different axis steps.
