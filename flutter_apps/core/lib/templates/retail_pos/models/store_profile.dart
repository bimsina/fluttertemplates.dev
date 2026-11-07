/// Details printed on receipts and used for tax.
class StoreProfile {
  const StoreProfile({
    required this.name,
    required this.addressLines,
    required this.phone,
    required this.tillName,
    required this.taxLabel,
    required this.taxRateBasisPoints,
    required this.openingFloatCents,
  });

  final String name;
  final List<String> addressLines;
  final String phone;
  final String tillName;
  final String taxLabel;

  /// 825 is 8.25%.
  final int taxRateBasisPoints;

  /// Cash placed in the drawer at the start of the day.
  final int openingFloatCents;
}
