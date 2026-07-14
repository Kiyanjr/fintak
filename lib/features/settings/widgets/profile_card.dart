import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

//Simple display card.
class ProfileCard extends StatelessWidget {
  final String name;
  final String email;

  const ProfileCard({super.key, required this.name, required this.email});

  // Helper method to extract initials from full name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length > 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          //  Avatar Circle with Initials
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                _getInitials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // NAME + EMAIL + PRO PLAN BADGE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 11,
                    color: onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Pro plan',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Chevron Right Icon
          Icon(
            Icons.chevron_right_rounded,
            color: onSurface.withOpacity(0.3),
          ),
        ], // last
      ),
    );
  }
}
