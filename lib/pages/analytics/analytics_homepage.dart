import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/pages/analytics/income_trend_page.dart';
import 'package:money_warden/pages/analytics/income_vs_expenses_page.dart';
import 'package:money_warden/pages/analytics/spend_by_category_page.dart';
import 'package:money_warden/pages/analytics/spending_trend_page.dart';

class AnalyticsHomepage extends StatefulWidget {
  const AnalyticsHomepage({super.key});

  @override
  State<AnalyticsHomepage> createState() => _AnalyticsHomepageState();
}

class _AnalyticsHomepageState extends State<AnalyticsHomepage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const MwAppBar(),
          TabBar(
            dividerColor: Theme.of(context).colorScheme.surfaceDim,
            tabs: const [
              Tab(icon: Icon(Icons.pie_chart),),
              Tab(icon: Icon(Icons.area_chart),),
              Tab(icon: Icon(Icons.timeline),),
              Tab(icon: Icon(Icons.trending_up),),
            ]
          ),
          const Expanded(
            child: TabBarView(
              children: [
                SpendByCategoryPage(),
                IncomeVsExpensesPage(),
                SpendingTrendPage(),
                IncomeTrendPage(),
              ],
            ),
          )
        ]
      )
    );
  }
}
