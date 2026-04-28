import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? const Color(0xFF1B5E20);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: size * 0.75,
              height: size * 0.75,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              Icons.eco,
              color: themeColor,
              size: size * 0.5,
            ),
            Positioned(
              right: size * 0.1,
              bottom: size * 0.1,
              child: Icon(
                Icons.favorite,
                color: Colors.orange,
                size: size * 0.25,
              ),
            ),
          ],
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'Organic',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.bold,
              color: themeColor,
              height: 0.9,
            ),
          ),
          Text(
            'Vitality',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.bold,
              color: themeColor,
              height: 0.9,
            ),
          ),
        ],
      ],
    );
  }
}
