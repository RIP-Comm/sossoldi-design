import 'package:flutter/material.dart';

import 'design_system/design_system.dart';

void main() {
  runApp(const SossoldiApp());
}

class SossoldiApp extends StatelessWidget {
  const SossoldiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SossoldiTheme.light,
      darkTheme: SossoldiTheme.dark,
      // Screens are added feature by feature, from Figma.
      home: const Scaffold(),
    );
  }
}
