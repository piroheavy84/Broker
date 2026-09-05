import 'package:flutter/material.dart';

import '../../services/broker_api.dart';

class BankImportVerificationPage extends StatefulWidget {
  final String banca;
  final String pdfPath;

  const BankImportVerificationPage({
    super.key,
    required this.banca,
    required this.pdfPath,
  });

  @override
  State<BankImportVerificationPage> createState() =>
      _BankImportVerificationPageState();
}

class _BankImportVerificationPageState
    extends State<BankImportVerificationPage> {
  bool loading = true;
  Map<String, dynamic>? audit;

  @override
  void initState() {
    super.initState();
    loadAudit();
  }

  Future<void> loadAudit() async {
    setState(() => loading = true);
    try {
      final result = await BrokerApi.verifyBankImport(
        banca: widget.banca,
        pdfPath: widget.pdfPath,
      );
      if (!mounted) return;
      setState(() {
        audit = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore verifica importazione: $e')),
      );
    }
  }

  Color statusColor(String value) {
    switch (value) {
      case 'ERRORE':
        return Colors.red;
      case 'ATTENZIONE':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget summaryCard(String label, dynamic value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = audit ?? {};
    final summary = Map<String, dynamic>.from(data['summary'] ?? {});
    final changes = List<dynamic>.from(data['changes'] ?? []);
    final unresolved = List<dynamic>.from(data['unresolved'] ?? []);
    final pageAudit = List<dynamic>.from(data['page_audit'] ?? []);
    final technicalPages = List<dynamic>.from(data['technical_pages'] ?? []);
    final status = (data['status'] ?? 'ATTENZIONE').toString();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verifica importazione ${widget.banca}'),
          actions: [
            IconButton(onPressed: loadAudit, icon: const Icon(Icons.refresh)),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Riepilogo'),
              Tab(text: 'Modifiche'),
              Tab(text: 'Problemi aperti'),
              Tab(text: 'Dettagli tecnici'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: statusColor(status).withOpacity(0.10),
                  child: ListTile(
                    leading: Icon(Icons.fact_check, color: statusColor(status)),
                    title: Text(
                      'Esito: $status',
                      style: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(widget.pdfPath),
                  ),
                ),
                summaryCard('Pagine PDF', summary['numero_pagine'] ?? 0,
                    Icons.picture_as_pdf),
                summaryCard('Pagine coperte', summary['pagine_coperte'] ?? 0,
                    Icons.check_circle),
                summaryCard(
                    'Copertura',
                    '${summary['copertura_percentuale'] ?? 0}%',
                    Icons.analytics),
                summaryCard('Pagine sospette', summary['pagine_sospette'] ?? 0,
                    Icons.warning),
                summaryCard('Modifiche rispetto alla memoria',
                    summary['modifiche_rilevate'] ?? 0, Icons.compare_arrows),
                summaryCard('Frasi non risolte',
                    summary['frasi_non_risolte'] ?? 0, Icons.rule),
                const SizedBox(height: 12),
                const Text(
                  'Copertura pagina per pagina',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                for (final raw in pageAudit)
                  Builder(builder: (_) {
                    final row = Map<String, dynamic>.from(raw as Map);
                    final suspicious = row['suspicious'] == true;
                    return Card(
                      color: suspicious ? Colors.orange.shade50 : null,
                      child: ListTile(
                        leading: Icon(
                          suspicious ? Icons.warning : Icons.check_circle,
                          color: suspicious ? Colors.orange : Colors.green,
                        ),
                        title: Text('Pagina ${row['pagina']}'),
                        subtitle: Text(
                          'Prodotti: ${row['products_count']} · Info: ${row['info_count']} · '
                          'Header: ${row['header_count']} · Sconosciuti: ${row['unknown_count']}',
                        ),
                      ),
                    );
                  }),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (changes.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Nessuna modifica rilevata rispetto alla memoria banca.'),
                    ),
                  ),
                for (final raw in changes)
                  Builder(builder: (_) {
                    final row = Map<String, dynamic>.from(raw as Map);
                    return Card(
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.compare_arrows),
                        title: Text(row['field'].toString()),
                        subtitle: Text('${row['old']} → ${row['new']}'),
                      ),
                    );
                  }),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (unresolved.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Nessuna frase nuova o non confermata.'),
                    ),
                  ),
                for (final raw in unresolved.take(300))
                  Builder(builder: (_) {
                    final row = Map<String, dynamic>.from(raw as Map);
                    final categories = List<dynamic>.from(row['categories'] ?? []);
                    return Card(
                      child: ListTile(
                        title: Text(row['sentence'].toString()),
                        subtitle: Text(
                          'Pagina ${row['pagina']} · '
                          '${categories.isEmpty ? 'Nessuna categoria' : categories.join(', ')}',
                        ),
                      ),
                    );
                  }),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final raw in technicalPages)
                  Builder(builder: (_) {
                    final row = Map<String, dynamic>.from(raw as Map);
                    return ExpansionTile(
                      title: Text('Pagina ${row['pagina']}'),
                      subtitle: Text(
                        'Blocchi ${row['numero_blocchi']} · testo ${row['raw_text_length']} caratteri',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(row['raw_text'].toString()),
                        ),
                      ],
                    );
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
