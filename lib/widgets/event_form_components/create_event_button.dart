import 'package:flutter/material.dart';

class CreateEventButton extends StatelessWidget {
  final Function onPressed;

  const CreateEventButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      child: const Text('Create Event'),
    );
  }
}
