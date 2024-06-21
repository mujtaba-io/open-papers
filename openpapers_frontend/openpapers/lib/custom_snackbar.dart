import 'package:flutter/material.dart';

void showCustomSnackBar(
    BuildContext context, String message, SnackBarAction? customActions) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF0E0D14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      action: customActions,
    ),
  );
}
