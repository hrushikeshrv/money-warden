import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/budget_month_dropdown.dart';
import 'package:money_warden/components/budget_initialization_failed_alert.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/components/transaction_tile.dart';
import 'package:money_warden/models/budget_sheet.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        if (budget.budgetInitializationFailed) {
          return const BudgetInitializationFailedAlert();
        }

        return Column(
          children: [
            const MwAppBar(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  budget.currentBudgetMonthData != null  && budget.currentBudgetMonthData!.recentTransactions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(child: Text('No transactions yet 💸', style: TextStyle(fontSize: 17))),
                        )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: budget.currentBudgetMonthData == null ? 0 : budget.currentBudgetMonthData!.orderedTransactions.length,
                        itemBuilder: (context, index) {
                          return TransactionTile(transaction: budget.currentBudgetMonthData?.orderedTransactions[index]);
                        },
                      ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
