import 'package:flutter/material.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

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
        List<Spend> data = [];
        int idx = 0;
        for (String month in lastSixMonths) {
          if (budget.budgetData.containsKey(month)) {
            data.add(Spend(
              idx++,
              budget.budgetData[month]!.monthExpenseAmount,
              month
            ));
          }
        }
        final s = charts.Series<Spend, double>(
          id: 'Expenses by month',
          domainFn: (Spend s, _) => s.spend,
          measureFn: (Spend s, _) => s.spend,
          labelAccessorFn: (Spend s, _) => s.monthName,
          colorFn: (Spend s, __) {
            Color c = getRandomGraphColor();
            return Color(
              r: c.red,
              g: c.green,
              b: c.blue
            );
          },
          data: data
        );
        return Column(
          children: [
            charts.LineChart(
              s
            )
          ],
        );
      },
    );
  }
}

class Spend {
  final double spend;
  final int index;
  final String monthName;
  Spend(this.index, this.spend, this.monthName);
}