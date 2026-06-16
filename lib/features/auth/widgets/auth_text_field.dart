import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.lable,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.isPasswordVisible = false,
    this.isPassword = false,
    this.onToggleVisibility,
    this.keynoardType = TextInputType.text,
  });
  final String lable;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final bool isPasswordVisible;
  final bool isPassword;
  final VoidCallback? onToggleVisibility;
  final TextInputType keynoardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lable,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 5),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkField
                : AppColors.lightField,
            borderRadius: BorderRadius.circular(13),
          ),
          child: TextField(
            onChanged: onChanged,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keynoardType,
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
             suffixIcon: (isPassword && onToggleVisibility != null)
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
