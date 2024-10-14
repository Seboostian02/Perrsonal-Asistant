import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  final double _iconSize = 30.0;
  static const double _sizeBoxWidth = 30.0;
  final Color iconColor = Colors.white;
  static final Color footerColor = Colors.deepPurple.shade600;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: footerColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
                iconSize: _iconSize,
                color: iconColor,
              ),
              const SizedBox(width: _sizeBoxWidth),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
                iconSize: _iconSize,
                color: iconColor,
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
                iconSize: _iconSize,
                color: iconColor,
              ),
              const SizedBox(width: _sizeBoxWidth),
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {},
                iconSize: _iconSize,
                color: iconColor,
              ),
            ],
          ),
        ],
      ),
      // Mutăm butonul de acțiune la MainPage
    );
  }
}
