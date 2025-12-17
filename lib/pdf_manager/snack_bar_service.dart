import 'package:flutter/material.dart';

class SnackBarService {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    );
  }

  static void showWarning(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 2),
    );
  }
}
