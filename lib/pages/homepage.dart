import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/shared.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/components/mw_form_label.dart';
import 'package:money_warden/components/transaction_tile.dart';
import 'package:money_warden/utils.dart';
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
        double? percentSpent = budget.currentBudgetMonthData?.percentIncomeSpent;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MwAppBar(
              assetImagePath: 'assets/images/logo.png',
              child: BudgetMonthDropdown()
            ),
            ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          amountSpent == null ?
                          const CircularProgressIndicator()
                              : Text("\$${formatMoney(amountSpent)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                          const Text("Spent"),
                        ],
                      ),
                      const SizedBox(width: 50),
                      Column(
                        children: [
                          amountEarned == null ?
                          const CircularProgressIndicator()
                              : Text("\$${formatMoney(amountEarned)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                          const Text("Earned"),
                        ],
                      ),
                    ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              difference == null ?
                              const CircularProgressIndicator()
                                  : Text("${difference > 0 ? '+ ' : '- '}\$${formatMoney(difference.abs())}",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: difference > 0 ? Colors.green.shade500 : Colors.red.shade600
                                  )
                              ),
                            ],
                          ),
                          const Text("Balance"),
                        ],
                      ),
                      const SizedBox(width: 60),
                      Column(
                        children: [
                          Row(
                            children: [
                              percentSpent == null ?
                              const CircularProgressIndicator()
                                  : Text("$percentSpent %",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: percentSpent < 90.0 ? Colors.green.shade500 : Colors.red.shade600
                                  )
                              ),
                            ],
                          ),
                          const Text("% Spent"),
                        ],
                      ),
                    ]
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MwActionButton(
                        leading: const Icon(Icons.payments_outlined),
                        text: 'Add Expense',
                        onTap: () {}
                    ),
                    const SizedBox(width: 30),
                    MwActionButton(
                        leading: const Icon(Icons.savings_outlined),
                        text: 'Add Income',
                        onTap: () {}
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Heading1(text: 'Recent Transactions'),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Text(
                              'See all',
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
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                ListView.builder(
                  itemCount: budget.currentBudgetMonthData == null ? 0 : budget.currentBudgetMonthData!.recentTransactions.length,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return TransactionTile(transaction: budget.currentBudgetMonthData?.recentTransactions[index]);
                  },
                )
              ]
            )
          ],
        );
      }
    );
  }
}
