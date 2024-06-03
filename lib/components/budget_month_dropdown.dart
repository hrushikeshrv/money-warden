import 'package:flutter/material.dart';

class BudgetMonthDropdown extends StatefulWidget {
  const BudgetMonthDropdown({super.key});

  @override
  State<BudgetMonthDropdown> createState() => _BudgetMonthDropdownState();
}

class _BudgetMonthDropdownState extends State<BudgetMonthDropdown> {
  final TextEditingController budgetMonthController = TextEditingController();
  List<DropdownMenuEntry> budgetMonths = [
    DropdownMenuEntry(value: 'May 2024', label: "May 2024"),
    DropdownMenuEntry(value: 'June 2024', label: 'June 2024')
  ];

  @override
  initState() {
    super.initState();
    // TODO - Get the list of sheets from the Google Sheet and populate the budgetMonths list.
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          labelStyle: TextStyle(color: Colors.grey),
        ),
        controller: budgetMonthController,
        requestFocusOnTap: true,
        label: const Text('Month'),
        dropdownMenuEntries: budgetMonths
    );
  }
}
