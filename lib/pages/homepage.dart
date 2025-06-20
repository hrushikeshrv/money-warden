import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/components/transaction_tile.dart';
import 'package:money_warden/components/budget_initialization_failed_alert.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/pages/transaction_add.dart';
import 'package:money_warden/utils/utils.dart';


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

        if (budget.budgetInitializationFailed) {
          return const BudgetInitializationFailedAlert();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MwAppBar(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              amountSpent == null ?
                              const CircularProgressIndicator()
                                  : Text(
                                      "${budget.defaultCurrencySymbol}${formatMoney(amountSpent)}",
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)
                                  ),
                              const Text("Spent"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              amountEarned == null ?
                              const CircularProgressIndicator()
                                  : Text("${budget.defaultCurrencySymbol}${formatMoney(amountEarned)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                              const Text("Earned"),
                            ],
                          ),
                        ),
                      ]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              difference == null ?
                              const CircularProgressIndicator()
                                  : Text("${difference > 0 ? '+ ' : difference < 0 ? '- ' : ''}${budget.defaultCurrencySymbol}${formatMoney(difference.abs())}",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: difference > 0 ? Colors.green.shade500 : Colors.red.shade600
                                  )
                              ),
                              const Text("Balance"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
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
                              const Text("% Spent"),
                            ],
                          ),
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
                        onTap: () {
                          showAddTransactionBottomSheet(context: context, transactionType: TransactionType.expense);
                        }
                      ),
                      const SizedBox(width: 30),
                      MwActionButton(
                        leading: const Icon(Icons.savings_outlined),
                        text: 'Add Income',
                        onTap: () {
                          showAddTransactionBottomSheet(context: context, transactionType: TransactionType.income);
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Heading1(text: 'Recent Transactions'),
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: budget.currentBudgetMonthData != null && budget.currentBudgetMonthData!.recentTransactions.isEmpty
                        ? const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(child: Text('No transactions yet 💸', style: TextStyle(fontSize: 17))),
                        )
                        : ListView.builder(
                          itemCount: budget.currentBudgetMonthData == null ? 0 : budget.currentBudgetMonthData!.recentTransactions.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return TransactionTile(transaction: budget.currentBudgetMonthData?.recentTransactions[index]);
                          },
                        ),
                  ),

                  // To make sure content isn't overlapped by the FAB
                  const SizedBox(height: 70),
                ]
              ),
            )
          ],
        );
      }
    );
  }
}
