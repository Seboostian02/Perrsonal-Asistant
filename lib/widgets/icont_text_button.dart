import 'package:TimeBuddy/utils/colors.dart';
import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPressed;

  const IconTextButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPressed = false,
  });

  static Color isPressedColor = AppColors.iconPressedColor;
  static Color isNotPressedColor = AppColors.iconColor;
  static FontWeight isPressedText = FontWeight.w900;
  static FontWeight isNotPressedText = FontWeight.normal;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isPressed ? isPressedColor : isNotPressedColor,
            size: 30.0,
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: isPressed ? isPressedColor : isNotPressedColor,
            fontWeight: isPressed ? isPressedText : isNotPressedText,
          ),
        ),
      ],
    );
  }
}
