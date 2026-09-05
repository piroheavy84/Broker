import 'package:flutter/material.dart';

import '../../services/broker_api.dart';

class BankMemoryPage extends StatefulWidget {
  final String banca;

  const BankMemoryPage({
    super.key,
    required this.banca,
  });

  @override
  State<BankMemoryPage> createState() => _BankMemoryPageState();
}

class _BankMemoryPageState extends State<BankMemoryPage> {
  bool loading = true;

  Map<String, dynamic> memory = {};

  final List<String> dynamicCategories = const [
    "frasi_confermate",
    "autonomi",
    "dipendenti",
    "pensionati",
    "redditi_esteri",
    "garanti",
    "coobbligati",
    "classe_energetica",
    "polizze",
    "deroghe",
    "istruttoria",
    "perizia",
    "durata",
    "ltv",
    "eta",
    "finalita",
  ];

  @override
  void initState() {
    super.initState();
    loadMemory();
  }

  Future<void> loadMemory() async {
    try {
      final response = await BrokerApi.getBankMemory(
        widget.banca,
      );

      setState(() {
        memory = Map<String, dynamic>.from(
          response["memory"] ?? {},
        );

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  String labelCategory(String key) {
    switch (key) {
      case "frasi_confermate":
        return "Frasi confermate";
      case "redditi_esteri":
        return "Redditi esteri";
      case "classe_energetica":
        return "Classe energetica / Green";
      case "coobbligati":
        return "Coobbligati";
      case "istruttoria":
        return "Istruttoria";
      case "perizia":
        return "Perizia";
      case "durata":
        return "Durata";
      case "ltv":
        return "LTV";
      case "eta":
        return "Età";
      case "finalita":
        return "Finalità";
      default:
        return key[0].toUpperCase() + key.substring(1).replaceAll("_", " ");
    }
  }

  Widget section(
    String key,
    dynamic rows,
  ) {
    final list = List<dynamic>.from(
      rows ?? [],
    );

    return Card(
      child: ExpansionTile(
        initiallyExpanded: list.isNotEmpty,
        title: Text(
          labelCategory(key),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text("${list.length} elementi"),
        childrenPadding: const EdgeInsets.all(14),
        children: [
          if (list.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Nessun dato"),
            ),
          for (final row in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("• $row"),
              ),
            ),
        ],
      ),
    );
  }

  Widget valueCard(
    String title,
    dynamic value,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value == null ? "-" : value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget summaryCard() {
    int totalRows = 0;

    for (final category in dynamicCategories) {
      final rows = memory[category];

      if (rows is List) {
        totalRows += rows.length;
      }
    }

    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading: const Icon(Icons.memory),
        title: const Text(
          "Memoria banca",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Categorie monitorate: ${dynamicCategories.length}\n"
          "Frasi memorizzate: $totalRows",
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Memoria ${widget.banca}",
        ),
        actions: [
          IconButton(
            onPressed: loadMemory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          summaryCard(),

          const SizedBox(height: 20),

          const Text(
            "Parametri banca",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          valueCard(
            "Età massima letta/confermata dal PDF",
            memory["eta_massima"],
          ),

          valueCard(
            "Età massima a fine mutuo (manuale)",
            memory["eta_massima_finanziabile"],
          ),

          valueCard(
            "Metodo calcolo debiti",
            memory["calcolo_debito"],
          ),

          valueCard(
            "Rapporto rata/reddito (%)",
            memory["rapporto_rata_reddito_percentuale"],
          ),

          valueCard(
            "LTV massimo",
            memory["ltv_massimo"],
          ),

          valueCard(
            "Prima casa",
            memory["prima_casa"],
          ),

          valueCard(
            "Seconda casa",
            memory["seconda_casa"],
          ),

          valueCard(
            "Surroga",
            memory["surroga"],
          ),

          valueCard(
            "Liquidità",
            memory["liquidita"],
          ),

          valueCard(
            "Consolidamento",
            memory["consolidamento"],
          ),

          valueCard(
            "Green",
            memory["green"],
          ),

          const SizedBox(height: 25),

          const Text(
            "Categorie e frasi memorizzate",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          for (final category in dynamicCategories)
            section(
              category,
              memory[category],
            ),
        ],
      ),
    );
  }
}