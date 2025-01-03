import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_warden/components/budget_month_dropdown.dart';
import 'package:money_warden/models/budget_sheet.dart';

class MwAppBar extends StatefulWidget {
  const MwAppBar({super.key});

  @override
  State<MwAppBar> createState() => _MwAppBarState();
}

class _MwAppBarState extends State<MwAppBar> {
  bool refreshing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        var refreshingSnackBar = SnackBar(
          showCloseIcon: true,
          closeIconColor: Colors.black,
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          content: Row(
            children: [
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2,),),
              const SizedBox(width: 10),
              Text(
                'Syncing with ${budget.spreadsheetName}',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          )
        );
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 45,),
                    const SizedBox(width: 5),
                    const BudgetMonthDropdown(),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    if (refreshing) return;
                    ScaffoldMessenger.of(context).showSnackBar(refreshingSnackBar);
                    refreshing = true;
                    await budget.initBudgetData(forceUpdate: true);
                    refreshing = false;
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).colorScheme.inverseSurface, width: 2),
                      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(2, 2))],
                    ),
                    child: const Icon(Icons.sync),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
