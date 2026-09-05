import 'dart:math';

import 'package:flutter/material.dart';

class LoanCalculatorPage extends StatefulWidget {
  const LoanCalculatorPage({super.key});

  @override
  State<LoanCalculatorPage> createState() => _LoanCalculatorPageState();
}

class _LoanCalculatorPageState extends State<LoanCalculatorPage> {
  final importoController = TextEditingController();
  final durataController = TextEditingController();
  final tassoController = TextEditingController();

  double parseValue(String value) {
    return double.tryParse(
          value.replaceAll(".", "").replaceAll(",", "."),
        ) ??
        0;
  }

  double rataMensile() {
    final importo = parseValue(importoController.text);
    final anni = parseValue(durataController.text);
    final tasso = parseValue(tassoController.text);

    final mesi = (anni * 12).round();

    if (importo <= 0 || mesi <= 0) {
      return 0;
    }

    final tassoMensile = tasso / 100 / 12;

    if (tassoMensile == 0) {
      return importo / mesi;
    }

    return importo *
        (tassoMensile / (1 - pow(1 + tassoMensile, -mesi)));
  }

  double totaleInteressi() {
    final importo = parseValue(importoController.text);
    final anni = parseValue(durataController.text);
    final mesi = (anni * 12).round();

    return (rataMensile() * mesi) - importo;
  }

  double interessiMediMensili() {
    final anni = parseValue(durataController.text);
    final mesi = (anni * 12).round();

    if (mesi <= 0) {
      return 0;
    }

    return totaleInteressi() / mesi;
  }

  double costoTotale() {
    final importo = parseValue(importoController.text);

    return importo + totaleInteressi();
  }

  String euro(double value) {
    return "€ ${value.toStringAsFixed(2)}";
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) {
        setState(() {});
      },
    );
  }

  Widget resultCard({
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    importoController.dispose();
    durataController.dispose();
    tassoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rata = rataMensile();
    final interessiMedi = interessiMediMensili();
    final interessiTotali = totaleInteressi();
    final totale = costoTotale();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calcolatore Rata"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "CALCOLATORE RATA MUTUO",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          inputField(
            controller: importoController,
            label: "Importo mutuo (€)",
          ),

          const SizedBox(height: 15),

          inputField(
            controller: durataController,
            label: "Durata mutuo (anni)",
          ),

          const SizedBox(height: 15),

          inputField(
            controller: tassoController,
            label: "Tasso finito annuo (%)",
          ),

          const SizedBox(height: 25),

          resultCard(
            title: "Rata mensile",
            value: euro(rata),
          ),

          resultCard(
            title: "Interessi medi mensili",
            value: euro(interessiMedi),
          ),

          resultCard(
            title: "Totale interessi",
            value: euro(interessiTotali),
          ),

          resultCard(
            title: "Costo totale",
            value: euro(totale),
          ),
        ],
      ),
    );
  }
}