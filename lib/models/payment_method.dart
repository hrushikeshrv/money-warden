import 'package:flutter/material.dart';

class PaymentMethod {
  String name;
  String? cellId;
  Icon? icon;
  bool isDefault;

  PaymentMethod({
    required this.name,
    this.cellId,
    this.icon,
    this.isDefault = false
  });
}