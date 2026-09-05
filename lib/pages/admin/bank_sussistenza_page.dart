import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../services/broker_api.dart';

class BankSussistenzaPage extends StatefulWidget {
  final String banca;
  final bool obbligatoria;

  const BankSussistenzaPage({
    super.key,
    required this.banca,
    this.obbligatoria = false,
  });

  @override
  State<BankSussistenzaPage> createState() => _BankSussistenzaPageState();
}

class _BankSussistenzaPageState extends State<BankSussistenzaPage> {
  bool loading = true;
  bool saving = false;
  bool uploading = false;

  String? stato;
  String? fileNome;

  final Map<String, Map<int, TextEditingController>> c = {
    for (final a in ['nord', 'centro', 'sud'])
      a: {
        for (var n = 1; n <= 5; n++) n: TextEditingController(),
      }
  };

  final Map<String, TextEditingController> inc = {
    for (final a in ['nord', 'centro', 'sud'])
      a: TextEditingController(text: '0'),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await BrokerApi.getBankSussistenza(widget.banca);
      final s = Map<String, dynamic>.from(r['sussistenza'] ?? {});
      stato = s['stato']?.toString();
      fileNome = s['file_nome']?.toString();

      final soglie = Map<String, dynamic>.from(s['soglie'] ?? {});
      final increments =
          Map<String, dynamic>.from(s['incremento_oltre_5'] ?? {});

      for (final a in c.keys) {
        final rows = Map<String, dynamic>.from(soglie[a] ?? {});
        for (var n = 1; n <= 5; n++) {
          if (rows['$n'] != null) {
            c[a]![n]!.text = rows['$n'].toString();
          }
        }
        if (increments[a] != null) {
          inc[a]!.text = increments[a].toString();
        }
      }
    } catch (_) {}

    if (mounted) setState(() => loading = false);
  }

  double? _num(String v) =>
      double.tryParse(v.trim().replaceAll(',', '.'));

  Future<void> _openUpload() async {
    final configured = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _SussistenzaUploadPage(
          banca: widget.banca,
          fileNomeIniziale: fileNome,
        ),
      ),
    );

    if (configured == true && mounted) {
      Navigator.pop(context, true);
      return;
    }
    await _load();
  }

  Future<void> _openManual() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _SussistenzaManualPage(
          banca: widget.banca,
          controllers: c,
          incrementi: inc,
          fileNome: fileNome,
        ),
      ),
    );

    if (saved == true && mounted) {
      Navigator.pop(context, true);
    } else {
      await _load();
    }
  }

  Future<void> _defer() async {
    setState(() => saving = true);

    try {
      await BrokerApi.deferBankSussistenza(widget.banca);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sussistenza da completare. La banca resta in configurazione incompleta.',
          ),
        ),
      );

      Navigator.pop(context, false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget _choice({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configured = stato == 'CONFIGURATA';

    return PopScope(
      canPop: !widget.obbligatoria,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sussistenza - ${widget.banca}'),
          automaticallyImplyLeading: !widget.obbligatoria,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    configured
                        ? 'Sussistenza configurata'
                        : 'Come vuoi configurare la sussistenza?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    configured
                        ? 'Puoi aggiornare i dati caricando un nuovo file o modificandoli manualmente.'
                        : 'Scegli una delle opzioni. La banca non sarà disponibile nella Verifica Pratica finché la sussistenza non sarà completata.',
                  ),
                  const SizedBox(height: 18),

                  if (fileNome != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.attach_file),
                        title: const Text('File associato'),
                        subtitle: Text(fileNome!),
                      ),
                    ),

                  _choice(
                    icon: Icons.upload_file,
                    title: 'Carica file Excel / PDF',
                    subtitle:
                        'Seleziona il file della banca e associalo alla sussistenza.',
                    onTap: uploading ? null : _openUpload,
                  ),

                  _choice(
                    icon: Icons.edit_note,
                    title: 'Inserimento manuale',
                    subtitle:
                        'Inserisci le soglie per Nord, Centro e Sud e salva.',
                    onTap: saving ? null : _openManual,
                  ),

                  _choice(
                    icon: Icons.schedule,
                    title: 'Carica più tardi',
                    subtitle:
                        'Ritorna a Gestione Banche lasciando la banca incompleta.',
                    onTap: saving ? null : _defer,
                  ),
                ],
              ),
      ),
    );
  }
}

class _SussistenzaUploadPage extends StatefulWidget {
  final String banca;
  final String? fileNomeIniziale;

  const _SussistenzaUploadPage({
    required this.banca,
    required this.fileNomeIniziale,
  });

  @override
  State<_SussistenzaUploadPage> createState() =>
      _SussistenzaUploadPageState();
}

