import 'package:flutter/material.dart';

class EventDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const EventDescriptionField({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      controller: controller,
      decoration: const InputDecoration(labelText: 'Descriere'),
    );
  }
}
