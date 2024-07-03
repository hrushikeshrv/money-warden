import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        return Scaffold(
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
              child: Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Heading1(text: '$transactionType Categories'),
                    ),
                    const SizedBox(height: 10),
                    const MwWarning(
                      children: [
                        Text('Deleting expense or income categories is not yet supported. You can only create new categories and change the color of an existing category.')
                      ]
                    ),
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
