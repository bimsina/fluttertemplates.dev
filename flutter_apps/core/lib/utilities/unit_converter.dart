import 'package:flutter/material.dart';

class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  String _selectedCategory = 'Length';
  final _inputController = TextEditingController(text: '1');

  final Map<String, List<Map<String, String>>> _categories = {
    'Length': [
      {'name': 'Meter', 'toBase': '1'},
      {'name': 'Kilometer', 'toBase': '1000'},
      {'name': 'Centimeter', 'toBase': '0.01'},
      {'name': 'Millimeter', 'toBase': '0.001'},
      {'name': 'Mile', 'toBase': '1609.34'},
      {'name': 'Yard', 'toBase': '0.9144'},
      {'name': 'Foot', 'toBase': '0.3048'},
      {'name': 'Inch', 'toBase': '0.0254'},
    ],
    'Weight': [
      {'name': 'Kilogram', 'toBase': '1'},
      {'name': 'Gram', 'toBase': '0.001'},
      {'name': 'Milligram', 'toBase': '0.000001'},
      {'name': 'Pound', 'toBase': '0.453592'},
      {'name': 'Ounce', 'toBase': '0.0283495'},
      {'name': 'Ton', 'toBase': '1000'},
    ],
    'Temperature': [
      {'name': 'Celsius', 'toBase': '1'},
      {'name': 'Fahrenheit', 'toBase': '1'},
      {'name': 'Kelvin', 'toBase': '1'},
    ],
    'Volume': [
      {'name': 'Liter', 'toBase': '1'},
      {'name': 'Milliliter', 'toBase': '0.001'},
      {'name': 'Gallon', 'toBase': '3.78541'},
      {'name': 'Quart', 'toBase': '0.946353'},
      {'name': 'Pint', 'toBase': '0.473176'},
      {'name': 'Cup', 'toBase': '0.236588'},
    ],
    'Area': [
      {'name': 'Square Meter', 'toBase': '1'},
      {'name': 'Square Kilometer', 'toBase': '1000000'},
      {'name': 'Square Foot', 'toBase': '0.092903'},
      {'name': 'Acre', 'toBase': '4046.86'},
      {'name': 'Hectare', 'toBase': '10000'},
    ],
  };

  int _fromIndex = 0;
  int _toIndex = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final units = _categories[_selectedCategory]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.keys
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _fromIndex = 0;
                      _toIndex = 1;
                      _inputController.text = '1';
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[700] : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _fromIndex,
                                  isExpanded: true,
                                  items: units
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(e.value['name']!),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _fromIndex = value!);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () {
                          setState(() {
                            final temp = _fromIndex;
                            _fromIndex = _toIndex;
                            _toIndex = temp;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[700] : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _toIndex,
                                  isExpanded: true,
                                  items: units
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(e.value['name']!),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _toIndex = value!);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _inputController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getConversionResult(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Conversions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              units.length > 5 ? 5 : units.length,
              (index) => _buildQuickConversion(
                units[index]['name']!,
                units[index + 1 < units.length ? index + 1 : 0]['name']!,
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getConversionResult() {
    if (_inputController.text.isEmpty) return '';

    final input = double.tryParse(_inputController.text) ?? 0;
    final units = _categories[_selectedCategory]!;

    double result;
    if (_selectedCategory == 'Temperature') {
      result = _convertTemperature(input, _fromIndex, _toIndex);
    } else {
      final fromFactor = double.parse(units[_fromIndex]['toBase']!);
      final toFactor = double.parse(units[_toIndex]['toBase']!);
      result = (input * fromFactor) / toFactor;
    }

    return result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 4);
  }

  double _convertTemperature(double value, int from, int to) {
    double celsius;
    switch (from) {
      case 0:
        celsius = value;
        break;
      case 1:
        celsius = (value - 32) * 5 / 9;
        break;
      case 2:
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }

    switch (to) {
      case 0:
        return celsius;
      case 1:
        return celsius * 9 / 5 + 32;
      case 2:
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  Widget _buildQuickConversion(String from, String to, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(from, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Icon(Icons.arrow_right_alt),
          Text(to, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
