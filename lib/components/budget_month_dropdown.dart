import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';

class BudgetMonthDropdown extends StatefulWidget {
  const BudgetMonthDropdown({super.key});

  @override
  State<BudgetMonthDropdown> createState() => _BudgetMonthDropdownState();
}

class _BudgetMonthDropdownState extends State<BudgetMonthDropdown> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budgetSheet, child) {
        List<String> budgetMonths = budgetSheet.budgetMonthNames;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<String>(
            items: budgetMonths.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem(value: value,
                  child: Text(value, style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold)));
            }).toList(),
            value: budgetSheet.currentBudgetMonthName,
            onChanged: budgetSheet.setCurrentBudgetMonthName,
            iconEnabledColor: Theme
                .of(context)
                .colorScheme
                .primary,
            // isExpanded: true,
          ),
        );
      }
    );
  }
}
