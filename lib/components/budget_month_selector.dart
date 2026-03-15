import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/components/mw_alert_dialog.dart';
import 'package:money_warden/pages/add_budget_month_to_spreadsheet.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';

class BudgetMonthSelector extends StatefulWidget {
  const BudgetMonthSelector({super.key});

  @override
  State<BudgetMonthSelector> createState() => _BudgetMonthSelectorState();
}

class _BudgetMonthSelectorState extends State<BudgetMonthSelector> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budgetSheet, child) {
        List<String> budgetMonths = budgetSheet.budgetMonthNames;
        return GestureDetector(
          child: Row(
            children: [
              Text(
                budgetSheet.currentBudgetMonthName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26
                ),
              ),
              const SizedBox(width: 5,),
              Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.primary,)
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                return MwAlertDialog(
                  title: Text("Choose month"),
                  content: ListView(
                    shrinkWrap: true,
                    children: budgetMonths.map((month) {
                      return ListTile(
                        leading: month == budgetSheet.currentBudgetMonthName ? Icon(Icons.check) : Icon(Icons.calendar_month_outlined),
                        title: Text(month),
                        contentPadding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                        onTap: () {
                          budgetSheet.setCurrentBudgetMonth(month);
                          Navigator.of(context).pop();
                        }
                      );
                    }).toList(),
                  ),
                  actions: [
                    MwActionButton(
                      leading: Icon(Icons.add),
                      text: "Create new month",
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const FractionallySizedBox(
                              heightFactor: 0.85,
                              child: AddBudgetMonthToSpreadsheetPage()
                            );
                          }
                        );
                      }
                    )
                  ]
                );
              }
            );
          }
        );
      }
    );
  }
}
