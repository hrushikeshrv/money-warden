import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/category_tile.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_warning.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/transaction.dart';


class TransactionCategoriesList extends StatefulWidget {
  final TransactionType transactionType;
  const TransactionCategoriesList({super.key, required this.transactionType});

  @override
  State<TransactionCategoriesList> createState() => _TransactionCategoriesListState();
}

class _TransactionCategoriesListState extends State<TransactionCategoriesList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        String transactionType = widget.transactionType == TransactionType.expense ? 'Expense' : 'Income';
        int categoryCount = widget.transactionType == TransactionType.expense ? budget.expenseCategories.length : budget.incomeCategories.length;
        return Scaffold(
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Heading1(text: '$transactionType Categories'),
                    ),
                    const SizedBox(height: 10),
                    const MwWarning(
                      children: [
                        Text('Deleting expense or income categories is not yet supported. You can only create new categories and change an existing category.')
                      ]
                    ),
                    const SizedBox(height: 20),
                    MwActionButton(
                      leading: widget.transactionType == TransactionType.expense ? const Icon(Icons.payments_outlined) : const Icon(Icons.savings_outlined),
                      text: 'Add $transactionType Category',
                      onTap: () {}
                    ),

                    const SizedBox(height: 20),
                    ListView.builder(
                      itemCount: categoryCount,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (widget.transactionType == TransactionType.expense) {
                          return CategoryTile(category: budget.expenseCategories[index]);
                        }
                        else {
                          return CategoryTile(category: budget.incomeCategories[index]);
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
