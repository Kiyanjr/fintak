
import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, this.onPressed,  this.isLoading=false});

final String label;
final VoidCallback ? onPressed;
final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
        ),
        child:isLoading ? 
         SizedBox(
          width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
         ) : Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
      ),
      );
  }
}