import 'package:flutter/material.dart';

import '../../../../core/widgets/swiss.dart';

/// Header halaman auth dengan gaya Swiss — label kecil + judul besar
/// + underline tipis sebagai hairline divider visual.
class AuthHeader extends StatelessWidget {
  final IconData? icon;
  final String kicker;
  final String title;
  final String? subtitle;

  const AuthHeader({
    super.key,
    this.icon,
    required this.kicker,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 8),
            ],
            SwissLabel(kicker),
          ],
        ),
        const SizedBox(height: 16),
        Container(width: 32, height: 1, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: -0.8,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                      height: 1.45,
                    ),
          ),
        ],
      ],
    );
  }
}