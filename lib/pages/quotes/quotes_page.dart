import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/broker_api.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  bool loading = true;
  List<dynamic> quotes = [];

  @override
  void initState() {
    super.initState();
    loadQuotes();
  }

  Future<void> loadQuotes() async {
    try {
      final result = await BrokerApi.getQuotes();

      setState(() {
        quotes = result["quotes"] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore caricamento preventivi: $e"),
        ),
      );
    }
  }

  Future<void> openQuote(String filename) async {
    final uri = Uri.parse(
      BrokerApi.quoteUrl(filename),
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  String euro(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;

    return "€ ${number.toStringAsFixed(2)}";
  }

  Widget quoteCard(Map<String, dynamic> quote) {
    final filename = quote["filename"]?.toString() ?? "";

    return Card(
      child: ListTile(
        leading: const Icon(Icons.description),
        title: Text(
          quote["cliente"]?.toString().isEmpty == true
              ? "Preventivo senza cliente"
              : quote["cliente"]?.toString() ?? "Preventivo",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Data: ${quote["created_at"]}\n"
          "Importo: ${euro(quote["importo"])} | Durata: ${quote["durata"]} anni\n"
          "Prodotti selezionati: ${quote["prodotti"]}",
        ),
        isThreeLine: true,
        trailing: ElevatedButton.icon(
          onPressed: filename.isEmpty
              ? null
              : () {
                  openQuote(filename);
                },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Apri PDF"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archivio Preventivi"),
        actions: [
          IconButton(
            onPressed: loadQuotes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : quotes.isEmpty
              ? const Center(
                  child: Text(
                    "Nessun preventivo salvato.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    return quoteCard(
                      Map<String, dynamic>.from(
                        quotes[index],
                      ),
                    );
                  },
                ),
    );
  }
}