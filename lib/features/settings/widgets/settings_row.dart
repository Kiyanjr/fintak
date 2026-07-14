import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// This is a reusable row widget used for every setting item in the list — dark mode,
// notifications, biometric, change password etc.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Icon(
              icon,
              size: 18,
              color: isDestructive
                  ? AppColors.red
                  : onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.red : onSurface,
                ),
              ),
            ),
            // Trailing widget (pushed cleanly to the right)
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// AppToggle widget
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 44, // Slightly wider for smoother proportions
        height: 24, // Standard pill height
        padding: const EdgeInsets.all(2), // Clean inner gap
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: value
              ? AppColors.accent
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}