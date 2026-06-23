import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_theme.dart';

/// Kumpulan primitif UI Swiss-style yang dipakai lintas halaman.
///
/// Konvensi:
/// - [SwissLabel]     → uppercase, tracking lebar (label/kategori).
/// - [SwissHairline]  → pembatas horizontal 1px.
/// - [SwissNumber]    → angka tabular dengan prefix opsional.
/// - [SwissTag]       → chip kotak kecil (selected/unselected).
/// - [SwissRow]       → baris dua kolom dengan label kecil + nilai.
class SwissLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double letterSpacing;

  const SwissLabel(
    this.text, {
    super.key,
    this.color,
    this.letterSpacing = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.labelMedium;
    return Text(
      text.toUpperCase(),
      style: base?.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurface,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

/// Garis horizontal 1px (menggantikan Divider agar konsisten).
class SwissHairline extends StatelessWidget {
  final double indent;
  final double endIndent;
  final Color? color;

  const SwissHairline({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      color: color ?? Theme.of(context).dividerColor,
    );
  }
}

/// Angka tabular ala Swiss (mis. harga, ID order).
class SwissNumber extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color? color;

  const SwissNumber(
    this.text, {
    super.key,
    this.size = 14,
    this.weight = FontWeight.w700,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.mono.copyWith(
        fontSize: size,
        fontWeight: weight,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Chip kotak dengan dua state (selected / unselected).
class SwissTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  const SwissTag({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = selected
        ? (isDark ? AppColors.darkTextInverse : AppColors.textInverse)
        : Theme.of(context).colorScheme.onSurface;
    final bg = selected
        ? Theme.of(context).colorScheme.onSurface
        : Colors.transparent;
    final border = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baris label kecil (uppercase) di atas konten besar — header section.
class SwissSection extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final EdgeInsets padding;

  const SwissSection({
    super.key,
    required this.label,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 32, 20, 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwissLabel(label),
                const SizedBox(height: 6),
                Container(
                  width: 24,
                  height: 1,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Baris label–nilai dengan label kecil di atas nilai.
class SwissRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monoValue;
  final bool valueBold;

  const SwissRow({
    super.key,
    required this.label,
    required this.value,
    this.monoValue = false,
    this.valueBold = true,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SwissLabel(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: monoValue
              ? AppTheme.mono.copyWith(
                  fontSize: 16,
                  fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
                  color: valueColor,
                )
              : TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 16,
                  fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
                  color: valueColor,
                  height: 1.3,
                ),
        ),
      ],
    );
  }
}

/// Kotak bernomor Swiss (Müller-Brockmann style) — dipakai untuk step/list.
class SwissNumberBox extends StatelessWidget {
  final String number;
  final bool filled;

  const SwissNumberBox({
    super.key,
    required this.number,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? onSurface : Colors.transparent,
        border: Border.all(color: onSurface, width: 1),
      ),
      child: Text(
        number,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: filled
              ? Theme.of(context).colorScheme.surface
              : onSurface,
        ),
      ),
    );
  }
}

/// Tombol aksi utama (primary) ala Swiss — full-width, uppercase, square.
class SwissPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const SwissPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          foregroundColor: Theme.of(context).colorScheme.surface,
          disabledBackgroundColor: Theme.of(context).dividerColor,
          disabledForegroundColor: Theme.of(context).hintColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Theme.of(context).colorScheme.surface,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
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

/// Tombol outlined Swiss — full-width, uppercase, square, hairline border.
class SwissOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;

  const SwissOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          side: BorderSide(color: c, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: c,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: c,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}