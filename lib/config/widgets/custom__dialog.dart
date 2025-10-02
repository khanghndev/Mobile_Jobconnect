import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.help_outline_rounded,
    this.iconColor,
    this.cancelText = "Hủy",
    this.confirmText = "Xác nhận",
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha:0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                          if (onCancel != null) onCancel!();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          side: BorderSide(
                            color: theme.dividerColor.withValues(alpha:0.7),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                          if (onConfirm != null) onConfirm!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmButtonColor ?? theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          confirmText,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}