import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_page.dart';
import 'screens/login_page.dart';
import 'services/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final hasPermission = await _checkLocationPermission();

  runApp(MyApp(hasLocationPermission: hasPermission));
}

Future<bool> _checkLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isDenied) {
    await Permission.location.request();

    status = await Permission.location.status;
  }
  return status.isGranted;
}

class MyApp extends StatelessWidget {
  final bool hasLocationPermission;
  
  const MyApp({super.key, required this.hasLocationPermission});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            home: hasLocationPermission
                ? (authProvider.isLoggedIn
                    ? const MainPage()
                    : const LoginPage())
                : const LocationPermissionPage(),
          );
        },
      ),
    );
  }
}

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Permission')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'This app needs location permission to function properly.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkLocationPermission().then((hasPermission) {
                  if (hasPermission) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  }
                });
              },
              child: const Text('Request Location Permission'),
            ),
          ],
        ),
      ),
    );
  }
}
