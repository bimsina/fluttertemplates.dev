import 'package:flutter/material.dart';

class _Item {
  final IconData icon;
  final String label;
  const _Item(this.icon, this.label);
}

class ExpandableSidebar extends StatefulWidget {
  const ExpandableSidebar({super.key});

  @override
  State<ExpandableSidebar> createState() => _ExpandableSidebarState();
}

class _ExpandableSidebarState extends State<ExpandableSidebar> {
  bool _expanded = true;
  int _selected = 0;

  static const _items = [
    _Item(Icons.dashboard_outlined, 'Dashboard'),
    _Item(Icons.inventory_2_outlined, 'Products'),
    _Item(Icons.receipt_long_outlined, 'Orders'),
    _Item(Icons.people_outline, 'Customers'),
    _Item(Icons.bar_chart_outlined, 'Analytics'),
    _Item(Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _expanded ? 220 : 72,
            color: scheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                IconButton(
                  tooltip: _expanded ? 'Collapse sidebar' : 'Expand sidebar',
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(_expanded ? Icons.menu_open : Icons.menu),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      final active = _selected == i;
                      // The hidden label's name moves to Semantics, and
                      // MergeSemantics keeps each row a single node.
                      final row = MergeSemantics(
                        child: Semantics(
                          button: true,
                          selected: active,
                          label: _expanded ? null : item.label,
                          child: Material(
                            color: active
                                ? scheme.primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => setState(() => _selected = i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(item.icon,
                                        color: active
                                            ? scheme.onPrimaryContainer
                                            : scheme.onSurfaceVariant),
                                    if (_expanded)
                                      // The gap sits inside Expanded because
                                      // the label appears while the rail is
                                      // still narrow, and Padding can shrink.
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 14),
                                          child: Text(item.label,
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: active
                                                      ? scheme.onPrimaryContainer
                                                      : scheme.onSurface)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        child: _expanded
                            ? row
                            : Tooltip(
                                message: item.label,
                                excludeFromSemantics: true,
                                child: row,
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: Text(_items[_selected].label,
                  style: theme.textTheme.headlineSmall),
            ),
          ),
        ],
      ),
    );
  }
}
