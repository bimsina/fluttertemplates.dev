---
title: Conversion Funnel
description: A Flutter conversion funnel in CustomPaint with centered stage bars, carry-through wedges, platform tabs and step drop-off details.
app: core
path: /analytics/conversion_funnel
code_files: ["analytics/conversion_funnel.dart"]
---

`_FunnelPainter` lays stages out in fixed-height rows, which reduces hit testing to one division in `_selectAt`. Bar widths are proportional to the first stage, and the faint wedge between rows shows how much of each stage carries into the next. Fill strength steps down a single hue because the stages are ordered, not separate categories. The detail card derives step conversion, overall conversion and drop-off from the counts, so only the `_Platform` values and `_stages` need replacing. Each platform must supply one count per stage. Very small final stages get thin, so raise a minimum bar width if your funnel narrows sharply.
