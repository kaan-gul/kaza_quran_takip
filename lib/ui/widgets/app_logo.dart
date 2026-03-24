import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final circleSize = size;
    const logoColor = Color(0xFF009688);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: logoColor,
            boxShadow: [
              BoxShadow(
                color: logoColor,
                blurRadius: 20,
                spreadRadius: 2,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.mosque_rounded,
                color: Colors.white,
                size: circleSize * 0.45,
              ),
              SizedBox(width: circleSize * 0.1),
              Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: circleSize * 0.45,
              ),
            ],
          ),
        ),
        SizedBox(height: circleSize * 0.25),
        Text(
          'Namaz & Kur\'an Takip',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
