import 'package:flutter/material.dart';
import 'package:money_warden/components/budget_month_dropdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int amountSpent = 9999;
  int amountEarned = 9999;
  int difference = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BudgetMonthDropdown()
              ]
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text("${amountSpent > 0 ? '+' : ''}\$$amountSpent", style: const TextStyle(fontSize: 22)),
                      const Text("Spent"),
                    ],
                  ),
                  Column(
                    children: [
                      Text("${amountEarned > 0 ? '+' : ''}\$$amountEarned", style: const TextStyle(fontSize: 22)),
                      const Text("Earned"),
                    ],
                  ),
                  Column(
                    children: [
                      Text("${difference > 0 ? '+' : ''}\$$difference", style: const TextStyle(fontSize: 22)),
                      const Text("Difference"),
                    ],
                  )
                ]
            ),
          )
        ],
      ),
    );
  }
}
