import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _display = '0';
  String _expression = '';
  double _firstOperand = 0;
  String _operator = '';
  bool _shouldResetDisplay = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _display,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildRow(['C', '⌫', '%', '÷'], isDark),
                  _buildRow(['7', '8', '9', '×'], isDark),
                  _buildRow(['4', '5', '6', '-'], isDark),
                  _buildRow(['1', '2', '3', '+'], isDark),
                  _buildRow(['±', '0', '.', '='], isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> buttons, bool isDark) {
    return Expanded(
      child: Row(
        children: buttons.map((btn) => _buildButton(btn, isDark)).toList(),
      ),
    );
  }

  Widget _buildButton(String label, bool isDark) {
    final isOperator = ['÷', '×', '-', '+', '='].contains(label);
    final isFunction = ['C', '⌫', '%', '±'].contains(label);

    Color backgroundColor;
    Color textColor;

    if (isOperator) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
    } else if (isFunction) {
      backgroundColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
      textColor = isDark ? Colors.white : Colors.black87;
    } else {
      backgroundColor = isDark ? Colors.grey[800]! : Colors.white;
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _onButtonPressed(label),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: label == 'C' ? 20 : 28,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _errorText = 'Error';

  bool get _hasError => _display == _errorText;

  void _clear() {
    _display = '0';
    _expression = '';
    _firstOperand = 0;
    _operator = '';
    _shouldResetDisplay = false;
  }

  /// Returns null when the result can't be shown, such as dividing by zero.
  double? _calculate(double first, String op, double second) {
    final result = switch (op) {
      '÷' => second == 0 ? double.nan : first / second,
      '×' => first * second,
      '-' => first - second,
      '+' => first + second,
      _ => second,
    };
    return result.isFinite ? result : null;
  }

  String _format(double value) {
    // 12 significant digits hides float noise such as 0.1 + 0.2.
    final rounded = double.parse(value.toStringAsPrecision(12));
    final isWhole = rounded == rounded.truncateToDouble();
    return isWhole && rounded.abs() < 1e15
        ? rounded.toInt().toString()
        : rounded.toString();
  }

  void _showError() {
    _clear();
    _display = _errorText;
  }

  /// Evaluates the pending operation into the display.
  /// Returns false when that produced an error.
  bool _evaluatePending({required bool showExpression}) {
    final second = double.parse(_display);
    final result = _calculate(_firstOperand, _operator, second);
    if (result == null) {
      _showError();
      return false;
    }
    if (showExpression) {
      _expression =
          '${_format(_firstOperand)} $_operator ${_format(second)} =';
    }
    _display = _format(result);
    return true;
  }

  void _pressOperator(String label) {
    final hasNewOperand = _operator.isNotEmpty && !_shouldResetDisplay;
    if (hasNewOperand && !_evaluatePending(showExpression: false)) return;
    _firstOperand = double.parse(_display);
    _operator = label;
    _expression = '$_display $label';
    _shouldResetDisplay = true;
  }

  void _pressEquals() {
    if (_operator.isEmpty) return;
    if (_evaluatePending(showExpression: true)) {
      _operator = '';
      _shouldResetDisplay = true;
    }
  }

  void _pressDot() {
    if (_shouldResetDisplay) {
      _display = '0.';
      _shouldResetDisplay = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void _pressBackspace() {
    if (_shouldResetDisplay) return;
    final shortened = _display.substring(0, _display.length - 1);
    _display = shortened.isEmpty || shortened == '-' ? '0' : shortened;
  }

  void _pressDigit(String label) {
    if (_shouldResetDisplay) {
      _display = label;
      _shouldResetDisplay = false;
    } else {
      _display = _display == '0' ? label : _display + label;
    }
  }

  void _onButtonPressed(String label) {
    setState(() {
      if (_hasError) {
        // Only clearing or starting a new number leaves the error state.
        final startsNumber = label == '.' || int.tryParse(label) != null;
        if (label != 'C' && !startsNumber) return;
        _clear();
      }
      switch (label) {
        case 'C':
          _clear();
        case '⌫':
          _pressBackspace();
        case '%':
          _display = _format(double.parse(_display) / 100);
        case '±':
          _display = _display.startsWith('-')
              ? _display.substring(1)
              : (_display == '0' ? '0' : '-$_display');
        case '÷':
        case '×':
        case '-':
        case '+':
          _pressOperator(label);
        case '=':
          _pressEquals();
        case '.':
          _pressDot();
        default:
          _pressDigit(label);
      }
    });
  }
}
