import 'package:flutter/material.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/category.dart' as category;
import 'package:money_warden/models/transaction.dart';

class TransactionCategoryUpdatePage extends StatefulWidget {
  final category.Category transactionCategory;
  final bool updateCategory;
  final TransactionType transactionType;
  const TransactionCategoryUpdatePage({
    super.key,
    required this.transactionCategory,
    required this.transactionType,
    this.updateCategory = true
  });

  @override
  State<TransactionCategoryUpdatePage> createState() => _TransactionCategoryUpdatePageState();
}

class _TransactionCategoryUpdatePageState extends State<TransactionCategoryUpdatePage> {
  bool _loading = false;
  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    categoryNameController.text = widget.transactionCategory.name;
  }

  void updateCategory() async {

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
                  const Heading1(text: 'Update A Category'),
                  MwActionButton(
                    leading: const Icon(Icons.check),
                    text: widget.updateCategory ? 'Update' : 'Add',
                    onTap: () {
                      if (_loading) return;
                      updateCategory();
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
                                budget.setCategoryBackgroundColor(
                                  category: widget.transactionCategory,
                                  transactionType: widget.transactionType,
                                  color: color
                                );
                                Navigator.of(context).pop();
                              },
                              child: widget.transactionCategory.backgroundColor == color
                              ? Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    width: 60,
                                    height: 60,
                                  ),
                                  const Icon(Icons.check)
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
