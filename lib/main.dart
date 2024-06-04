import 'package:money_warden/pages/analytics.dart';
import 'package:money_warden/pages/settings.dart';
import 'package:money_warden/pages/transaction_crud.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'pages/homepage.dart';

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
    HomePage(),
    TransactionsPage(),
    AnalyticsPage(),
    SettingsPage(),
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
          useMaterial3: true,
          colorScheme: const ColorScheme.light()
      ),
      home: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: GNav(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              color: Colors.grey.shade500,
              activeColor: Colors.grey.shade900,
              // tabActiveBorder: Border.all(color: Colors.grey.shade600),
              tabBackgroundColor: Colors.grey.shade300,
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
        backgroundColor: Colors.grey.shade50,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
