import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/exceptions/null_spreadsheet_value_exception.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/pill_container.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/models/category.dart' as category;
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';


class AddTransactionPage extends StatefulWidget {
  final TransactionType initialTransactionType;
  final bool updateTransaction;
  final Transaction? initialTransaction;
  const AddTransactionPage({
    super.key,
    required this.initialTransactionType,
    this.updateTransaction = false,
    this.initialTransaction
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionType? transactionType;
  DateTime transactionDate = DateTime.now();
  category.Category? transactionCategory;
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool _amountValid = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (
      widget.updateTransaction
      && widget.initialTransaction != null
    ) {
      amountController.text = widget.initialTransaction!.amount.toString();
      if (widget.initialTransaction!.category != null) {
        categoryController.text = widget.initialTransaction!.category!.name;
        setState(() {
          transactionCategory = widget.initialTransaction!.category!;
        });
      }
      descriptionController.text = widget.initialTransaction!.description ?? '';
      setState(() {
        transactionDate = getTransactionInitialDate();
      });
    }
  }

  List<DropdownMenuEntry<category.Category>> getTransactionCategoryOptions(BudgetSheet budget) {
    if (transactionType == null || transactionType == TransactionType.expense) {
      return budget.expenseCategories.map(
          (category.Category c) {
            return DropdownMenuEntry(value: c, label: c.name);
          }
      ).toList();
    }
    else {
      return budget.incomeCategories.map(
          (category.Category c) {
            return DropdownMenuEntry(value: c, label: c.name);
          }
      ).toList();
    }
  }

  void createTransaction(BudgetSheet budget) async {
    if (amountController.value.text == '') {
      return;
    }
    if (!isNumber(amountController.value.text)) {
      setState(() {
        _amountValid = false;
        return;
      });
    }
    else {
      setState(() {
        _amountValid = true;
      });
    }
    setState(() {
      _loading = true;
    });

    try {
      await budget.createTransaction(
        amount: double.parse(amountController.value.text),
        date: transactionDate,
        transactionType: transactionType!,
        category: transactionCategory,
        description: descriptionController.value.text,
        updateTransaction: widget.updateTransaction,
        freeRowIndex: widget.updateTransaction ? widget.initialTransaction?.rowIndex : null
      );
    }
    on NullSpreadsheetValueException catch (exception) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('An error occurred'),
            content: Text(exception.cause)
          );
        }
      );
    }
    catch (exception) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('An error occurred'),
            content: Text(
              'An unknown error occurred while trying to create the transaction. '
              'Please contact us at https://hrus.in/money-warden/contact if this error persists.'
            )
          );
        }
      );
    }
    finally {
      setState(() {
        _loading = false;
      });
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  /// Returns the first accepted date for the transaction's date picker
  DateTime getTransactionFirstDate() {
    return widget.updateTransaction && widget.initialTransaction != null
        ? getFirstDateOfMonth(widget.initialTransaction!.time)
        : DateTime(1900, 1, 1);
  }
  /// Returns the last accepted date for the transaction's date picker
  DateTime getTransactionLastDate() {
    return widget.updateTransaction && widget.initialTransaction != null
        ? getLastDateOfMonth(widget.initialTransaction!.time)
        : DateTime(2100, 12, 1);
  }
  /// Returns the initial date for the transaction's date picker
  DateTime getTransactionInitialDate() {
    return widget.updateTransaction && widget.initialTransaction != null
        ? widget.initialTransaction!.time
        : DateTime.now();
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
                    Heading1(text: '${widget.updateTransaction ? 'Update' : 'Add'} an ${transactionType == TransactionType.expense ? 'Expense' : 'Income'}'),
                    MwActionButton(
                      leading: const Icon(Icons.check),
                      text: widget.updateTransaction ? 'Update' : 'Add',
                      onTap: () {
                        if (_loading) return;
                        createTransaction(budget);
                      }
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
                                      // If we are updating a transaction, we can't change
                                      // from income to expense, and vice-versa.
                                      if (widget.updateTransaction) return;
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
                                      // If we are updating a transaction, we can't change
                                      // from expense to income, and vice-versa.
                                      if (widget.updateTransaction) return;
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
                                      errorText: _amountValid ? null : 'Enter a valid amount'
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true
                                    ),
                                    enabled: !_loading,
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
                                    if (_loading) return;
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
                                    if (_loading) return;
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
                                    if (_loading) return;
                                    var date = await showDatePicker(
                                        context: context,
                                        firstDate: getTransactionFirstDate(),
                                        lastDate: getTransactionLastDate(),
                                        initialDate: getTransactionInitialDate()
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
                                  child: DropdownMenu<category.Category>(
                                    expandedInsets: const EdgeInsets.all(0),
                                    controller: categoryController,
                                    dropdownMenuEntries: getTransactionCategoryOptions(budget),
                                    hintText: 'Category (optional)',
                                    inputDecorationTheme: InputDecorationTheme(
                                      filled: true,
                                      fillColor: Colors.grey.shade100
                                    ),
                                    enabled: !_loading,
                                    onSelected: (category.Category? cat) {
                                      setState(() {
                                        transactionCategory = cat;
                                      });
                                    },
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
                                    enabled: !_loading,
                                  ),
                                )
                              ],
                            ),

                            Container(
                              padding: const EdgeInsets.only(top: 30, bottom: 15),
                              child: widget.updateTransaction && widget.initialTransaction != null
                                  ? MwActionButton(
                                    leading: const Icon(Icons.delete_forever, color: Colors.white),
                                    text: 'Delete',
                                    onTap: () async {
                                      setState(() {
                                        _loading = true;
                                      });
                                      await budget.deleteTransaction(widget.initialTransaction!);
                                      if (!context.mounted) return;
                                      Navigator.of(context).pop();
                                    },
                                    role: 'error'
                                  )
                                  : null
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
