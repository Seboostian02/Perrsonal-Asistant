import 'package:calendar/widgets/icont_text_button.dart';
import 'package:flutter/material.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  static const double _sizeBoxWidth = 30.0;

  @override
  FooterState createState() => FooterState();
}

class FooterState extends State<Footer> {
  static final Color footerColor = Colors.deepPurple.shade600;

  bool _isHomePressed = true;
  bool _isMapPressed = false;
  bool _isSettingsPressed = false;
  bool _isProfilePressed = false;

  void _onButtonPressed(String button) {
    setState(() {
      _isHomePressed = false;
      _isMapPressed = false;
      _isSettingsPressed = false;
      _isProfilePressed = false;

      if (button == 'home') {
        _isHomePressed = true;
      } else if (button == 'map') {
        _isMapPressed = true;
      } else if (button == 'settings') {
        _isSettingsPressed = true;
      } else if (button == 'profile') {
        _isProfilePressed = true;
      }
    });
  }

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
                    _onButtonPressed('home');
                  },
                  isPressed: _isHomePressed,
                ),
                const SizedBox(width: Footer._sizeBoxWidth),
                IconTextButton(
                  icon: Icons.map,
                  label: 'Map',
                  onPressed: () {
                    _onButtonPressed('map');
                  },
                  isPressed: _isMapPressed,
                ),
              ],
            ),
            Row(
              children: [
                IconTextButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onPressed: () {
                    _onButtonPressed('settings');
                  },
                  isPressed: _isSettingsPressed,
                ),
                const SizedBox(width: Footer._sizeBoxWidth),
                IconTextButton(
                  icon: Icons.people_alt,
                  label: 'Profile',
                  onPressed: () {
                    _onButtonPressed('profile');
                  },
                  isPressed: _isProfilePressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
