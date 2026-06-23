import 'package:flutter/material.dart';

import '../../../../core/widgets/swiss.dart';

/// Divider ala Swiss — hairline dengan label kecil uppercase.
class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: SwissHairline()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SwissLabel(text),
        ),
        const Expanded(child: SwissHairline()),
      ],
    );
  }
}