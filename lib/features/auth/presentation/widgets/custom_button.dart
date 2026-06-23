import 'package:flutter/material.dart';

import '../../../../core/widgets/swiss.dart';

enum ButtonVariant { primary, outlined, text }

/// Tombol ala Swiss — selalu square, uppercase dengan tracking lebar.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return SwissPrimaryButton(
          label: label,
          onPressed: onPressed,
          loading: isLoading,
        );
      case ButtonVariant.outlined:
        return SwissOutlineButton(
          label: label,
          onPressed: onPressed,
          loading: isLoading,
        );
      case ButtonVariant.text:
        final onSurface = Theme.of(context).colorScheme.onSurface;
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: onSurface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: onSurface,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[icon!, const SizedBox(width: 8)],
                      Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
          ),
        );
    }
  }
}