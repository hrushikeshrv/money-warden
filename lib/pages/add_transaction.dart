import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/mw_form_label.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/pill_container.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/models/category.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';


class AddTransactionPage extends StatefulWidget {
  final TransactionType initialTransactionType;
  const AddTransactionPage({super.key, required this.initialTransactionType});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionType? transactionType;
  DateTime transactionDate = DateTime.now();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<DropdownMenuEntry<Category>> getTransactionCategoryOptions(BudgetSheet budget) {
    if (transactionType == null || transactionType == TransactionType.expense) {
      return budget.expenseCategories.map(
          (Category c) {
            return DropdownMenuEntry(value: c, label: c.name);
          }
      ).toList();
    }
    else {
      return budget.incomeCategories.map(
          (Category c) {
            return DropdownMenuEntry(value: c, label: c.name);
          }
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    transactionType ??= widget.initialTransactionType;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Consumer<BudgetSheet>(
        builder: (context, budget, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Heading1(text: 'Add an ${transactionType == TransactionType.expense ? 'Expense' : 'Income'}'),
                    MwActionButton(
                        leading: const Icon(Icons.check),
                        text: 'Add',
                        onTap: () {}
                    )
                  ],
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                  
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: transactionType == TransactionType.expense
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.surface,
                                      border: Border.all(
                                        width: 3,
                                        color: transactionType == TransactionType.expense
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.surfaceDim
                                      )
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Expense',
                                        style: TextStyle(
                                          color: transactionType == TransactionType.expense
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.onSurface
                                        ),
                                      )
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      transactionType = TransactionType.expense;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: transactionType == TransactionType.income
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.surface,
                                      border: Border.all(
                                        width: 3,
                                        color: transactionType == TransactionType.income
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.surfaceDim
                                      )
                                    ),
                                    child: Center(
                                        child: Text(
                                          'Income',
                                          style: TextStyle(
                                            color: transactionType == TransactionType.income
                                                ? Colors.white
                                                : Theme.of(context).colorScheme.onSurface
                                          ),
                                        )
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      transactionType = TransactionType.income;
                                    });
                                  },
                                ),
                              ],
                            ),
                  
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(budget.defaultCurrencySymbol, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: TextField(
                                    controller: amountController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      fontSize: 24
                                    ),
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      hintText: 'Amount',
                                      hintStyle: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  formatDateTime(transactionDate),
                                  style: const TextStyle(
                                    fontSize: 24
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                GestureDetector(
                                  child: PillContainer(
                                    color: Theme.of(context).colorScheme.primary,
                                    child: Text('Today', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      transactionDate = DateTime.now();
                                    });
                                  }
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  child: PillContainer(
                                    color: Theme.of(context).colorScheme.primary,
                                    child: Text('Yesterday', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      transactionDate = DateTime.now().subtract(const Duration(days: 1));
                                    });
                                  }
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  child: Ink(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceDim,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: const Icon(Icons.calendar_month)
                                  ),
                                  onTap: () async {
                                    var date = await showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1900, 1, 1),
                                        lastDate: DateTime(2100, 1, 1),
                                        initialDate: DateTime.now()
                                      );
                                    if (date != null) {
                                      setState(() {
                                        transactionDate = date;
                                      });
                                    }
                                  }
                                )
                              ],
                            ),
                  
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownMenu<Category>(
                                    expandedInsets: const EdgeInsets.all(0),
                                    controller: categoryController,
                                    dropdownMenuEntries: getTransactionCategoryOptions(budget),
                                    hintText: 'Category (optional)',
                                    inputDecorationTheme: InputDecorationTheme(
                                      filled: true,
                                      fillColor: Colors.grey.shade100
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: descriptionController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      fillColor: Colors.grey.shade100,
                                      filled: true,
                                      hintText: 'Description (optional)',
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
