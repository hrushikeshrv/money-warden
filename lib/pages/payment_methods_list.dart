import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/category_tile.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_warning.dart';
import 'package:money_warden/pages/add_category.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/transaction.dart';


class PaymentMethodsListPage extends StatefulWidget {
  const PaymentMethodsListPage({super.key});

  @override
  State<PaymentMethodsListPage> createState() => _PaymentMethodsListPageState();
}

class _PaymentMethodsListPageState extends State<PaymentMethodsListPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return Scaffold(
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                physics: const ClampingScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Heading1(text: 'Payment Methods'),
                  ),
                  SizedBox(height: 10),
                ]
              )
            ),
          ),
        );
      },
    );
  }
}
