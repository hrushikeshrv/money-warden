import 'package:flutter/material.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:community_charts_common/community_charts_common.dart' as chartsCommon;

class SpendingTrendPage extends StatelessWidget {
  const SpendingTrendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        if (!budget.lastSixMonthDataLoaded()) {
          budget.getLastSixMonthData();
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(width: 15),
                  Text("Loading data from last 6 months")
                ],
              ),
            ],
          );
        }

        List<String> lastSixMonths = getLastSixMonths(getCurrentMonthName());
        List<MonthlySpend> data = [];
        List<Widget> spendTiles = [];
        for (String month in lastSixMonths) {
          if (budget.budgetData.containsKey(month)) {
            data.add(MonthlySpend(
              getDateFromMonthName(month),
              budget.budgetData[month]!.monthExpenseAmount,
            ));
            spendTiles.add(ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text(month),
              trailing: Text(
                budget.defaultCurrencySymbol + formatMoney(budget.budgetData[month]!.monthExpenseAmount),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface
                ),
              ),
            ));
          }
        }
        data = data.reversed.toList();
        final s = [charts.Series<MonthlySpend, DateTime>(
          id: 'Expenses by month',
          domainFn: (MonthlySpend s, _) => s.month,
          measureFn: (MonthlySpend s, _) => s.spend,
          labelAccessorFn: (MonthlySpend s, _) => getMonthNameFromDate(s.month, true),
          colorFn: (MonthlySpend s, __) {
            Color c = const Color(0xFF43A047);
            return chartsCommon.Color(
              r: c.red,
              g: c.green,
              b: c.blue
            );
          },
          data: data
        )];
        return Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Center(
                    child: Text(
                      'Expenses over last 6 months',
                      style: TextStyle(
                        fontSize: 10
                      ),
                    )
                  ),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: charts.TimeSeriesChart(
                      s,
                      domainAxis: const charts.DateTimeAxisSpec(
                        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                          month: charts.TimeFormatterSpec(
                            format: 'MMM',
                            transitionFormat: 'MMM yyyy',
                          )
                        )
                      ),
                      defaultRenderer: charts.LineRendererConfig(
                        strokeWidthPx: 3
                      ),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        tickFormatterSpec: charts.BasicNumericTickFormatterSpec((num? value) {
                          if (value == null) return '';
                          return '${budget.defaultCurrencySymbol} ${value.toStringAsFixed(0)}';
                        })
                      ),
                      behaviors: [
                        charts.SelectNearest(eventTrigger: charts.SelectionTrigger.tap),
                        charts.LinePointHighlighter(
                          symbolRenderer: charts.CircleSymbolRenderer(),
                        ),
                      ],
                    )
                  ),

                  const SizedBox(height: 20),
                  ...spendTiles,
                  const SizedBox(height: 70),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

class MonthlySpend {
  final double spend;
  final DateTime month;
  MonthlySpend(this.month, this.spend);
}