class _SussistenzaUploadPageState extends State<_SussistenzaUploadPage> {
  bool uploading = false;
  bool analyzing = false;
  String? fileNome;

  @override
  void initState() {
    super.initState();
    fileNome = widget.fileNomeIniziale;
  }

  Future<void> _upload() async {
    const typeGroup = XTypeGroup(
      label: 'Sussistenza',
      extensions: ['xlsx', 'xls', 'csv', 'pdf'],
    );

    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    setState(() => uploading = true);

    try {
      final bytes = await file.readAsBytes();

      final result = await BrokerApi.uploadBankSussistenzaFile(
        banca: widget.banca,
        fileName: file.name,
        fileBytes: bytes,
      );

      if (!mounted) return;

      setState(() {
        fileNome = result['file_nome']?.toString() ?? file.name;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'File caricato. La banca resta incompleta finché i dati non vengono elaborati e confermati.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore caricamento file: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> _analyze() async {
    setState(() => analyzing = true);
    try {
      final result = await BrokerApi.analyzeBankSussistenza(widget.banca);
      if (!mounted) return;
      final interpretation = Map<String, dynamic>.from(result['interpretazione'] ?? {});
      if (result['success'] != true) {
        final warnings = (interpretation['warnings'] as List? ?? []).join('\n');
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Interpretazione non riuscita'),
            content: Text(warnings.isEmpty ? 'La struttura non è stata riconosciuta. Usa inserimento manuale.' : warnings),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        );
        return;
      }

      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => _SussistenzaInterpretationPage(
            banca: widget.banca,
            interpretation: interpretation,
          ),
        ),
      );
      if (confirmed == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore analisi: $e')));
      }
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carica file - ${widget.banca}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Carica file sussistenza',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Formati accettati: Excel (.xlsx/.xls), CSV o PDF.',
            ),
            const SizedBox(height: 20),
            if (fileNome != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(fileNome!),
                  subtitle: const Text('File associato alla banca'),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: uploading ? null : _upload,
              icon: const Icon(Icons.upload_file),
              label: Text(
                uploading ? 'CARICAMENTO...' : 'SELEZIONA E CARICA FILE',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: fileNome == null || analyzing ? null : _analyze,
                icon: const Icon(Icons.auto_awesome),
                label: Text(analyzing ? 'ANALISI...' : 'ANALIZZA TABELLA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SussistenzaManualPage extends StatefulWidget {
  final String banca;
  final Map<String, Map<int, TextEditingController>> controllers;
  final Map<String, TextEditingController> incrementi;
  final String? fileNome;

  const _SussistenzaManualPage({
    required this.banca,
    required this.controllers,
    required this.incrementi,
    required this.fileNome,
  });

  @override
  State<_SussistenzaManualPage> createState() =>
      _SussistenzaManualPageState();
}

class _SussistenzaManualPageState extends State<_SussistenzaManualPage> {
  bool saving = false;

  double? _num(String v) =>
      double.tryParse(v.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    final soglie = <String, dynamic>{};

    for (final a in widget.controllers.keys) {
      final rows = <String, dynamic>{};

      for (var n = 1; n <= 5; n++) {
        final v = _num(widget.controllers[a]![n]!.text);

        if (v == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Inserisci la soglia ${a.toUpperCase()} per $n componenti.',
              ),
            ),
          );
          return;
        }

        rows['$n'] = v;
      }

      soglie[a] = rows;
    }

    final increments = <String, dynamic>{};

    for (final a in widget.incrementi.keys) {
      final v = _num(widget.incrementi[a]!.text);

      if (v == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Incremento oltre 5 non valido: ${a.toUpperCase()}',
            ),
          ),
        );
        return;
      }

