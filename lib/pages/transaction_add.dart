import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/components/mw_text_field.dart';
import 'package:money_warden/exceptions/null_spreadsheet_value_exception.dart';
import 'package:money_warden/theme/theme.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/pill_container.dart';
import 'package:money_warden/models/payment_method.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/models/category.dart' as category;
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';


class TransactionAddPage extends StatefulWidget {
  final TransactionType initialTransactionType;
  final bool updateTransaction;
  final Transaction? initialTransaction;
  const TransactionAddPage({
    super.key,
    required this.initialTransactionType,
    this.updateTransaction = false,
    this.initialTransaction
  });

  @override
  State<TransactionAddPage> createState() => _TransactionAddPageState();
}

class _TransactionAddPageState extends State<TransactionAddPage> {
  TransactionType? transactionType;
  DateTime transactionDate = DateTime.now();
  category.Category? transactionCategory;
  PaymentMethod? paymentMethod;
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController paymentMethodController = TextEditingController();
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
      if (widget.initialTransaction!.paymentMethod != null) {
        paymentMethodController.text = widget.initialTransaction!.paymentMethod!.name;
        setState(() {
          paymentMethod = widget.initialTransaction!.paymentMethod!;
        });
      }
      descriptionController.text = widget.initialTransaction!.description ?? '';
      setState(() {
        transactionDate = getTransactionInitialDate();
      });
    } else {
      // TODO: Otherwise, set the value of the payment method dropdown to the default payment method
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

  List<DropdownMenuEntry<PaymentMethod>> getPaymentMethodOptions(BudgetSheet budget) {
    return budget.paymentMethods.map(
        (PaymentMethod method) {
          return DropdownMenuEntry(value: method, label: method.name);
        }
    ).toList();
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
        paymentMethod: paymentMethod,
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
    final colors = Theme.of(context).extension<MwColors>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Consumer<BudgetSheet>(
        builder: (context, budget, child) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(2, 2))],
                            ),
                            child: SegmentedButton<TransactionType>(

                              segments: <ButtonSegment<TransactionType>> [
                                ButtonSegment<TransactionType>(
                                  value: TransactionType.expense,
                                  label: const Text("Expense"),
                                  icon: const Icon(Icons.payments_outlined),
                                  enabled: (
                                    !widget.updateTransaction
                                    || widget.initialTransaction == null
                                    || widget.initialTransaction!.transactionType == TransactionType.expense
                                  )
                                ),
                                ButtonSegment<TransactionType>(
                                  value: TransactionType.income,
                                  label: const Text("Income"),
                                  icon: const Icon(Icons.savings_outlined),
                                  enabled: (
                                    !widget.updateTransaction
                                    || widget.initialTransaction == null
                                    || widget.initialTransaction!.transactionType == TransactionType.income
                                  )
                                )
                              ],
                              selected: <TransactionType>{transactionType!},
                              onSelectionChanged: (Set<TransactionType> newSelection) {
                                setState(() {
                                  transactionType = newSelection.first;
                                });
                              },
                              showSelectedIcon: false,
                              style: SegmentedButton.styleFrom(
                                backgroundColor: colors.backgroundDark1,
                                selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  width: 2
                                )
                              )
                            ),
                          ),
                          MwActionButton(
                              leading: const Icon(Icons.check),
                              text: widget.updateTransaction ? 'Save' : 'Add',
                              onTap: () {
                                if (_loading) return;
                                createTransaction(budget);
                              }
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(budget.defaultCurrencySymbol, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 15),
                              Expanded(
                                child: TextField(
                                  controller: amountController,
                                  autofocus: true,
                                  style: const TextStyle(
                                    fontSize: 32
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
                              Flexible(
                                child: Text(
                                  formatDateTime(transactionDate),
                                  style: const TextStyle(
                                    fontSize: 20
                                  )
                                ),
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
                                  label: Row(
                                    children: [
                                      const Icon(Icons.category_outlined),
                                      const SizedBox(width: 5,),
                                      Text("Category", style: TextStyle(color: colors.mutedText),)
                                    ],
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: colors.backgroundDark1,
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                                        borderSide: BorderSide(color: colors.backgroundDark1, width: 1)
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0)
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
                          MwTextField(
                            controller: descriptionController,
                            enabled: !_loading,
                            labelText: "Description",
                            labelIcon: const Icon(Icons.description_outlined)
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownMenu<PaymentMethod>(
                                  expandedInsets: const EdgeInsets.all(0),
                                  controller: paymentMethodController,
                                  dropdownMenuEntries: getPaymentMethodOptions(budget),
                                  label: Row(
                                    children: [
                                      const Icon(Icons.payments_outlined),
                                      const SizedBox(width: 5,),
                                      Text("Payment Method", style: TextStyle(color: colors.mutedText),)
                                    ],
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: colors.backgroundDark1,
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                                        borderSide: BorderSide(color: colors.backgroundDark1, width: 1)
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0)
                                  ),
                                  enabled: !_loading,
                                  onSelected: (PaymentMethod? method) {
                                    setState(() {
                                      paymentMethod = method;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          Container(
                            padding: const EdgeInsets.only(top: 30, bottom: 15),
                            child: widget.updateTransaction && widget.initialTransaction != null
                                ? MwActionButton(
                                  leading: const Icon(Icons.delete, color: Colors.white),
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
          );
        }
      ),
    );
  }
}
