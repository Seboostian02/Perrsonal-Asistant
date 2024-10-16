import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(BuildContext, bool) onTimeSelected;

  const TimeSelector({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Start time: ${startTime.format(context)}',
          style: const TextStyle(fontSize: 24),
        ),
        ElevatedButton(
          onPressed: () => onTimeSelected(context, true),
          child: const Text('Pick Start Time'),
        ),
        const SizedBox(height: 20),
        Text(
          'End time: ${endTime.format(context)}',
          style: const TextStyle(fontSize: 24),
        ),
        ElevatedButton(
          onPressed: () => onTimeSelected(context, false),
          child: const Text('Pick End Time'),
        ),
      ],
    );
  }
}
