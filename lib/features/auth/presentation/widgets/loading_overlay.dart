import 'package:flutter/material.dart';

/// Overlay loading ala Swiss — full hitam 60% dengan spinner
/// dan label kecil uppercase di bawahnya.
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Container(width: 32, height: 1, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        message!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}