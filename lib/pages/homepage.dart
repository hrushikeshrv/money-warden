import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/budget_month_dropdown.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/models/budget_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        double? amountSpent = budget.currentBudgetMonthData?.monthExpenseAmount;
        double? amountEarned = budget.currentBudgetMonthData?.monthIncomeAmount;
        double? difference = budget.currentBudgetMonthData?.monthDifferenceAmount;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const MwAppBar(
                text: 'Money Warden', assetImagePath: 'assets/images/logo.png'),
            const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BudgetMonthDropdown()
                ]
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround ,
                children: [
                  Column(
                    children: [
                      amountSpent == null ?
                        const CircularProgressIndicator()
                      : Text("\$$amountSpent", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                      const Text("Spent"),
                    ],
                  ),
                  Column(
                    children: [
                      amountEarned == null ?
                        const CircularProgressIndicator()
                      : Text("\$$amountEarned", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                      const Text("Earned"),
                    ],
                  ),
                  Column(
                    children: [
                      difference == null ?
                        const CircularProgressIndicator()
                      : Text("${difference > 0 ? '+' : ''}\$$difference",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                      const Text("Difference"),
                    ],
                  )
                ]
              ),
            )
          ],
        );
      }
    );
  }
}
