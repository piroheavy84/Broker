import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/broker_api.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  bool loading = true;
  List<dynamic> clients = [];

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    try {
      final result = await BrokerApi.getClients();

      setState(() {
        clients = result["clients"] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore caricamento clienti: $e"),
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

  Widget clientCard(Map<String, dynamic> client) {
    final ultimoPreventivo =
        client["ultimo_preventivo"]?.toString() ?? "";

    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(
          client["cliente"]?.toString() ?? "Cliente",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Ultimo preventivo: ${client["ultimo_preventivo_data"]}\n"
          "Importo: ${euro(client["importo"])} | Durata: ${client["durata"]} anni\n"
          "Prodotti selezionati: ${client["prodotti"]}",
        ),
        isThreeLine: true,
        trailing: ElevatedButton.icon(
          onPressed: ultimoPreventivo.isEmpty
              ? null
              : () {
                  openQuote(ultimoPreventivo);
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
        title: const Text("Archivio Clienti"),
        actions: [
          IconButton(
            onPressed: loadClients,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : clients.isEmpty
              ? const Center(
                  child: Text(
                    "Nessun cliente salvato.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    return clientCard(
                      Map<String, dynamic>.from(
                        clients[index],
                      ),
                    );
                  },
                ),
    );
  }
}