import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_pill_button.dart';
import 'package:money_warden/models/payment_method.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:money_warden/components/budget_initialization_failed_alert.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/components/mw_text_field.dart';
import 'package:money_warden/components/mw_alert_dialog.dart';
import 'package:money_warden/components/transaction_tile.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/category.dart';
import 'package:money_warden/theme/theme.dart';
import 'package:money_warden/utils/utils.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();
  final List<Category> filterCategories = [];
  final List<PaymentMethod> filterPaymentMethods = [];

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
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: MwTextField(
                      hintText: "Filter transactions",
                      prefixIcon: Icon(Icons.search, color: colors.mutedText),
                      controller: controller,
                      onChanged: (String query) {
                        budget.setTransactionFilters(query: query);
                        budget.filterTransactions();
                      },
                    ),
                  ),
                  const SizedBox(width: 10,),

                  MwPillButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.category_outlined),
                          const SizedBox(width: 5,),
                          Text(budget.transactionFilterCategories.length.toString())
                        ],
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          List<Category> allCategories = budget.expenseCategories + budget.incomeCategories;
                          return StatefulBuilder(
                            builder: (context, setStateDialog) {
                              return MwAlertDialog(
                                title: Text("Filter by Categories"),
                                content: ListView(
                                  shrinkWrap: true,
                                  children: allCategories.map((cat) {
                                    return ListTile(
                                      leading: filterCategories.contains(cat) ? Icon(Icons.check_box_outlined) : Icon(Icons.check_box_outline_blank),
                                      title: Text(cat.name),
                                      contentPadding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                                      onTap: () {
                                        setStateDialog(() {
                                          if (filterCategories.contains(cat)) {
                                            filterCategories.remove(cat);
                                          } else {
                                            filterCategories.add(cat);
                                          }
                                        });
                                        budget.setTransactionFilters(categories: filterCategories);
                                      },
                                    );
                                  }).toList(),
                                ),
                                actions: [
                                  MwActionButton(
                                    leading: Icon(Icons.filter_alt_outlined),
                                    text: "Filter",
                                    onTap: () {
                                      budget.filterTransactions();
                                      Navigator.of(context).pop();
                                    }
                                  )
                                ]
                              );
                            }
                          );
                        }
                      );
                    }
                  ),
                  const SizedBox(width: 10,),

                  MwPillButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.payments_outlined),
                          const SizedBox(width: 5,),
                          Text(budget.transactionFilterPaymentMethods.length.toString())
                        ],
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return StatefulBuilder(
                            builder: (context, setStateDialog) {
                              return MwAlertDialog(
                                title: Text("Filter by Payment Method", style: TextStyle(overflow: TextOverflow.ellipsis),),
                                content: ListView(
                                  shrinkWrap: true,
                                  children: budget.paymentMethods.map((cat) {
                                    return ListTile(
                                      leading: filterPaymentMethods.contains(cat) ? Icon(Icons.check_box_outlined) : Icon(Icons.check_box_outline_blank),
                                      title: Text(cat.name),
                                      contentPadding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                                      onTap: () {
                                        if (filterPaymentMethods.contains(cat)) {
                                          setStateDialog(() {
                                            filterPaymentMethods.remove(cat);
                                        });
                                        }
                                        else {
                                          setStateDialog(() {
                                            filterPaymentMethods.add(cat);
                                          });
                                        }
                                        budget.setTransactionFilters(paymentMethods: filterPaymentMethods);
                                      },
                                    );
                                  }).toList(),
                                ),
                                actions: [
                                  MwActionButton(
                                    leading: Icon(Icons.filter_alt_outlined),
                                    text: "Filter",
                                    onTap: () {
                                      budget.filterTransactions();
                                      Navigator.of(context).pop();
                                    }
                                  )
                                ]
                              );
                            }
                          );
                        }
                      );
                    }
                  ),
                ],
              )
            ),
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
