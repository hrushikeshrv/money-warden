import 'package:flutter/material.dart';

import 'package:money_warden/models/category.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/pages/transaction_category_update.dart';


class CategoryTile extends StatelessWidget {
  final Category category;
  final TransactionType transactionType;
  const CategoryTile({super.key, required this.category, required this.transactionType});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: category.backgroundColor ?? Colors.grey.shade400,
          ),
        ),
      ),
      title: Text(category.name),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return FractionallySizedBox(
                heightFactor: 0.85,
                child: TransactionCategoryUpdatePage(transactionCategory: category, transactionType: transactionType)
            );
          }
        );
      },
    );
  }
}
