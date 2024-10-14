import 'package:flutter/material.dart';
import 'footer.dart';
import '../widgets/event_form.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  void _showEventForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(16.0),
        child: EventForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main App"),
      ),
      body: const Center(
        child: Text("Your events will be here"),
      ),
      bottomNavigationBar: const Footer(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: FloatingActionButton(
          onPressed: () => _showEventForm(context),
          backgroundColor: Colors.deepPurple.shade600,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
