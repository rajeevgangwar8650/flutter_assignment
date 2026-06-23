import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  );
}
