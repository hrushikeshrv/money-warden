import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:money_warden/pages/analytics.dart';
import 'package:money_warden/pages/homepage.dart';
import 'package:money_warden/pages/settings.dart';
import 'package:money_warden/pages/transaction_crud.dart';

void main() {
  runApp(MoneyWarden());
}

class MoneyWarden extends StatefulWidget {
  MoneyWarden({super.key});

  @override
  State<MoneyWarden> createState() => _MoneyWardenState();
}

class _MoneyWardenState extends State<MoneyWarden> {
  final List pages = [
    const HomePage(),
    const TransactionsPage(),
    const AnalyticsPage(),
    const SettingsPage(),
  ];

  int currentPage = 0;

  void navigateBottomBar(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light().copyWith(
          primary: const Color(0xFF2DBA4B),
          onPrimary: const Color(0xFFFFFFFF),
          secondary: const Color(0xFF2DBBA1),
          onSecondary: const Color(0xFFFFFFFF),
          surface: const Color(0xFFFEF7FF),
          surfaceDim: const Color(0xFFE1E1E1),
          onSurface: const Color(0xFF1D1B20),
        ),
      ),
      home: Builder(
        builder: (context) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: GNav(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  color: Theme.of(context).colorScheme.secondary,
                  activeColor: Theme.of(context).colorScheme.onPrimary,
                  tabBackgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 17),
                  gap: 7,
                  onTabChange: (index) => navigateBottomBar(index),
                  tabs: const [
                    GButton(icon: Icons.home, text: "Home"),
                    GButton(icon: Icons.monetization_on, text: "Transactions"),
                    GButton(icon: Icons.auto_graph, text: "Summary"),
                    GButton(icon: Icons.settings, text: "Settings")
                  ]
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: pages[currentPage],
              ),
            ),
          );
        }
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
