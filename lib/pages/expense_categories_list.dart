import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/transaction.dart';


class ExpenseCategoriesList extends StatefulWidget {
  final TransactionType transactionType;
  const ExpenseCategoriesList({super.key, required this.transactionType});

  @override
  State<ExpenseCategoriesList> createState() => _ExpenseCategoriesListState();
}

class _ExpenseCategoriesListState extends State<ExpenseCategoriesList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return Container();
      },
    );
  }
}
