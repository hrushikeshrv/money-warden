import 'package:flutter/material.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';

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
        return Container();
      },
    );
  }
}
