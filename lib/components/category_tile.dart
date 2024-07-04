import 'package:flutter/material.dart';

import 'package:money_warden/models/category.dart';


class CategoryTile extends StatelessWidget {
  final Category category;
  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: category.backgroundColor ?? Colors.grey.shade400,
          ),
        ),
      ),
      title: Text(category.name),
    );
  }
}
