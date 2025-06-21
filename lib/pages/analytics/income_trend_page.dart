import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:community_charts_common/community_charts_common.dart' as chartsCommon;

class IncomeTrendPage extends StatelessWidget {
  const IncomeTrendPage({super.key});

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
        List<MonthlyIncome> data = [];
        List<Widget> spendTiles = [];
        for (int i = 0; i < lastSixMonths.length; i++) {
          String month = lastSixMonths[i];
          if (budget.budgetData.containsKey(month)) {
            data.add(MonthlyIncome(
              getDateFromMonthName(month),
              budget.budgetData[month]!.monthIncomeAmount,
            ));
            double change = 0;
            if (i < lastSixMonths.length - 1) {
              double curr = budget.budgetData[month]?.monthIncomeAmount ?? 0;
              double prev = (budget.budgetData[lastSixMonths[i+1]]?.monthIncomeAmount ?? 0);
              change = (curr - prev) * 100 / prev;
              if (change.isInfinite) change = 100;
              if (change.isNaN) change = 0;
            }
            spendTiles.add(ListTile(
              leading: const Icon(Icons.savings_outlined),
              title: Text(month),
              subtitle: Row(
                children: [
                  change > 0
                      ? Icon(Icons.arrow_upward, size: 12, color: change > 0 ? Colors.green.shade500 : Colors.red.shade600,)
                      : change == 0
                          ?  const Icon(Icons.remove, size: 12)
                          : Icon(Icons.arrow_downward, size: 12, color: change > 0 ? Colors.green.shade500 : Colors.red.shade600,),
                  Text(
                    '${change.abs().toStringAsFixed(2)}% ${change > 0 ? "increase" : change == 0 ? "no change" : "decrease"}',
                    style: TextStyle(
                      color: change > 0
                          ? Colors.green.shade600
                          : change == 0
                              ? Colors.black
                              : Colors.red.shade600
                    ),
                  ),
                ],
              ),
              trailing: Text(
                budget.defaultCurrencySymbol + formatMoney(budget.budgetData[month]!.monthIncomeAmount),
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface
                ),
              ),
            ));
          }
        }
        data = data.reversed.toList();
        final s = [charts.Series<MonthlyIncome, DateTime>(
            id: 'Income by month',
            domainFn: (MonthlyIncome s, _) => s.month,
            measureFn: (MonthlyIncome s, _) => s.income,
            labelAccessorFn: (MonthlyIncome s, _) => getMonthNameFromDate(s.month, true),
            colorFn: (MonthlyIncome s, __) {
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
                        'Income over last 6 months',
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

class MonthlyIncome {
  final double income;
  final DateTime month;
  MonthlyIncome(this.month, this.income);
}
