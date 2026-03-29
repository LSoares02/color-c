import 'package:flutter/material.dart';

void clearToast(BuildContext context) {
  ScaffoldMessenger.of(context).clearSnackBars();
}

void showToast(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 5),
}) {
  final messenger = ScaffoldMessenger.of(context);
  final theme = Theme.of(context);

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onInverseSurface),
      ),
      action:
          actionLabel != null && onAction != null
              ? SnackBarAction(
                label: actionLabel,
                textColor: theme.colorScheme.inversePrimary,
                onPressed: onAction,
              )
              : null,
      backgroundColor: theme.colorScheme.inverseSurface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      duration: duration,
    ),
  );
}
