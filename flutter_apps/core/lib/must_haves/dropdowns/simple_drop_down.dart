import 'package:flutter/material.dart';

class SimpleDropDown extends StatefulWidget {
  const SimpleDropDown({super.key});

  @override
  State<SimpleDropDown> createState() => _SimpleDropDownState();
}

class _SimpleDropDownState extends State<SimpleDropDown> {
  String? _selectedFruit;
  final List<String> _fruits = [
    '🍎 Apple',
    '🍋 Mango',
    '🍌 Banana',
    '🍉 Watermelon',
    '🍇 Grapes',
    '🍓 Strawberry',
    '🍒 Cherries',
    '🍑 Peach',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _title("Simple Dropdown"),
                _dropDown(),
                _title("Outlined Dropdown"),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _dropDown(underline: Container()),
                ),
                _title("Custom Dropdown"),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _dropDown(
                    underline: Container(),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: Colors.red,
                    iconEnabledColor: Colors.white,
                    hintStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String val) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _dropDown({
    Widget? underline,
    Widget? icon,
    TextStyle? style,
    TextStyle? hintStyle,
    Color? dropdownColor,
    Color? iconEnabledColor,
  }) => DropdownButton<String>(
    value: _selectedFruit,
    underline: underline,
    icon: icon,
    dropdownColor: dropdownColor,
    style: style,
    iconEnabledColor: iconEnabledColor,
    onChanged: (String? newValue) {
      setState(() {
        _selectedFruit = newValue;
      });
    },
    hint: Text("Select a fruit", style: hintStyle),
    items: _fruits
        .map(
          (fruit) => DropdownMenuItem<String>(value: fruit, child: Text(fruit)),
        )
        .toList(),
  );
}
