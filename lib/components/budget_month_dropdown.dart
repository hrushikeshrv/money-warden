import 'package:flutter/material.dart';

List<String> budgetMonths = [
  "May 2024",
  "June 2024",
];

class BudgetMonthDropdown extends StatefulWidget {
  const BudgetMonthDropdown({super.key});

  @override
  State<BudgetMonthDropdown> createState() => _BudgetMonthDropdownState();
}

class _BudgetMonthDropdownState extends State<BudgetMonthDropdown> {
  final TextEditingController budgetMonthController = TextEditingController();

  String? _currentBudgetMonth = budgetMonths.first;

  void setCurrentBudgetMonth(String? value) {
    setState(() {
      _currentBudgetMonth = value;
    });
  }

  @override
  initState() {
    super.initState();
    // TODO - Get the list of sheets from the Google Sheet and populate the budgetMonths list.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton<String>(
        items: budgetMonths.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)));
        }).toList(),
        value: _currentBudgetMonth,
        onChanged: setCurrentBudgetMonth,
        iconEnabledColor: Theme.of(context).colorScheme.primary,
        // isExpanded: true,
      ),
    );
  }
}
