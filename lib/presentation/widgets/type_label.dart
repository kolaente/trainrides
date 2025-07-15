import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class TypeLabel extends StatelessWidget {
  final String type;
  final double fontSize;
  final EdgeInsets padding;

  const TypeLabel({
    super.key,
    required this.type,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.getBaserowColorForType(type);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: typeColor, width: 1),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: AppTheme.getTextColorForBackground(typeColor),
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
