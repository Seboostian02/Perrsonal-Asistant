import 'package:flutter/material.dart';
import '../widgets/event_form.dart';

class TimePickerScreen extends StatelessWidget {
  const TimePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(title: const Text('Create Event')),
      body: EventForm(),
    );
  }
}
