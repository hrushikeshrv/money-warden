import 'package:flutter/material.dart';

class Category {
  String name;
  Color? backgroundColor;
  String? cellId;

  Category({ required this.name, this.cellId, this.backgroundColor });
}