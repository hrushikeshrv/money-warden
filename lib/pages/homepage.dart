import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:money_warden/components/budget_initialization_failed_alert.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/components/mw_text_field.dart';
import 'package:money_warden/components/transaction_tile.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/theme/theme.dart';
import 'package:money_warden/utils/utils.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MwColors>()!;

    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        double? amountSpent = budget.currentBudgetMonthData?.monthExpenseAmount;
        double? amountEarned = budget.currentBudgetMonthData?.monthIncomeAmount;
        double? difference = budget.currentBudgetMonthData?.monthDifferenceAmount;
        double? percentSpent = budget.currentBudgetMonthData?.percentIncomeSpent;

        if (budget.budgetInitializationFailed) {
          return const BudgetInitializationFailedAlert();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MwAppBar(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              amountSpent == null ?
                              const CircularProgressIndicator()
                                  : Text(
                                      "${budget.defaultCurrencySymbol}${formatMoney(amountSpent)}",
                                      style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.w600)
                                  ),
                              const Text("Spent"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              amountEarned == null ?
                              const CircularProgressIndicator()
                                  : Text("${budget.defaultCurrencySymbol}${formatMoney(amountEarned)}", style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.w600)),
                              const Text("Earned"),
                            ],
                          ),
                        ),
                      ]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              difference == null ?
                              const CircularProgressIndicator()
                                  : Text("${difference < 0 ? '-' : ''}${budget.defaultCurrencySymbol}${formatMoney(difference.abs())}",
                                  style: GoogleFonts.jetBrainsMono(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: difference > 0 ? Colors.green.shade500 : Colors.red.shade600
                                  )
                              ),
                              const Text("Balance"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              percentSpent == null ?
                              const CircularProgressIndicator()
                                  : Text("$percentSpent %",
                                  style: GoogleFonts.jetBrainsMono(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: percentSpent < 90.0 ? Colors.green.shade500 : Colors.red.shade600
                                  )
                              ),
                              const Text("% Spent"),
                            ],
                          ),
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: MwTextField(
                      labelText: "Filter transactions",
                      labelIcon: Icon(Icons.search, color: colors.mutedText),
                      controller: controller,
                      onChanged: (String query) {
                        budget.filterTransactions(query);
                      },
                    )
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: budget.currentBudgetMonthData != null && budget.currentBudgetMonthData!.filteredTransactions.isEmpty
                        ? const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(child: Text('No transactions yet 💸', style: TextStyle(fontSize: 17))),
                        )
                        : ListView.builder(
                          itemCount: budget.currentBudgetMonthData == null ? 0 : budget.currentBudgetMonthData!.filteredTransactions.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return TransactionTile(transaction: budget.currentBudgetMonthData?.filteredTransactions[index]);
                          },
                        ),
                  ),

                  const SizedBox(height: 50),
                ]
              ),
            )
          ],
        );
      }
    );
  }
}
