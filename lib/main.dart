import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_page.dart';
import 'screens/login_page.dart';
import 'services/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            home:
                authProvider.isLoggedIn ? const MainPage() : const LoginPage(),
          );
        },
      ),
    );
  }
}
