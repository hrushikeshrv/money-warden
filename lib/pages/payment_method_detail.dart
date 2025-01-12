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
  String iconName = '';
  TextEditingController paymentMethodNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.updatePaymentMethod) {
      paymentMethodNameController.text = widget.paymentMethod.name;
      var iconData = getPaymentMethodIcons();
      setState(() {
        iconName = getIconNameFromIcon(widget.paymentMethod.icon ?? const Icon(Icons.payment));
      });
    }
  }

  void updatePaymentMethod(
    BudgetSheet budget,
    PaymentMethod paymentMethod,
    String name
  ) async {
    await budget.setPaymentMethodName(paymentMethod: paymentMethod, name: name);
  }

  void createPaymentMethod(
    BudgetSheet budget,
    String name,
    String iconName
  ) async {
    if (name.trim() == '') return;
    var paymentMethod = PaymentMethod(name: name, icon: getIconFromStoredString(iconName: iconName));
    _loading = true;
    await budget.createPaymentMethod(paymentMethod: paymentMethod);
    _loading = false;
  }

  void setPaymentMethodAsDefault(BudgetSheet budget, PaymentMethod paymentMethod) async {
    await budget.setPaymentMethodAsDefault(paymentMethod: paymentMethod);
  }

  List<GestureDetector> getIconGestureDetectors(BudgetSheet budget) {
    var iconData = getPaymentMethodIcons();
    List<GestureDetector> icons = [];
    iconData.forEach((key, value) {
      icons.add(
        GestureDetector(
          onTap: () {
            if (_loading) return;
            setState(() {
              iconName = key;
            });
            budget.setPaymentMethodIcon(paymentMethod: widget.paymentMethod, icon: value);
          },
          child: Container(
            decoration: BoxDecoration(
              color: iconName == key ? Theme.of(context).colorScheme.surfaceDim : Colors.white,
              borderRadius: BorderRadius.circular(10)
            ),
            width: 60,
            height: 60,
            child: Center(
              child: value,
            ),
          )
        )
      );
    });
    return icons;
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
                  Heading1(text: '${widget.updatePaymentMethod ? '' : 'Add'} Payment Method'),
                  MwActionButton(
                    leading: const Icon(Icons.check),
                    text: widget.updatePaymentMethod ? 'Update' : 'Add',
                    onTap: () {
                      if (_loading) return;
                      if (widget.updatePaymentMethod) {
                        updatePaymentMethod(budget, widget.paymentMethod, paymentMethodNameController.text);
                      }
                      else {
                        createPaymentMethod(budget, paymentMethodNameController.text, iconName);
                      }
                      Navigator.of(context).pop();
                    }
                  )
                ],
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: paymentMethodNameController,
                      autofocus: true,
                      style: const TextStyle(
                          fontSize: 24
                      ),
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: 'Payment Method Name',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                      ),
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Center(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: getIconGestureDetectors(budget)
                  ),
                ),
              ) ,

              const SizedBox(height: 10),
              widget.updatePaymentMethod && !widget.paymentMethod.isDefault
                ? MwActionButton(leading: const Icon(Icons.check), text: 'Make Default', onTap: () {
                  setPaymentMethodAsDefault(budget, widget.paymentMethod);
                  Navigator.of(context).pop();
                })
                : Container(),
            ],
          ),
        );
      },
    );
  }
}
