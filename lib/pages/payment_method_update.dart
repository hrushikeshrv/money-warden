import 'package:flutter/material.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/payment_method.dart';


class PaymentMethodDetailPage extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final bool updatePaymentMethod;
  const PaymentMethodDetailPage({
    super.key,
    required this.paymentMethod,
    this.updatePaymentMethod = true
  });

  @override
  State<PaymentMethodDetailPage> createState() => _PaymentMethodDetailPageState();
}

class _PaymentMethodDetailPageState extends State<PaymentMethodDetailPage> {
  bool _loading = false;
  TextEditingController paymentMethodNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    paymentMethodNameController.text = widget.paymentMethod.name;
  }

  void updatePaymentMethod(
    BudgetSheet budget,
    PaymentMethod paymentMethod,
    String name,
    String iconName
  ) async {

  }

  void createPaymentMethod(
    BudgetSheet budget,
    String name,
    String iconName
  ) async {

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
                  Heading1(text: '${widget.updatePaymentMethod ? 'Update' : 'Add'} Payment Method'),
                  MwActionButton(
                    leading: const Icon(Icons.check),
                    text: widget.updatePaymentMethod ? 'Update' : 'Add',
                    onTap: () {
                      if (_loading) return;
                      if (widget.updatePaymentMethod) {
                        updatePaymentMethod(budget, widget.paymentMethod, paymentMethodNameController.text, '');
                      }
                      else {

                      }
                      Navigator.of(context).pop();
                    }
                  )
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
