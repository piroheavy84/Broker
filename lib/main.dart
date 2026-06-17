import 'package:flutter/material.dart';
import 'pages/home/home_page.dart';

void main() {
  runApp(const KironBrokerEngine());
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