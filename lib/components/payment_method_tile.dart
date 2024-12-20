import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/payment_method.dart';
import 'package:money_warden/pages/payment_method_detail.dart';


class PaymentMethodTile extends StatelessWidget {
  final PaymentMethod paymentMethod;
  const PaymentMethodTile({
    super.key,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return ListTile(
          leading: paymentMethod.icon ?? const Icon(Icons.payment),
          title: Text(paymentMethod.name),
          trailing: paymentMethod.isDefault ? const Text('Default') : null,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                    heightFactor: 0.85,
                    child: PaymentMethodDetailPage(paymentMethod: paymentMethod,)
                );
              }
            );
          }
        );
      },
    );
  }
}
