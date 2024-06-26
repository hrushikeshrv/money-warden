import 'package:flutter/material.dart';
import 'package:money_warden/components/budget_month_dropdown.dart';
import 'package:money_warden/components/mw_app_bar.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MwAppBar(assetImagePath: 'assets/images/logo.png', child: BudgetMonthDropdown()),
        Column(
          children: [
            Center(
                child: Text("Analytics Page")
            ),
          ],
        ),
      ],
    );
  }
}
