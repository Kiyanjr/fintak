import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit; // Added optional edit callback

  const TransactionTile({
    super.key, 
    required this.transaction,
    this.onDelete,
    this.onEdit, // Default is null
  });

  // Maping enums into icons
  IconData _getCategoryIcon(TransactionCategory category) {
    return switch (category) {
      TransactionCategory.food => Icons.restaurant_rounded,
      TransactionCategory.income => Icons.attach_money_rounded,
      TransactionCategory.transport => Icons.directions_car_rounded,
      TransactionCategory.entertainment => Icons.sports_esports_rounded,
      TransactionCategory.shopping => Icons.shopping_bag_rounded,
      TransactionCategory.housing => Icons.house_rounded,
      TransactionCategory.salary => Icons.work_rounded,
      TransactionCategory.freelance => Icons.laptop_mac_rounded,
      TransactionCategory.health => Icons.favorite_border_rounded,
      TransactionCategory.other => Icons.more_horiz_rounded,
      TransactionCategory.utilities => Icons.water_drop_rounded,
    };
  }

  // Output of two background colors and the icon colors
  (Color, Color) _getCategoryColors(TransactionCategory category) {
    return switch (category) {
      TransactionCategory.food => (AppColors.catFoodBg, AppColors.catFood),
      TransactionCategory.transport => (
        AppColors.catTransportBg,
        AppColors.catTransport,
      ),
      TransactionCategory.income => (
        AppColors.catincomeBg,
        AppColors.catincome,
      ),
      TransactionCategory.entertainment => (
        AppColors.catEntertainBg,
        AppColors.catEntertain,
      ),
      TransactionCategory.shopping => (
        AppColors.catShoppingBg,
        AppColors.catShopping,
      ),
      TransactionCategory.health => (
        AppColors.catHealthBg,
        AppColors.catHealth,
      ),
      TransactionCategory.salary => (
        AppColors.catSalaryBg,
        AppColors.catSalary,
      ),
      TransactionCategory.housing => (
        AppColors.catHousingBg,
        AppColors.catHousing,
      ),
      TransactionCategory.utilities => (
        AppColors.catutilitiesBg,
        AppColors.catutilities,
      ),
      TransactionCategory.freelance => (
        AppColors.catFreelanceBg,
        AppColors.catFreelance,
      ),
      TransactionCategory.other => (AppColors.catOtherBg, AppColors.catOther),
    };
  }

  String _fromatDateAndCategory(TransactionModel transaction) {
    final dateString = DateFormat('MMM d').format(transaction.date);
    final categoryString = transaction.category.name;
    final categoryLabel =
        categoryString[0].toUpperCase() + categoryString.substring(1);
    return '$dateString · $categoryLabel';
  }

  String _formatAmount(TransactionModel transaction) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    return '$prefix${formatter.format(transaction.amount)}';
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 198, 14, 14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.delete_rounded,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final (bgColor, iconColor) = _getCategoryColors(transaction.category);

    final tileContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          // Category icon container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: iconColor,
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 11),
          // Title + date column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        transaction.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatAmount(transaction),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: transaction.type == TransactionType.income
                            ? Colors.green
                            : const Color.fromARGB(255, 198, 14, 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _fromatDateAndCategory(transaction),
                  style: TextStyle(
                    fontSize: 10,
                    color: onSurfaceColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final tile = GestureDetector(
      onLongPress: onEdit, // Added GestureDetector to handle onLongPress for edit trigger
      child: tileContent,
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      onDismissed: (_) => onDelete?.call(),
      child: tile,
    );
  }
}