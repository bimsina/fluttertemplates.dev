import 'package:flutter/material.dart';

/// Draws a real Code 39 barcode, so a printed receipt can be scanned back for
/// returns. Supports digits, `R` and `-`, which covers receipt numbers.
class Code39Barcode extends StatelessWidget {
  const Code39Barcode({super.key, required this.data, this.height = 44});

  final String data;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Barcode for receipt $data',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _Code39Painter(
            data,
            Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Nine elements per character, alternating bar and space, `1` meaning wide.
const _patterns = {
  '0': '000110100',
  '1': '100100001',
  '2': '001100001',
  '3': '101100000',
  '4': '000110001',
  '5': '100110000',
  '6': '001110000',
  '7': '000100101',
  '8': '100100100',
  '9': '001100100',
  'R': '100000110',
  '-': '010000101',
  '*': '010010100',
};

class _Code39Painter extends CustomPainter {
  const _Code39Painter(this.data, this.color);

  static const double _wideRatio = 2.5;

  final String data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final encoded = '*$data*'.split('').map((char) => _patterns[char]);
    final symbols = encoded.whereType<String>().toList();

    // One symbol is 3 wide and 6 narrow elements, plus a narrow gap between.
    final symbolUnits = 3 * _wideRatio + 6 + 1;
    final totalUnits = symbolUnits * symbols.length - 1;
    final narrow = (size.width / totalUnits).clamp(0.5, 2.0);
    var x = (size.width - totalUnits * narrow) / 2;

    final paint = Paint()..color = color;
    for (final pattern in symbols) {
      for (var i = 0; i < pattern.length; i++) {
        final width = narrow * (pattern[i] == '1' ? _wideRatio : 1);
        if (i.isEven) {
          canvas.drawRect(Rect.fromLTWH(x, 0, width, size.height), paint);
        }
        x += width;
      }
      x += narrow;
    }
  }

  @override
  bool shouldRepaint(_Code39Painter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}
