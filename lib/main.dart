import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/time_picker_screen.dart';

void main() async {
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey:
  //         "AIzaSyBBdtTxLfn2lV5X_QC8-VYTtysvboiCDJg", // paste your api key here
  //     appId:
  //         "1:1018588279964:android:ee2ef4af8270aaf6052959", //paste your app id here
  //     messagingSenderId: "1018588279964", //paste your messagingSenderId here
  //     projectId: "calendar-e5714", //paste your project id here
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TimePickerScreen(),
    );
  }
}
