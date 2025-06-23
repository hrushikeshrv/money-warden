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
  final TextEditingController controller = TextEditingController();

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
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: TextField(
                controller: controller,
                onChanged: (String query) {
                  budget.filterTransactions(query);
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Row(
                    children: [
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
                      const SizedBox(width: 5,),
                      Text("Filter transactions", style: TextStyle(color: Theme.of(context).colorScheme.onSurface))
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                ),
              ),
            ),
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
                        itemCount: budget.currentBudgetMonthData == null ? 0 : budget.currentBudgetMonthData!.filteredTransactions.length,
                        itemBuilder: (context, index) {
                          return TransactionTile(transaction: budget.currentBudgetMonthData?.filteredTransactions[index]);
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
