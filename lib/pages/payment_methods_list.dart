import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/components/payment_method_tile.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/payment_method.dart';
import 'package:money_warden/pages/payment_method_update.dart';


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
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Heading1(text: 'Payment Methods'),
                  ),
                  const SizedBox(height: 10),
                  MwActionButton(
                    leading: const Icon(Icons.add_card),
                    text: 'Add Payment Method',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.85,
                            child: PaymentMethodDetailPage(
                              paymentMethod: PaymentMethod(name: 'New Payment Method'),
                              updatePaymentMethod: false,
                            )
                          );
                        }
                      );
                    }
                  ),

                  const SizedBox(height: 20),
                  ListView.builder(
                    itemCount: budget.paymentMethods.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (budget.paymentMethods[index].name == 'Unspecified') {
                        return Container();
                      }
                      return PaymentMethodTile(paymentMethod: budget.paymentMethods[index]);
                    },
                  )
                ]
              )
            ),
          ),
        );
      },
    );
  }
}
