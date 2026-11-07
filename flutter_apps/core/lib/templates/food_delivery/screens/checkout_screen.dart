import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/formatting.dart';
import '../models/order.dart';
import '../state/app_scope.dart';
import '../widgets/common.dart';
import '../widgets/food_theme.dart';
import '../widgets/form_helpers.dart';
import '../widgets/layout.dart';
import '../widgets/ticket.dart';
import 'tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _tipOptions = [0, 10, 15, 20];

  final _formKey = GlobalKey<FormState>();
  final _street = TextEditingController();
  final _unit = TextEditingController();
  final _phone = TextEditingController();
  final _instructions = TextEditingController();

  // Card details stay in this form. A real app hands them to the payment
  // provider's SDK and only ever stores the token it returns.
  final _cardName = TextEditingController();
  final _cardNumber = TextEditingController();
  final _cardExpiry = TextEditingController();
  final _cardCvc = TextEditingController();

  late final List<String> _slots = _nextSlots();
  String? _slot;
  PaymentType _payment = PaymentType.card;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _placing = false;

  /// Shown while this route animates away, after the cart has been cleared.
  Widget? _lastBuild;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final saved = CartScope.read(context).address;
    if (saved != null && _street.text.isEmpty) {
      _street.text = saved.street;
      _unit.text = saved.unit;
      _phone.text = saved.phone;
      _instructions.text = saved.instructions;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _street,
      _unit,
      _phone,
      _instructions,
      _cardName,
      _cardNumber,
      _cardExpiry,
      _cardCvc,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> _nextSlots() {
    final now = DateTime.now();
    final minutesToNextHalf = 30 - now.minute % 30;
    final first = now.add(Duration(minutes: minutesToNextHalf + 30));
    return [
      for (var i = 0; i < 3; i++)
        formatClock(first.add(Duration(minutes: i * 30))),
    ];
  }

  Future<void> _placeOrder() async {
    final invalid = _formKey.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      Scrollable.ensureVisible(
        invalid.first.context,
        alignment: 0.2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final cart = CartScope.read(context);
    final orders = OrdersScope.read(context);
    final tabs = TabScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final address = DeliveryAddress(
      street: _street.text.trim(),
      unit: _unit.text.trim(),
      phone: _phone.text.trim(),
      instructions: _instructions.text.trim(),
    );

    setState(() => _placing = true);
    try {
      final order = await orders.place(
        OrderDraft(
          restaurant: cart.restaurant!,
          lines: cart.lines,
          prices: cart.prices,
          address: address,
          payment: _payment,
          scheduledFor: _slot,
        ),
      );
      cart
        ..saveAddress(address)
        ..clear();
      tabs.value = TabScope.orders;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => TrackingScreen(orderId: order.id),
        ),
        (route) => route.isFirst,
      );
    } catch (_) {
      if (mounted) setState(() => _placing = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not place your order. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final restaurant = cart.restaurant;
    if (restaurant == null) return _lastBuild ?? const Scaffold();

    final theme = Theme.of(context);
    final receipt = ReceiptCard(
      prices: cart.prices,
      promoLabel: cart.promo?.code,
    );
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(number: 1, title: 'Deliver to', child: _addressFields()),
        _Section(number: 2, title: 'When', child: _timeChoices()),
        _Section(number: 3, title: 'Payment', child: _paymentChoices()),
        _Section(
          number: 4,
          title: 'Tip your courier',
          child: Row(
            children: [
              for (final (index, percent) in _tipOptions.indexed) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Pill(
                    label: percent == 0 ? 'None' : '$percent%',
                    selected: cart.tipPercent == percent,
                    onTap: () => cart.setTipPercent(percent),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return _lastBuild = FoodTheme(
      seed: restaurant.seedColor,
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        bottomNavigationBar: Builder(
          builder: (context) => BottomActionBar(
            child: FilledButton(
              onPressed: _placing ? null : _placeOrder,
              child: _placing
                  ? SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Place order',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedMoney(cents: cart.prices.totalCents),
                      ],
                    ),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= wideBreakpoint) {
                // The form and receipt scroll separately, which keeps the
                // live total in view while the form is filled in.
                return ContentWidth(
                  maxWidth: 960,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 12, 24),
                          child: form,
                        ),
                      ),
                      SizedBox(
                        width: 340,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(8, 18, 16, 24),
                          child: receipt,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      form,
                      const SizedBox(height: 22),
                      Text(restaurant.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      receipt,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _addressFields() {
    return Column(
      children: [
        TextFormField(
          controller: _street,
          validator: validateStreet,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.streetAddressLine1],
          decoration: const InputDecoration(labelText: 'Street address'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _unit,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Apt or floor (optional)',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _phone,
          validator: validatePhone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: const InputDecoration(labelText: 'Phone number'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _instructions,
          maxLines: 2,
          minLines: 1,
          decoration: const InputDecoration(
            labelText: 'Courier instructions (optional)',
          ),
        ),
      ],
    );
  }

  Widget _timeChoices() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Pill(
          label: 'As soon as possible',
          selected: _slot == null,
          onTap: () => setState(() => _slot = null),
        ),
        for (final slot in _slots)
          _Pill(
            label: slot,
            selected: _slot == slot,
            onTap: () => setState(() => _slot = slot),
          ),
      ],
    );
  }

  Widget _paymentChoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final type in PaymentType.values) ...[
          _PaymentRow(
            type: type,
            selected: _payment == type,
            onTap: () => setState(() => _payment = type),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _payment == PaymentType.card
              ? _cardFields()
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _cardFields() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          TextFormField(
            controller: _cardName,
            validator: validateCardName,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.creditCardName],
            decoration: const InputDecoration(labelText: 'Name on card'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cardNumber,
            validator: validateCardNumber,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: const [CardNumberFormatter()],
            autofillHints: const [AutofillHints.creditCardNumber],
            decoration: const InputDecoration(
              labelText: 'Card number',
              hintText: '4242 4242 4242 4242',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cardExpiry,
                  validator: validateExpiry,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: const [ExpiryFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Expiry',
                    hintText: 'MM/YY',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _cardCvc,
                  validator: validateCvc,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(labelText: 'CVC'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.title,
    required this.child,
  });

  final int number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '$number',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? scheme.primary : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PaymentType type;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (type) {
    PaymentType.card => Icons.credit_card_rounded,
    PaymentType.wallet => Icons.account_balance_wallet_outlined,
    PaymentType.cash => Icons.payments_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _icon,
                  size: 22,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    type.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceMark(selected: selected, single: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
