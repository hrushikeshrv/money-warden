import 'package:flutter/material.dart';

class PaymentMethod {
  String name;
  String? cellId;
  Icon? icon;

  PaymentMethod({
    required this.name,
    this.cellId,
    this.icon,
  });
}