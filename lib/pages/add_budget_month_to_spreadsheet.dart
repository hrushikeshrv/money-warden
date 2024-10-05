import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/exceptions/spreadsheet_value_exception.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/models/category.dart' as category;
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/utils.dart';

class AddBudgetMonthToSpreadsheetPage extends StatefulWidget {
  const AddBudgetMonthToSpreadsheetPage({super.key});

  @override
  State<AddBudgetMonthToSpreadsheetPage> createState() => _AddBudgetMonthToSpreadsheetPageState();
}

class _AddBudgetMonthToSpreadsheetPageState extends State<AddBudgetMonthToSpreadsheetPage> {
  String errorMessage = '';
  List<DropdownMenuItem<String>> monthNames = [];
  List<DropdownMenuItem<String>> years = [];
  String selectedMonth = 'January';
  String selectedYear = DateTime.now().year.toString();
  bool _loading = false;

  List<DropdownMenuItem<String>> getMonthNameDropdownMenuItems() {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ].map((item) {
      return DropdownMenuItem(
        value: item,
        child: Text(item, style: const TextStyle(fontSize: 24)),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> getYearDropdownMenuItems() {
    var now = DateTime.now();
    List<int> years = [];
    for (int i = -5; i <= 5; i++) {
      years.add(now.year + i);
    }
    return years.map((item) {
      return DropdownMenuItem(
        value: item.toString(),
        child: Text(item.toString(), style: const TextStyle(fontSize: 24)),
      );
    }).toList();
  }

  Future<void> createBudgetMonth(String monthName, BudgetSheet budget) async {
    if (_loading) return;
    try {
      setState(() {
        _loading = true;
      });
      bool response = await budget.createSheet(monthName);
      Navigator.of(context).pop();
    }
    on SpreadsheetValueException catch (e) {
      setState(() {
        errorMessage = e.cause;
      });
    }
    catch (e) {
      setState(() {
        errorMessage = 'An error occurred while creating the new budget sheet.';
      });
    }
    finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    monthNames = getMonthNameDropdownMenuItems();
    years = getYearDropdownMenuItems();
    var now = DateTime.now();
    if (now.month == 12) {
      selectedMonth = monthNames[0].value!;
      selectedYear = years[6].value!;
    }
    else {
      selectedMonth = monthNames[now.month].value!;
      selectedYear = years[5].value!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Heading1(text: 'Add Budget Month'),
                  MwActionButton(
                    leading: const Icon(Icons.check),
                    text: 'Add',
                    onTap: () {
                      if (_loading) return;
                      createBudgetMonth('$selectedMonth $selectedYear', budget);
                    }
                  )
                ],
              ),
              const SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
                    items: getMonthNameDropdownMenuItems(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                    // isExpanded: true,
                    value: selectedMonth,
                  ),
                  const SizedBox(width: 10,),
                  DropdownButton(
                    items: getYearDropdownMenuItems(),
                    // isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                    value: selectedYear,
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.errorContainer
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
