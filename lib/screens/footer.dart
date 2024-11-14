import 'package:calendar/utils/colors.dart';
import 'package:calendar/widgets/icont_text_button.dart';
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final Function(int) onItemTapped;
  final int selectedIndex;
  static final Color footerColor = AppColors.primaryColor;
  const Footer(
      {super.key, required this.onItemTapped, required this.selectedIndex});

  static const double _sizeBoxWidth = 30.0;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: footerColor,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconTextButton(
                  icon: Icons.home,
                  label: 'Home',
                  onPressed: () {
                    onItemTapped(0);
                  },
                  isPressed: selectedIndex == 0,
                ),
                const SizedBox(width: _sizeBoxWidth),
                IconTextButton(
                  icon: Icons.map,
                  label: 'Map',
                  onPressed: () {
                    onItemTapped(1);
                  },
                  isPressed: selectedIndex == 1,
                ),
              ],
            ),
            Row(
              children: [
                IconTextButton(
                  icon: Icons.cloud,
                  label: 'Weather',
                  onPressed: () {
                    onItemTapped(2);
                  },
                  isPressed: selectedIndex == 2,
                ),
                const SizedBox(width: _sizeBoxWidth),
                IconTextButton(
                  icon: Icons.people_alt,
                  label: 'Profile',
                  onPressed: () {
                    onItemTapped(3);
                  },
                  isPressed: selectedIndex == 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
