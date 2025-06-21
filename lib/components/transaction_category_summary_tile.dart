import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';


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
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) => ListTile(
        leading: Stack(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
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
        subtitle: Text('${(percentSpent * 100).toStringAsFixed(1)}% of total'),
        trailing: Text('${budget.defaultCurrencySymbol}${formatMoney(amount)}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),),
      ),
    );
  }
}
