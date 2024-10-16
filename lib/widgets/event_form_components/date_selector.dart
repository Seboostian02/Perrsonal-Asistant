import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(BuildContext) onDateSelected;

  const DateSelector({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Selected date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
          onPressed: () => onDateSelected(context),
          child: const Text('Pick Date'),
        ),
      ],
    );
  }
}
