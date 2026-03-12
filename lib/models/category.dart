import 'package:flutter/material.dart';

class Category {
  String name;
  Color? backgroundColor;
  String? cellId;

  Category({ required this.name, this.cellId, this.backgroundColor });

  @override
  bool operator ==(Object other) {
    return identical(this, other)
        || (
          other is Category
          && other.name == name
          && other.cellId == cellId
        );
  }

  @override
  int get hashCode => Object.hash(name, cellId);
}