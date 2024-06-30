import 'package:flutter/material.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:money_warden/components/budget_month_dropdown.dart';
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
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Heading1(text: 'Expenses by Category'),
                  ),

                  budget.currentBudgetMonthData == null
                      ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
                      : AspectRatio(
                        aspectRatio: 1.2,
                        child: PieChart(
                          PieChartData(
                            sections: budget.currentBudgetMonthData!.getExpensesByCategorySectionData(),
                            centerSpaceRadius: 0,
                          )
                        ),
                      )
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}
