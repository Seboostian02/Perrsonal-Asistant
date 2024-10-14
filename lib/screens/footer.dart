import 'package:calendar/widgets/icont_text_button.dart';
import 'package:flutter/material.dart';

class Footer extends StatefulWidget {
  const Footer(
      {super.key,
      required this.onItemTapped}); // Acceptă un parametru pentru callback

  final ValueChanged<int> onItemTapped; // Definește un tip pentru callback

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

  void _onButtonPressed(int index) {
    setState(() {
      _isHomePressed = index == 0;
      _isMapPressed = index == 1;
      _isSettingsPressed = index == 2;
      _isProfilePressed = index == 3;
    });

    // Apelează callback-ul pentru a schimba pagina
    widget.onItemTapped(index);
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
                    _onButtonPressed(0);
                  },
                  isPressed: _isHomePressed,
                ),
                const SizedBox(width: Footer._sizeBoxWidth),
                IconTextButton(
                  icon: Icons.map,
                  label: 'Map',
                  onPressed: () {
                    _onButtonPressed(1);
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
                    _onButtonPressed(2);
                  },
                  isPressed: _isSettingsPressed,
                ),
                const SizedBox(width: Footer._sizeBoxWidth),
                IconTextButton(
                  icon: Icons.people_alt,
                  label: 'Profile',
                  onPressed: () {
                    _onButtonPressed(3);
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
