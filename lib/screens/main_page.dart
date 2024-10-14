import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'footer.dart';
import '../widgets/event_form.dart';
import '../widgets/event_card.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(authProvider.isLoggedIn
            ? "Hello, ${authProvider.currentUser?.displayName ?? 'User'}"
            : "Main App"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Your events will be here",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          if (authProvider.isLoggedIn)
            ElevatedButton(
              onPressed: authProvider.signOut,
              child: const Text('Log Out'),
            )
          else
            const Text("Not logged in"),
          const SizedBox(height: 20),
          ...List.generate(34, (index) {
            return EventCard(number: index + 1);
          }),
        ],
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
