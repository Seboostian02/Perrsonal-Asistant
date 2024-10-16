import 'package:flutter/material.dart';

class EventTitleField extends StatelessWidget {
  final TextEditingController controller;

  const EventTitleField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      controller: controller,
      decoration: const InputDecoration(labelText: 'Event Title'),
    );
  }
}
