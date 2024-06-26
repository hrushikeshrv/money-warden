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
          children: [
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      amountSpent == null ?
                        const CircularProgressIndicator()
                      : Text("\$$amountSpent", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                      const Text("Spent"),
                    ],
                  ),
                  Column(
                    children: [
                      amountEarned == null ?
                        const CircularProgressIndicator()
                      : Text("\$$amountEarned", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                      const Text("Earned"),
                    ],
                  ),
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      // The trending up or trending down icon
                      difference == null ?
                          const Text('-')
                          : difference > 0 ? Icon(Icons.trending_up, color: Colors.green.shade500) : Icon(Icons.trending_down, color: Colors.red.shade600),
                      const SizedBox(width: 5),

                      // The actual value
                      difference == null ?
                          const SizedBox(height: 15, width: 15, child: Center(child: CircularProgressIndicator()))
                          : Text("${difference > 0 ? '+' : '-'}\$${difference.abs()}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: difference > 0 ? Colors.green.shade500 : Colors.red.shade600
                          )
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'See all transactions',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).colorScheme.primary,
                          size: 14
                        )
                      ],
                    )
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
