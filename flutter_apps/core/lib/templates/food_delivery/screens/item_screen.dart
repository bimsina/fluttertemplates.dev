import 'package:flutter/material.dart';

import '../models/cart_line.dart';
import '../models/formatting.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../state/app_scope.dart';
import '../widgets/cart_actions.dart';
import '../widgets/common.dart';
import '../widgets/dish_art.dart';
import '../widgets/food_theme.dart';
import '../widgets/layout.dart';
import '../widgets/ticket.dart';

/// Customizes a menu item, either new or an existing cart line ([editing]).
class ItemScreen extends StatefulWidget {
  const ItemScreen({
    super.key,
    required this.restaurant,
    required this.item,
    this.editing,
  });

  final Restaurant restaurant;
  final MenuItem item;
  final CartLine? editing;

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  /// Selected option ids, by group id.
  final Map<String, Set<String>> _selected = {};
  late final _groupKeys = {
    for (final group in widget.item.optionGroups) group.id: GlobalKey(),
  };
  late final TextEditingController _note;
  late int _quantity;
  bool _showErrors = false;

  MenuItem get _item => widget.item;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _note = TextEditingController(text: editing?.note ?? '');
    _quantity = editing?.quantity ?? 1;
    final chosen = editing?.selected.map((o) => o.id).toSet() ?? const {};
    for (final group in _item.optionGroups) {
      _selected[group.id] = {
        for (final option in group.options)
          if (chosen.contains(option.id)) option.id,
      };
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  List<ItemOption> get _selectedOptions => [
    for (final group in _item.optionGroups)
      for (final option in group.options)
        if (_selected[group.id]!.contains(option.id)) option,
  ];

  int get _totalCents {
    final extras = _selectedOptions.fold(0, (sum, o) => sum + o.priceCents);
    return (_item.priceCents + extras) * _quantity;
  }

  bool _isMissing(OptionGroup group) =>
      _selected[group.id]!.length < group.minSelected;

  void _toggle(OptionGroup group, ItemOption option) {
    setState(() {
      final selected = _selected[group.id]!;
      if (group.isSingleChoice) {
        final wasSelected = selected.contains(option.id);
        selected.clear();
        // A required single choice cannot be cleared, an optional one can.
        if (!wasSelected || group.isRequired) selected.add(option.id);
      } else if (!selected.remove(option.id) &&
          selected.length < group.maxSelected) {
        selected.add(option.id);
      }
    });
  }

  Future<void> _submit() async {
    final missing = _item.optionGroups.where(_isMissing).firstOrNull;
    if (missing != null) {
      setState(() => _showErrors = true);
      final target = _groupKeys[missing.id]!.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          alignment: 0.1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    final cart = CartScope.read(context);
    final navigator = Navigator.of(context);
    final editing = widget.editing;
    if (editing != null) {
      cart.replaceLine(
        lineId: editing.id,
        selected: _selectedOptions,
        quantity: _quantity,
        note: _note.text,
      );
      navigator.pop();
      return;
    }

    final current = cart.restaurant;
    if (current != null && cart.conflictsWith(widget.restaurant)) {
      final replace = await confirmReplaceCart(
        context,
        currentRestaurant: current.name,
        newRestaurant: widget.restaurant.name,
      );
      if (!replace) return;
      cart.clear();
    }
    cart.add(
      restaurant: widget.restaurant,
      item: _item,
      selected: _selectedOptions,
      quantity: _quantity,
      note: _note.text,
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return FoodTheme(
      seed: widget.restaurant.seedColor,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          return Scaffold(
            bottomNavigationBar: BottomActionBar(
              child: Row(
                children: [
                  QuantityStepper(
                    quantity: _quantity,
                    onChanged: (value) => setState(() => _quantity = value),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.editing == null ? 'Add' : 'Update',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedMoney(cents: _totalCents),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 196,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1),
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) =>
                              Transform.scale(scale: value, child: child),
                          child: DishArt(kind: _item.kind, size: 148),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ContentWidth(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _item.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _item.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatMoney(_item.priceCents),
                            style: theme.textTheme.titleMedium,
                          ),
                          for (final group in _item.optionGroups)
                            _GroupSection(
                              key: _groupKeys[group.id],
                              group: group,
                              selected: _selected[group.id]!,
                              showError: _showErrors && _isMissing(group),
                              onToggle: (option) => _toggle(group, option),
                            ),
                          const SizedBox(height: 22),
                          Text(
                            'Note for the kitchen',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _note,
                            maxLength: 120,
                            maxLines: 2,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'No onions, extra sauce on the side',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    super.key,
    required this.group,
    required this.selected,
    required this.showError,
    required this.onToggle,
  });

  final OptionGroup group;
  final Set<String> selected;
  final bool showError;
  final ValueChanged<ItemOption> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final atLimit =
        !group.isSingleChoice && selected.length >= group.maxSelected;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(group.title, style: theme.textTheme.titleMedium),
              ),
              const SizedBox(width: 8),
              Text(
                group.hint,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: showError ? scheme.error : scheme.onSurfaceVariant,
                  fontWeight: group.isRequired ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Pick an option to continue',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: showError ? scheme.error : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                for (final option in group.options)
                  _OptionRow(
                    option: option,
                    single: group.isSingleChoice,
                    selected: selected.contains(option.id),
                    enabled: !atLimit || selected.contains(option.id),
                    onTap: () => onToggle(option),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.single,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ItemOption option;
  final bool single;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = enabled ? scheme.onSurface : scheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ChoiceMark(selected: selected, single: single, enabled: enabled),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.name,
                  style: theme.textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
              if (option.priceCents > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '+${formatMoney(option.priceCents)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
