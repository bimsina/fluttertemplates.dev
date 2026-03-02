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

  void _onButtonPressed(String label) {
    setState(() {
      switch (label) {
        case 'C':
          _display = '0';
          _expression = '';
          _firstOperand = 0;
          _operator = '';
          _shouldResetDisplay = false;
          break;
        case '⌫':
          if (_display.length > 1) {
            _display = _display.substring(0, _display.length - 1);
          } else {
            _display = '0';
          }
          break;
        case '%':
          _display = (double.parse(_display) / 100).toString();
          break;
        case '±':
          _display = (double.parse(_display) * -1).toString();
          break;
        case '÷':
        case '×':
        case '-':
        case '+':
          _firstOperand = double.parse(_display);
          _operator = label;
          _expression = '$_display $label';
          _shouldResetDisplay = true;
          break;
        case '=':
          if (_operator.isNotEmpty) {
            final secondOperand = double.parse(_display);
            double result;
            switch (_operator) {
              case '÷':
                result = _firstOperand / secondOperand;
                break;
              case '×':
                result = _firstOperand * secondOperand;
                break;
              case '-':
                result = _firstOperand - secondOperand;
                break;
              case '+':
                result = _firstOperand + secondOperand;
                break;
              default:
                result = 0;
            }
            _expression = '$_firstOperand $_operator $secondOperand =';
            _display = result.truncateToDouble() == result
                ? result.toInt().toString()
                : result.toString();
            _operator = '';
            _shouldResetDisplay = true;
          }
          break;
        default:
          if (_shouldResetDisplay) {
            _display = label;
            _shouldResetDisplay = false;
          } else {
            _display = _display == '0' ? label : _display + label;
          }
      }
    });
  }
}
