import 'package:flutter/material.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:community_charts_common/community_charts_common.dart' as chartsCommon;

class IncomeVsExpensesPage extends StatelessWidget {
  const IncomeVsExpensesPage({super.key});

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
        List<BudgetEntry> incomeData = [];
        List<BudgetEntry> expenseData = [];
        List<Widget> spendTiles = [];
        for (int i = 0; i < lastSixMonths.length; i++) {
          String month = lastSixMonths[i];
          if (budget.budgetData.containsKey(month)) {
            incomeData.add(BudgetEntry(
              getDateFromMonthName(month),
              budget.budgetData[month]!.monthIncomeAmount,
            ));
            expenseData.add(BudgetEntry(
              getDateFromMonthName(month),
              budget.budgetData[month]!.monthExpenseAmount,
            ));
            double incomeChange = 0;
            double expenseChange = 0;
            if (i < lastSixMonths.length - 1) {
              double currIncome = budget.budgetData[month]?.monthIncomeAmount ?? 0;
              double prevIncome = (budget.budgetData[lastSixMonths[i+1]]?.monthIncomeAmount ?? 0);
              double currExpense = budget.budgetData[month]?.monthExpenseAmount ?? 0;
              double prevExpense = (budget.budgetData[lastSixMonths[i+1]]?.monthExpenseAmount ?? 0);
              incomeChange = (currIncome - prevIncome) * 100 / prevIncome;
              expenseChange = (currExpense - prevExpense) * 100 / prevExpense;
              if (incomeChange.isInfinite) incomeChange = 100;
              if (incomeChange.isNaN) incomeChange = 0;
              if (expenseChange.isInfinite) expenseChange = 100;
              if (expenseChange.isNaN) expenseChange = 0;
            }
            double spendDiff = budget.budgetData[month]!.monthDifferenceAmount;
            spendTiles.add(ListTile(
              leading: const Icon(Icons.account_balance),
              title: Text(month),
              subtitle: Row(
                children: [
                  Icon(Icons.payments_outlined, size: 14, color: expenseChange > 0 ? Colors.red.shade500 : expenseChange == 0 ? Colors.black : Colors.green.shade600,),
                  expenseChange > 0
                      ? Icon(Icons.arrow_upward, size: 12, color: expenseChange > 0 ? Colors.red.shade500 : Colors.green.shade600,)
                      : expenseChange == 0
                      ?  const Icon(Icons.remove, size: 12)
                      : Icon(Icons.arrow_downward, size: 12, color: expenseChange > 0 ? Colors.red.shade500 : Colors.green.shade600,),
                  Text(
                    '${expenseChange.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                        color: expenseChange > 0
                            ? Colors.red.shade600
                            : expenseChange == 0
                            ? Colors.black
                            : Colors.green.shade600
                    ),
                  ),
                  const Text(" · "),
                  Icon(Icons.savings_outlined, size: 14, color: incomeChange > 0 ? Colors.green.shade500 : incomeChange == 0 ? Colors.black : Colors.red.shade600,),
                  incomeChange > 0
                      ? Icon(Icons.arrow_upward, size: 12, color: incomeChange > 0 ? Colors.green.shade500 : Colors.red.shade600,)
                      : incomeChange == 0
                      ?  const Icon(Icons.remove, size: 12)
                      : Icon(Icons.arrow_downward, size: 12, color: incomeChange > 0 ? Colors.green.shade500 : Colors.red.shade600,),
                  Text(
                    '${incomeChange.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                        color: incomeChange > 0
                            ? Colors.green.shade600
                            : incomeChange == 0
                            ? Colors.black
                            : Colors.red.shade600
                    ),
                  ),
                ],
              ),
              trailing: Text(
                budget.defaultCurrencySymbol + formatMoney(spendDiff),
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: spendDiff > 0 ? Colors.green.shade500 : Colors.red.shade600
                ),
              ),
            ));
          }
        }
        incomeData = incomeData.reversed.toList();
        final s = [
          charts.Series<BudgetEntry, DateTime>(
            id: 'Income by month',
            domainFn: (BudgetEntry s, _) => s.month,
            measureFn: (BudgetEntry s, _) => s.amount,
            labelAccessorFn: (BudgetEntry s, _) => getMonthNameFromDate(s.month, true),
            colorFn: (BudgetEntry s, __) {
              Color c = const Color(0xFF43A047);
              return chartsCommon.Color(
                  r: c.red,
                  g: c.green,
                  b: c.blue
              );
            },
            data: incomeData
          ),
          charts.Series<BudgetEntry, DateTime>(
            id: 'Expense by month',
              domainFn: (BudgetEntry s, _) => s.month,
              measureFn: (BudgetEntry s, _) => s.amount,
              labelAccessorFn: (BudgetEntry s, _) => getMonthNameFromDate(s.month, true),
              colorFn: (BudgetEntry s, __) {
                Color c = Colors.red.shade600;
                return chartsCommon.Color(
                    r: c.red,
                    g: c.green,
                    b: c.blue
                );
              },
              data: expenseData
          )
        ];
        return Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Center(
                      child: Text(
                        'Income vs expenses over last 6 months',
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
                          strokeWidthPx: 3,
                          includeArea: true
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

class BudgetEntry {
  final double amount;
  final DateTime month;
  BudgetEntry(this.month, this.amount);
}
