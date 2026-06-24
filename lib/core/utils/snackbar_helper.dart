import 'package:flutter/material.dart';
import 'package:flutter_assignment/core/utils/extension.dart';

class SnackbarHelper {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, backgroundColor: Colors.green.shade700);
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: message.textMedium(),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
