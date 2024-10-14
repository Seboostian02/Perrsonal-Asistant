import 'package:calendar/widgets/icont_text_button.dart';
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  static const double _sizeBoxWidth = 30.0;
  static final Color footerColor = Colors.deepPurple.shade600;

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
                  onPressed: () {},
                ),
                const SizedBox(width: _sizeBoxWidth),
                IconTextButton(
                  icon: Icons.search,
                  label: 'Search',
                  onPressed: () {},
                ),
              ],
            ),
            Row(
              children: [
                IconTextButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onPressed: () {},
                ),
                const SizedBox(width: _sizeBoxWidth),
                IconTextButton(
                  icon: Icons.people_alt,
                  label: 'Profile',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
