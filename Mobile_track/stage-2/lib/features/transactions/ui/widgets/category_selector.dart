import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/category_extension.dart';

class CategorySelector extends StatelessWidget {
  final Category selectedCategory;
  final Function(Category) onCategorySelected;
  
  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Category.values.map((category) {
            final isSelected = selectedCategory == category;
            return FilterChip(
              label: Text(category.displayName),
              avatar: Icon(category.icon, size: 18),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: isSelected ? category.color : Colors.grey.shade200,
              selectedColor: category.color,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
            );
          }).toList(),
        ),
      ],
    );
  }
}