import 'package:flutter/material.dart';

class FloatingSnackbar {
  static SnackBar? _currentSnackbar;
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    if (_currentSnackbar != null) return; // Agar snackbar mavjud bo'lsa, yangi snackbar ko'rsatilmaydi

    _currentSnackbar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 3),
    );

    messenger.showSnackBar(_currentSnackbar!).closed.then((_) {
      _currentSnackbar = null; // Snackbar yopilgandan keyin uni tozalaymiz
    });
  }
}
