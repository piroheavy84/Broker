import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/practice_provider.dart';
import '../../services/broker_api.dart';
import '../admin/banks_page.dart';
import '../clients/clients_page.dart';
import '../practice/client_page.dart';
import '../quotes/quotes_page.dart';
import '../tools/loan_calculator_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Map<String, dynamic>? rates;
  List<dynamic> banks = [];

  bool loadingRates = true;

  final String irsUrl =
      "https://mutuionline.24oreborsaonline.ilsole24ore.com/guide-mutui/irs.asp";

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final ratesData = await BrokerApi.getRates();
      final banksData = await BrokerApi.getBanks();

      setState(() {
        rates = ratesData;
        banks = banksData["banks"] ?? [];
        loadingRates = false;
      });
    } catch (e) {
      setState(() {
        loadingRates = false;
      });
    }
  }

  Future<void> openIrsWebsite() async {
    final uri = Uri.parse(irsUrl);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> showIrsDialog() async {
    final controller = TextEditingController();

    await openIrsWebsite();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Aggiorna IRS"),
          content: SizedBox(
            width: 700,
            child: TextField(
              controller: controller,
              maxLines: 18,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    "Copia la tabella IRS dal sito e incollala qui.\n\nEsempio:\nIRS 20A 2,65% 21/06/2026",
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text;

                if (text.trim().isEmpty) return;

                await BrokerApi.updateManualIrs(text);

                if (!mounted) return;

                Navigator.pop(context);

                await loadDashboard();
              },
              child: const Text("Salva IRS"),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Widget summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 34),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  bool isImportantIrs(String descrizione) {
    return descrizione.contains("10A") ||
        descrizione.contains("15A") ||
        descrizione.contains("20A") ||
        descrizione.contains("25A") ||
        descrizione.contains("30A");
  }

  List<dynamic> euriborVisibili(List<dynamic> euribor) {
    return euribor.where((row) {
      final descrizione = "${row["descrizione"]}".toLowerCase();

      return descrizione.contains("1 settimana") ||
          descrizione.contains("1 mese") ||
          descrizione.contains("3 mesi") ||
          descrizione.contains("6 mesi");
    }).toList();
  }

  Widget ratesTable({
    required List<dynamic> rows,
    bool highlightIrs = false,
  }) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("Nessun dato disponibile"),
      );
    }

    final controller = ScrollController();

    return SizedBox(
      height: 190,
      child: Scrollbar(
        controller: controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: controller,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.4),
            },
            children: [
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      "Descrizione",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      "Fixing",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      "Data",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              for (final r in rows)
                TableRow(
                  decoration: highlightIrs && isImportantIrs("${r["descrizione"]}")
                      ? BoxDecoration(color: Colors.blue.shade50)
                      : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text("${r["descrizione"]}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text("${r["fixing"]}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text("${r["data_fixing"]}"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ratesBox({
    required String title,
    required List<dynamic> rows,
    String? lastUpdated,
    bool showUpdateButton = false,
    bool highlightIrs = false,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                if (showUpdateButton)
                  ElevatedButton(
                    onPressed: showIrsDialog,
                    child: Text(
                      lastUpdated == null ? "Aggiorna IRS" : "Aggiorna IRS\n$lastUpdated",
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ratesTable(rows: rows, highlightIrs: highlightIrs),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final euriborCompleto = rates?["euribor"] as List<dynamic>? ?? [];
    final euribor = euriborVisibili(euriborCompleto);

    final eurirs = rates?["eurirs"] as List<dynamic>? ?? [];
    final irsUpdated = rates?["eurirs_last_updated"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiron Broker Engine"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: summaryCard(
                  icon: Icons.account_balance,
                  title: "Banche importate",
                  value: banks.length.toString(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: summaryCard(
                  icon: Icons.show_chart,
                  title: "Euribor rilevati",
                  value: euribor.length.toString(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: summaryCard(
                  icon: Icons.trending_up,
                  title: "IRS rilevati",
                  value: eurirs.length.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (loadingRates)
            const Center(child: CircularProgressIndicator())
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ratesBox(
                    title: "EURIBOR",
                    rows: euribor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ratesBox(
                    title: "EURIRS",
                    rows: eurirs,
                    lastUpdated: irsUpdated,
                    showUpdateButton: true,
                    highlightIrs: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
          ],
          menuCard(
            icon: Icons.add_circle,
            title: "Nuova Pratica",
            subtitle: "Inserisci una nuova richiesta di mutuo",
            onTap: () {
              ref.read(practiceProvider.notifier).resetPractice();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientPage()),
              );
            },
          ),
          menuCard(
            icon: Icons.people,
            title: "Archivio Clienti",
            subtitle: "Clienti e ultimo preventivo salvato",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientsPage()),
              );
            },
          ),
          menuCard(
            icon: Icons.account_balance,
            title: "Gestione Banche",
            subtitle: "Importazione PDF e configurazione",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BanksPage()),
              ).then((_) => loadDashboard());
            },
          ),
          menuCard(
            icon: Icons.description,
            title: "Archivio Preventivi",
            subtitle: "Preventivi salvati",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuotesPage()),
              );
            },
          ),
          menuCard(
            icon: Icons.calculate,
            title: "Calcolatore Rata",
            subtitle: "Simula rata, interessi e costo totale",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoanCalculatorPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}