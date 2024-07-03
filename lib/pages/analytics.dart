import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_warden/components/transaction_category_summary_tile.dart';
import 'package:money_warden/models/budget_month.dart';
import 'package:provider/provider.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

import 'package:money_warden/components/budget_month_dropdown.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/models/budget_sheet.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return Column(
          children: [
            const MwAppBar(assetImagePath: 'assets/images/logo.png', child: BudgetMonthDropdown()),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  budget.currentBudgetMonthData == null
                      ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
                      : AspectRatio(
                        aspectRatio: 1,
                        child: charts.PieChart<double>(
                          budget.currentBudgetMonthData!.getExpensesByCategorySeriesList(budget.sharedPreferences!),
                          defaultRenderer: charts.ArcRendererConfig(
                            arcRendererDecorators: [charts.ArcLabelDecorator()]
                          ),
                        ),
                      ),

                  const SizedBox(height: 10),
                  budget.currentBudgetMonthData == null
                      ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
                      : ListView(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        children: budget.currentBudgetMonthData!.getExpensesByCategory().map(
                            (CategorySpend spend) {
                              return TransactionCategorySummaryTile(
                                categoryName: spend.name,
                                amount: spend.amount,
                                percentSpent: (spend.amount / budget.currentBudgetMonthData!.monthExpenseAmount)
                              );
                            }
                        ).toList(),
                  ),

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}
