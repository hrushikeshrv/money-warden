import 'package:flutter/material.dart';
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
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Heading1(text: 'Expenses by Category'),
                  ),
                  const SizedBox(height: 10),

                  budget.currentBudgetMonthData == null
                      ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
                      : AspectRatio(
                        aspectRatio: 1.5,
                        child: charts.PieChart<double>(
                          budget.currentBudgetMonthData!.getExpensesByCategorySeriesList(),
                          defaultRenderer: charts.ArcRendererConfig(
                            // arcWidth: 40,
                            arcRendererDecorators: [charts.ArcLabelDecorator()]
                          ),
                          behaviors: [
                            charts.DatumLegend(
                              position: charts.BehaviorPosition.end,
                              horizontalFirst: false,
                              showMeasures: true,
                              // legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
                              measureFormatter: (value) {
                                return value == null ? '-' : '\$$value';
                              }
                            )
                          ],
                        )
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
