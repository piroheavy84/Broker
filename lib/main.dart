import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/home/home_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KironBrokerEngine(),
    ),
  );
}

class KironBrokerEngine extends StatelessWidget {
  const KironBrokerEngine({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kiron Broker Engine",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}