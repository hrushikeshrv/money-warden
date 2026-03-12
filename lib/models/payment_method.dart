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

  @override
  bool operator ==(Object other) {
    return identical(this, other)
        || (
          other is PaymentMethod
          && other.name == name
          && other.cellId == cellId
        );
  }

  @override
  int get hashCode => Object.hash(name, cellId);
}