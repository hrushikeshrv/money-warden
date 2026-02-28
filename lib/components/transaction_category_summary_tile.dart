import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_warden/components/transaction_tile.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/category.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:money_warden/theme/theme.dart';


/// A tile showing the user how much money they have
/// spent on a particular category
class TransactionCategorySummaryTile extends StatelessWidget {
  final String categoryName;
  final double amount;
  final double percentSpent;
  const TransactionCategorySummaryTile({
    super.key,
    required this.categoryName,
    required this.amount,
    required this.percentSpent
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MwColors>()!;

    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        Category? category = budget.getCategoryByName(categoryName);
        List<Transaction> categoryTransactions = (category == null
            ? []
            : budget.currentBudgetMonthData!.getTransactionsByCategory(category)
        );
        List<TransactionTile> categoryTransactionTiles = categoryTransactions.map(
          (txn) => TransactionTile(transaction: txn,)
        ).toList();

        return ExpansionTile(
          leading: Stack(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                    value: percentSpent
                ),
              ),
              const Positioned(
                left: 10,
                top: 8,
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Icon(Icons.payments_outlined),
                ),
              )
            ],
          ),
          title: Text(categoryName),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${categoryTransactions.length} transaction${categoryTransactions.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: colors.mutedText
                ),
              ),
              Text('${(percentSpent * 100).toStringAsFixed(1)}% of total')
            ],
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.surface)
          ),
          trailing: Text('${budget.defaultCurrencySymbol}${formatMoney(amount)}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),),
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.backgroundDark1,
                borderRadius: BorderRadius.circular(10)
              ),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Column(
                children: categoryTransactionTiles,
              )
            )
          ],
        );
      }
    );
  }
}
