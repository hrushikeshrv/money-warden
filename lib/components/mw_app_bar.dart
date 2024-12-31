import 'package:flutter/material.dart';
import 'package:money_warden/components/budget_month_dropdown.dart';

class MwAppBar extends StatelessWidget {
  const MwAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        child: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 45,),
            const SizedBox(width: 10),
            const BudgetMonthDropdown(),
          ],
        ),
      ),
    );
  }
}
