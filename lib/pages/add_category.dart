import 'package:flutter/material.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/category.dart' as category;
import 'package:money_warden/models/transaction.dart';

class AddCategoryPage extends StatefulWidget {
  final TransactionType transactionType;
  const AddCategoryPage({
    super.key,
    required this.transactionType,
  });

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  bool _loading = false;
  Color backgroundColor = getRandomGraphColor();
  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
        builder: (context, budget, child) {
          return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Heading1(text: 'Create A Category'),
                      MwActionButton(
                          leading: const Icon(Icons.check),
                          text: 'Create',
                          onTap: () {
                            if (_loading) return;
                            category.Category newCat = category.Category(
                              name: categoryNameController.text,
                              backgroundColor: backgroundColor,
                              cellId: ''
                            );
                            budget.createCategory(category: newCat, transactionType: widget.transactionType);
                            Navigator.of(context).pop();
                          }
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                TextField(
                                  controller: categoryNameController,
                                  autofocus: true,
                                  style: const TextStyle(
                                      fontSize: 24
                                  ),
                                  decoration: InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    hintText: 'Category Name',
                                    hintStyle: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            child: Center(
                              child: Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                children: mwColors.map<Widget>((color) {
                                  return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          backgroundColor = color;
                                        });
                                      },
                                      child: backgroundColor == color
                                          ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius: BorderRadius.circular(10),
                                              // border: Border.all(color: Theme.of(context).colorScheme.surfaceDim, width: 4)
                                            ),
                                            width: 60,
                                            height: 60,
                                          ),
                                          const Icon(
                                            Icons.check,
                                            size: 32,
                                            color: Colors.black,
                                          ),
                                        ],
                                      )
                                          : Container(
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        width: 60,
                                        height: 60,
                                      )
                                  );
                                }).toList(),
                              ),
                            ),
                          ) ,
                        ]
                    ),
                  )
                ],
              )
          );
        }
    );
  }
}
