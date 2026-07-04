
import 'package:fintak/data/models/transaction_model.dart';
import 'package:flutter/material.dart';

IconData getCategoryIcon(TransactionCategory category){
  switch (category) {
    case TransactionCategory.food:
      return Icons.restaurant_rounded;
    case TransactionCategory.shopping:
      return Icons.shopping_bag_rounded;
    case TransactionCategory.entertainment:
      return Icons.local_movies_rounded;
    case TransactionCategory.transport:
      return Icons.directions_car_rounded;
    case TransactionCategory.housing:
      return Icons.home_rounded;
    case TransactionCategory.utilities:
      return Icons.water_drop_rounded;
    case TransactionCategory.income:
      return Icons.attach_money_rounded;
    default:
      return Icons.category_rounded;
  }
}
(Color, Color) getCategoryColors(TransactionCategory category) {
  // Returns a tuple of (BackgroundColor, IconColor)
  switch (category) {
    case TransactionCategory.food:
      return (const Color(0xFFFFF3E0), const Color(0xFFFF9800));
    case TransactionCategory.shopping:
      return (const Color(0xFFE8F5E9), const Color(0xFF4CAF50));
    case TransactionCategory.entertainment:
      return (const Color(0xFFE1F5FE), const Color(0xFF03A9F4));
    case TransactionCategory.transport:
      return (const Color(0xFFEDE7F6), const Color(0xFF673AB7));
    case TransactionCategory.housing:
      return (const Color(0xFFFCE4EC), const Color(0xFFE91E63));
    case TransactionCategory.utilities:
      return (const Color(0xFFE0F7FA), const Color(0xFF00BCD4));
    case TransactionCategory.income:
      return (const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
    default:
      return (const Color(0xFFF5F5F5), const Color(0xFF9E9E9E));
  }
}