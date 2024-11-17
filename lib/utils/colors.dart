import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Deep Purple palette)
  static const Color primaryColor = Color(0xFF512DA8); // Deep Purple 600
  static const Color primaryLightColor =
      Color.fromARGB(255, 213, 187, 254); // Lighter Deep Purple
  static const Color primaryDarkColor = Color(0xFF320B86); // Dark Deep Purple

  // Secondary Colors (Purple palette)
  static const Color secondaryColor = Color(0xFF673AB7); // Purple 600
  static const Color secondaryLightColor =
      Color(0xFF9575CD); // Light secondary purple
  static const Color secondaryDarkColor =
      Color(0xFF512DA8); // Dark secondary purple

  static const Color iconColor = Color.fromARGB(255, 255, 255, 255);
  static const Color iconPressedColor = const Color.fromRGBO(255, 235, 59, 1);
  static const Color textColor = Color.fromARGB(255, 255, 255, 255);
  static const Color linkColor = Color.fromARGB(255, 2, 179, 255);

  static const Color locationMarkerColor = Color.fromRGBO(244, 67, 54, 1);

  // Card and Background Colors
  static const Color footerColor = Color(0xFF512DA8);
  static const Color dividerColor =
      Color(0xFFBDBDBD); // Light grey color for dividers
  static const Color cardColor = Colors.white; // White color for the card

  // Priority Colors
  static const Color lowPriorityColor =
      Color.fromARGB(255, 233, 218, 255); // Lumină, pentru prioritate scăzută
  static const Color mediumPriorityColor =
      Color.fromARGB(255, 213, 187, 254); // Culoare de bază
  static const Color highPriorityColor =
      Color.fromARGB(255, 197, 158, 255); // Mai închis, pentru prioritate mare
}