      increments[a] = v;
    }

    setState(() => saving = true);

    try {
      await BrokerApi.saveBankSussistenza(
        banca: widget.banca,
        soglie: soglie,
        incrementoOltre5: increments,
        fonte: widget.fileNome == null
            ? 'MANUALE'
            : 'FILE_CONFERMATO_MANUALMENTE',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sussistenza salvata.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget _field(String area, int n) => SizedBox(
        width: 150,
        child: TextField(
          controller: widget.controllers[area]![n],
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '$n component${n == 1 ? 'e' : 'i'}',
            border: const OutlineInputBorder(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inserimento manuale - ${widget.banca}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Soglie di sussistenza',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Formula: reddito totale - rate debiti - rata nuovo mutuo ≥ soglia di sussistenza.',
          ),
          const SizedBox(height: 20),

          for (final area in ['nord', 'centro', 'sud']) ...[
            Text(
              area.toUpperCase(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var n = 1; n <= 5; n)
                  _field(area, n),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: 260,
              child: TextField(
                controller: widget.incrementi[area],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Incremento per persona oltre 5',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 22),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(
                saving ? 'SALVATAGGIO...' : 'SALVA E CHIUDI',
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SussistenzaInterpretationPage extends StatefulWidget {
  final String banca;
  final Map<String, dynamic> interpretation;

  const _SussistenzaInterpretationPage({
    required this.banca,
    required this.interpretation,
  });

  @override
  State<_SussistenzaInterpretationPage> createState() => _SussistenzaInterpretationPageState();
}

class _SussistenzaInterpretationPageState extends State<_SussistenzaInterpretationPage> {
  bool saving = false;

  Future<void> _confirm() async {
    setState(() => saving = true);
    try {
      await BrokerApi.confirmBankSussistenzaInterpretation(
        banca: widget.banca,
        tipoGeografia: (widget.interpretation['tipo_geografia'] ?? 'AREA').toString(),
        soglie: Map<String, dynamic>.from(widget.interpretation['soglie'] ?? {}),
        incrementoOltre5: Map<String, dynamic>.from(widget.interpretation['incremento_oltre_5'] ?? {}),
        struttura: (widget.interpretation['struttura'] ?? 'SEMPLICE').toString(),
        matrice: Map<String, dynamic>.from(widget.interpretation['matrice'] ?? {}),
        dimensioni: Map<String, dynamic>.from(widget.interpretation['dimensioni'] ?? {}),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore salvataggio: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = (widget.interpretation['tipo_geografia'] ?? '').toString();
    final soglie = Map<String, dynamic>.from(widget.interpretation['soglie'] ?? {});
    final increments = Map<String, dynamic>.from(widget.interpretation['incremento_oltre_5'] ?? {});
    final struttura = (widget.interpretation['struttura'] ?? 'SEMPLICE').toString();
    final matrice = Map<String, dynamic>.from(widget.interpretation['matrice'] ?? {});
    final warnings = widget.interpretation['warnings'] as List? ?? const [];
    final confidence = widget.interpretation['confidence'];

    return Scaffold(
      appBar: AppBar(title: Text('Anteprima - ${widget.banca}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Interpretazione proposta', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Tipo geografia: $tipo   •   Affidabilità: ${confidence ?? '-'}   •   Metodo: ${widget.interpretation['metodo'] ?? 'PARSER'}'),
          const SizedBox(height: 16),
          if (struttura == 'CENTRO_CASA')
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Regione')),
                  DataColumn(label: Text('Centro')),
                  DataColumn(label: Text('Casa')),
                  DataColumn(label: Text('1')),
                  DataColumn(label: Text('2')),
                  DataColumn(label: Text('3')),
                  DataColumn(label: Text('4')),
                  DataColumn(label: Text('5')),
                  DataColumn(label: Text('6')),
                  DataColumn(label: Text('≥7')),
                ],
                rows: [
                  for (final regEntry in matrice.entries)
                    for (final centerEntry in Map<String, dynamic>.from(regEntry.value as Map).entries)
                      for (final houseEntry in Map<String, dynamic>.from(centerEntry.value as Map).entries)
                        DataRow(
                          cells: [
                            DataCell(Text(regEntry.key)),
                            DataCell(Text(centerEntry.key.replaceAll('_', ' '))),
                            DataCell(Text(houseEntry.key.replaceAll('_', ' '))),
                            for (final n in ['1','2','3','4','5','6','7+'])
                              DataCell(Text('${Map<String, dynamic>.from(houseEntry.value as Map)[n] ?? '-'}')),
                          ],
                        ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Geografia')),
                  DataColumn(label: Text('1')),
                  DataColumn(label: Text('2')),
                  DataColumn(label: Text('3')),
                  DataColumn(label: Text('4')),
                  DataColumn(label: Text('5')),
                  DataColumn(label: Text('Oltre 5')),
                ],
                rows: soglie.entries.map((entry) {
                  final rows = Map<String, dynamic>.from(entry.value as Map);
                  return DataRow(cells: [
                    DataCell(Text(entry.key)),
                    for (var i=1;i<=5;i++) DataCell(Text('${rows['$i'] ?? '-'}')),
                    DataCell(Text('${increments[entry.key] ?? '-'}')),
                  ]);
                }).toList(),
              ),
            ),
          if (warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Da verificare:\n${warnings.join('\n')}'),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: saving ? null : _confirm,
            icon: const Icon(Icons.check_circle),
            label: Text(saving ? 'SALVATAGGIO...' : 'CONFERMA E COMPLETA BANCA'),
          ),
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(context, false),
            child: const Text('NON CONFERMARE'),
          ),
        ],
      ),
    );
  }
}
