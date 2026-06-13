import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor
  AppTheme._();

  //-----------------LIGHT THEME---------------------
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,

    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSurface: Color(0XFF111111),
    ),
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF111111)),
      titleTextStyle: TextStyle(
        color: Color(0xFF111111),
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.lightBg,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior
          .alwaysShow, //<---alwyas display the text labels for every navigation item
      iconTheme: WidgetStateProperty.resolveWith(
        //current state of widget
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent, size: 22);
          }
          return const IconThemeData(color: Color(0xFFCCCCCC), size: 22);
        },
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.accent,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(color: Color(0xFFCCCCCC), fontSize: 10);
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 0,
    ),
  );

  //-----------------DARK THEME---------------------

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSurface: Color(0xFFEEEEFF),
    ),
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFEEEEFF)),
      titleTextStyle: TextStyle(
        color: Color(0xFFEEEEFF),
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.darkBg,
    indicatorColor: Colors.transparent,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    iconTheme: WidgetStateProperty.resolveWith(
      (states){
        if(states.contains(WidgetState.selected)){
          return const IconThemeData(color: Color(0xFF8B83FF),size:22);
        }
        return const IconThemeData(color:Color(0xff383848),size:22);
      }
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states){
        if(states.contains(WidgetState.selected)){
          return const TextStyle(
            color: Color(0xFF8B83FF),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(
          color: Color(0xFF383848),
          fontSize: 10,
        );
      }
    ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 0,
    )
  );

}
