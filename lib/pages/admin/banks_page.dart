import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/broker_api.dart';
import 'bank_import_verification_page.dart';
import 'bank_memory_page.dart';
import 'bank_sussistenza_page.dart';

class BanksPage extends StatefulWidget {
  const BanksPage({super.key});

  @override
  State<BanksPage> createState() => _BanksPageState();
}

class _BanksPageState extends State<BanksPage> {
  bool loading = false;
  bool loadingBanks = true;
  List<dynamic> importedBanks = [];

  @override
  void initState() {
    super.initState();
    loadBanks();
  }

  Future<void> loadBanks() async {
    final result = await BrokerApi.getBanks();
    if (!mounted) return;
    setState(() {
      importedBanks = result["banks"] ?? [];
      loadingBanks = false;
    });
  }

  Future<void> apriPdf(String pdfName) async {
    await launchUrl(
      Uri.parse(BrokerApi.pdfUrl(pdfName)),
      mode: LaunchMode.externalApplication,
    );
  }

  void apriVerificaImportazione({
    required String banca,
    required String pdfName,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BankImportVerificationPage(
          banca: banca,
          pdfPath: "input/$pdfName",
        ),
      ),
    );
  }

  void apriMemoriaBanca(String banca) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BankMemoryPage(banca: banca),
      ),
    );
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim().replaceAll(",", "."));
  }

  Future<void> importPdf({String? bancaPrecompilata}) async {
    final bancaController = TextEditingController(text: bancaPrecompilata ?? "");
    final periziaController = TextEditingController(text: "0");
    final impostaSostitutivaController = TextEditingController(text: "0.25");
    final istruttoriaPercentualeController = TextEditingController(text: "0");
    final istruttoriaMinimoController = TextEditingController(text: "0");
    final istruttoriaMassimoController = TextEditingController(text: "0");
    final istruttoriaFissaController = TextEditingController(text: "0");
    final rapportoRataRedditoController = TextEditingController(text: "35");
    final etaMassimaController = TextEditingController(text: "80");
    final anniItaliaController = TextEditingController(text: "2");

    bool tassoEsplicito = false;
    String? calcoloDebito;
    String istruttoriaTipo = "PERCENTUALE";

    if (bancaPrecompilata != null && bancaPrecompilata.trim().isNotEmpty) {
      try {
        final memory = await BrokerApi.getBankMemory(bancaPrecompilata.trim());
        final bankMemory = Map<String, dynamic>.from(memory["memory"] ?? {});

        final perizia = bankMemory["perizia_euro"];
        if (perizia is num) periziaController.text = perizia.toStringAsFixed(2);

        final imposta = bankMemory["imposta_sostitutiva_percentuale"] ??
            bankMemory["costi_avviamento_percentuale"];
        if (imposta is num) {
          impostaSostitutivaController.text = imposta.toStringAsFixed(2);
        }

        final istrPct = bankMemory["istruttoria_percentuale"];
        final istrMin = bankMemory["istruttoria_minimo"];
        final istrMax = bankMemory["istruttoria_massimo"];
        final istrFissa = bankMemory["istruttoria_fissa_euro"];

        if (istrPct is num) {
          istruttoriaPercentualeController.text = istrPct.toStringAsFixed(2);
        }
        if (istrMin is num) {
          istruttoriaMinimoController.text = istrMin.toStringAsFixed(2);
        }
        if (istrMax is num) {
          istruttoriaMassimoController.text = istrMax.toStringAsFixed(2);
        }
        if (istrFissa is num) {
          istruttoriaFissaController.text = istrFissa.toStringAsFixed(2);
        }

        final tipoSalvato = (bankMemory["istruttoria_tipo"] ?? "")
            .toString()
            .trim()
            .toUpperCase();
        if (tipoSalvato == "FISSA" || tipoSalvato == "PERCENTUALE") {
          istruttoriaTipo = tipoSalvato;
        } else if (istrPct is num &&
            istrPct.toDouble() == 0 &&
            istrMin is num &&
            istrMax is num &&
            istrMin.toDouble() > 0 &&
            istrMin.toDouble() == istrMax.toDouble()) {
          // Compatibilità con il workaround precedente: 0% + min=max.
          istruttoriaTipo = "FISSA";
          istruttoriaFissaController.text = istrMin.toStringAsFixed(2);
        }

        final rapporto = bankMemory["rapporto_rata_reddito_percentuale"];
        if (rapporto is num) {
          rapportoRataRedditoController.text = rapporto.toStringAsFixed(2);
        }

        final etaMassima = bankMemory["eta_massima_finanziabile"];
        if (etaMassima is num) {
          etaMassimaController.text = etaMassima.toInt().toString();
        }

        final anniItalia = bankMemory["anni_residenza_italia_straniero"];
        if (anniItalia is num) {
          anniItaliaController.text = anniItalia.toInt().toString();
        }

        final metodo = (bankMemory["calcolo_debito"] ?? "")
            .toString()
            .toUpperCase();
        if (metodo == "RATA" || metodo == "REDDITO") calcoloDebito = metodo;
        tassoEsplicito = bankMemory["tasso_esplicito"] == true;
      } catch (_) {
        // Memoria non disponibile: usa i valori iniziali.
      }
    }

    const typeGroup = XTypeGroup(
      label: "PDF",
      extensions: ["pdf"],
      mimeTypes: ["application/pdf"],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    final fileBytes = await file.readAsBytes();
    final fileName = file.name;
    if (!mounted) return;

    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final istruttoriaFissa = istruttoriaTipo == "FISSA";
            return AlertDialog(
              title: Text(
                bancaPrecompilata == null
                    ? "Importa PDF banca"
                    : "Sostituisci PDF banca",
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "File selezionato:\n$fileName",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bancaPrecompilata == null
                            ? "Inserisci i parametri manuali specifici di questa banca."
                            : "Sono proposti gli ultimi parametri manuali salvati per questa banca. Puoi confermarli o modificarli.",
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: bancaController,
                        enabled: bancaPrecompilata == null,
                        decoration: const InputDecoration(
                          labelText: "Nome banca",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: periziaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Costo perizia banca (€)",
                          helperText: "Parametro distinto dall'istruttoria. Inserisci 0 se non prevista.",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: impostaSostitutivaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Imposta sostitutiva (%)",
                          helperText: "Valore specifico della banca, es. 0,25%.",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Tipo istruttoria",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      RadioListTile<String>(
                        value: "PERCENTUALE",
                        groupValue: istruttoriaTipo,
                        title: const Text("Percentuale"),
                        subtitle: const Text("Percentuale sull'importo con eventuale minimo e massimo."),
                        onChanged: (value) {
                          setDialogState(() => istruttoriaTipo = value!);
                        },
                      ),
                      RadioListTile<String>(
                        value: "FISSA",
                        groupValue: istruttoriaTipo,
                        title: const Text("Importo fisso"),
                        subtitle: const Text("Importo in euro indipendente dall'importo del mutuo."),
                        onChanged: (value) {
                          setDialogState(() => istruttoriaTipo = value!);
                        },
                      ),
                      if (!istruttoriaFissa) ...[
                        TextField(
                          controller: istruttoriaPercentualeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Istruttoria banca (%)",
                            helperText: "Inserisci 0 se non prevista.",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: istruttoriaMinimoController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Istruttoria minimo (€)",
                                  helperText: "0 se non previsto.",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: istruttoriaMassimoController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Istruttoria massimo (€)",
                                  helperText: "0 se non previsto.",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        TextField(
                          controller: istruttoriaFissaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Istruttoria fissa (€)",
                            helperText: "Esempio: 1500. Non viene conteggiata come perizia.",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Regole di verifica pratica della banca",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Metodo di calcolo dei debiti",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      RadioListTile<String>(
                        value: "RATA",
                        groupValue: calcoloDebito,
                        title: const Text("Strada 1 - debiti dalla rata"),
                        subtitle: const Text(
                          "Calcola la rata massima dal reddito e sottrae la somma delle rate dei debiti.",
                        ),
                        onChanged: (value) {
                          setDialogState(() => calcoloDebito = value);
                        },
                      ),
                      RadioListTile<String>(
                        value: "REDDITO",
                        groupValue: calcoloDebito,
                        title: const Text("Strada 2 - debiti dal reddito"),
                        subtitle: const Text(
                          "Sottrae la somma delle rate dei debiti dal reddito e poi applica il rapporto rata/reddito.",
                        ),
                        onChanged: (value) {
                          setDialogState(() => calcoloDebito = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: rapportoRataRedditoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Rapporto rata/reddito banca (%)",
                          helperText: "Valore specifico della banca, es. 35.",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: etaMassimaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Età massima a fine mutuo",
                          helperText: "Viene confrontata con data di nascita + durata del mutuo.",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: anniItaliaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Anni residenza in Italia per straniero",
                          helperText: "Minimo richiesto dalla banca. Per cittadino italiano il controllo è automaticamente superato.",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Il PDF contiene un tasso finito esplicito?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      RadioListTile<bool>(
                        value: true,
                        groupValue: tassoEsplicito,
                        title: const Text("Sì, il tasso è già finito nel PDF"),
                        onChanged: (value) {
                          setDialogState(() => tassoEsplicito = value!);
                        },
                      ),
                      RadioListTile<bool>(
                        value: false,
                        groupValue: tassoEsplicito,
                        title: const Text("No, contiene spread da sommare a IRS/Euribor"),
                        onChanged: (value) {
                          setDialogState(() => tassoEsplicito = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Annulla"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final istruttoriaValida = istruttoriaFissa
                        ? _parseDouble(istruttoriaFissaController.text) != null
                        : _parseDouble(istruttoriaPercentualeController.text) != null &&
                            _parseDouble(istruttoriaMinimoController.text) != null &&
                            _parseDouble(istruttoriaMassimoController.text) != null;

                    if (bancaController.text.trim().isEmpty ||
                        calcoloDebito == null ||
                        _parseDouble(rapportoRataRedditoController.text) == null ||
                        _parseDouble(impostaSostitutivaController.text) == null ||
                        !istruttoriaValida ||
                        int.tryParse(etaMassimaController.text.trim()) == null ||
                        int.tryParse(anniItaliaController.text.trim()) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Compila nome banca, imposta sostitutiva, istruttoria, metodo debiti, rapporto rata/reddito, età massima e anni minimi di residenza in Italia.",
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text("Importa"),
                ),
              ],
            );
          },
        );
      },
    );

    if (conferma != true) {
      bancaController.dispose();
      periziaController.dispose();
      impostaSostitutivaController.dispose();
      istruttoriaPercentualeController.dispose();
      istruttoriaMinimoController.dispose();
      istruttoriaMassimoController.dispose();
      istruttoriaFissaController.dispose();
      rapportoRataRedditoController.dispose();
      etaMassimaController.dispose();
      anniItaliaController.dispose();
      return;
    }

    final banca = bancaController.text.trim();
    final isFissa = istruttoriaTipo == "FISSA";
    final istruttoriaFissa = _parseDouble(istruttoriaFissaController.text) ?? 0;
    final istruttoriaPercentuale = isFissa
        ? 0.0
        : (_parseDouble(istruttoriaPercentualeController.text) ?? 0);
    final istruttoriaMinimo = isFissa
        ? istruttoriaFissa
        : (_parseDouble(istruttoriaMinimoController.text) ?? 0);
    final istruttoriaMassimo = isFissa
        ? istruttoriaFissa
        : (_parseDouble(istruttoriaMassimoController.text) ?? 0);

    setState(() => loading = true);

    try {
      final result = await BrokerApi.importBankPdf(
        banca: banca,
        tassoEsplicito: tassoEsplicito,
        periziaEuro: _parseDouble(periziaController.text) ?? 0,
        impostaSostitutivaPercentuale:
            _parseDouble(impostaSostitutivaController.text) ?? 0.25,
        istruttoriaPercentuale: istruttoriaPercentuale,
        istruttoriaMinimo: istruttoriaMinimo,
        istruttoriaMassimo: istruttoriaMassimo,
        calcoloDebito: calcoloDebito!,
        rapportoRataRedditoPercentuale:
            _parseDouble(rapportoRataRedditoController.text)!,
        etaMassimaFinanziabile: int.parse(etaMassimaController.text.trim()),
        anniResidenzaItaliaStraniero: int.parse(anniItaliaController.text.trim()),
        fileName: fileName,
        fileBytes: fileBytes,
      );

      // Il backend attuale continua a ricevere min=max per la modalità fissa,
      // così il calcolo è corretto anche nelle versioni precedenti. In memoria
      // salviamo però il modello esplicito, senza confonderlo con la perizia.
      await BrokerApi.confirmMemoryFields(
        banca: banca,
        fields: {
          "istruttoria_tipo": istruttoriaTipo,
          "istruttoria_fissa_euro": isFissa ? istruttoriaFissa : 0.0,
          "istruttoria_percentuale": istruttoriaPercentuale,
          "istruttoria_minimo": istruttoriaMinimo,
          "istruttoria_massimo": istruttoriaMassimo,
        },
      );

      await loadBanks();
      if (!mounted) return;
      setState(() => loading = false);

      await showDialog(
        context: context,
        builder: (context) {
          final istruttoriaLabel = isFissa
              ? "Istruttoria: € ${istruttoriaFissa.toStringAsFixed(2)} (fissa)"
              : "Istruttoria: ${istruttoriaPercentuale.toStringAsFixed(2)}% (min € ${istruttoriaMinimo.toStringAsFixed(2)}, max € ${istruttoriaMassimo.toStringAsFixed(2)})";
          return AlertDialog(
            title: const Text("Operazione completata"),
            content: Text(
              "Banca: ${result["banca"]}\n"
              "PDF: ${result["pdf"]}\n"
              "Tasso esplicito: ${result["tasso_esplicito"]}\n"
              "Perizia banca: € ${result["perizia_euro"]}\n"
              "Imposta sostitutiva: ${result["imposta_sostitutiva_percentuale"]}%\n"
              "$istruttoriaLabel\n"
              "Metodo debiti: ${result["calcolo_debito"]}\n"
              "Rapporto rata/reddito: ${result["rapporto_rata_reddito_percentuale"]}%\n"
              "Età massima a fine mutuo: ${result["eta_massima_finanziabile"]} anni\n"
              "Residenza minima in Italia (stranieri): ${result["anni_residenza_italia_straniero"]} anni\n\n"
              "Regole valide: ${result["regole_valide"]}\n"
              "Regole con errori: ${result["regole_errori"]}\n"
              "Regole commerciali: ${result["regole_commerciali"] ?? 0}"
              " (AI: ${result["regole_commerciali_ai"] ?? 0})\n"
              "Warning commerciali: ${result["warning_commerciali"] ?? 0}\n\n"
              "Ultimo aggiornamento: ${result["last_updated"]}\n"
              "Database: ${result["database"]}\n\n"
              "Ora puoi verificare la copertura e le differenze dell'importazione.",
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Continua: sussistenza"),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BankSussistenzaPage(
            banca: banca,
            obbligatoria: true,
          ),
        ),
      );
      await loadBanks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore importazione PDF: $e")),
      );
    } finally {
      bancaController.dispose();
      periziaController.dispose();
      impostaSostitutivaController.dispose();
      istruttoriaPercentualeController.dispose();
      istruttoriaMinimoController.dispose();
      istruttoriaMassimoController.dispose();
      istruttoriaFissaController.dispose();
      rapportoRataRedditoController.dispose();
      etaMassimaController.dispose();
      anniItaliaController.dispose();
      if (mounted) setState(() => loading = false);
    }
  }

  Widget bankCard(Map<String, dynamic> bank) {
    final banca = bank["banca"] ?? "";
    final pdf = bank["pdf"] ?? "";
    final commerciali = bank["regole_commerciali"] ?? 0;
    final commercialiAi = bank["regole_commerciali_ai"] ?? 0;
    final warningCommerciali = bank["warning_commerciali"] ?? 0;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance),
        title: Text(
          banca,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "PDF: $pdf\n"
          "Ultimo aggiornamento: ${bank["last_updated"]}\n"
          "Regole valide: ${bank["regole_valide"]} | Errori: ${bank["regole_errori"]}\n"
          "Regole commerciali: $commerciali | AI: $commercialiAi | Warning: $warningCommerciali\n"
          "Tasso esplicito: ${bank["tasso_esplicito"] == true ? "Sì" : "No"}\n"
          "${bank["sussistenza_configurata"] == true ? "✅ Configurata" : "⚠️ Configurazione incompleta"}"
          "${bank["sussistenza_configurata"] == true ? "" : " - ${bank["sussistenza_stato"] == "FILE_CARICATO_DA_ELABORARE" ? "Sussistenza: file caricato da elaborare" : "Sussistenza mancante"}"}",
        ),
        isThreeLine: false,
        trailing: Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: pdf.toString().isEmpty
                  ? null
                  : () => apriPdf(pdf.toString()),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Apri PDF"),
            ),
            ElevatedButton.icon(
              onPressed: pdf.toString().isEmpty
                  ? null
                  : () => apriVerificaImportazione(
                        banca: banca.toString(),
                        pdfName: pdf.toString(),
                      ),
              icon: const Icon(Icons.fact_check),
              label: const Text("Verifica importazione"),
            ),
            ElevatedButton.icon(
              onPressed: banca.toString().isEmpty
                  ? null
                  : () => apriMemoriaBanca(banca.toString()),
              icon: const Icon(Icons.memory),
              label: const Text("Memoria banca"),
            ),
            ElevatedButton.icon(
              onPressed: banca.toString().isEmpty
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BankSussistenzaPage(
                            banca: banca.toString(),
                          ),
                        ),
                      );
                      await loadBanks();
                    },
              icon: const Icon(Icons.table_chart),
              label: const Text("Sussistenza"),
            ),
            ElevatedButton.icon(
              onPressed: loading
                  ? null
                  : () => importPdf(bancaPrecompilata: banca.toString()),
              icon: const Icon(Icons.sync),
              label: const Text("Sostituisci PDF"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestione Banche"),
        actions: [
          IconButton(onPressed: loadBanks, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          if (loadingBanks)
            const Center(child: CircularProgressIndicator())
          else if (importedBanks.isEmpty)
            const Center(
              child: Text(
                "Nessuna banca importata.\nPremi Carica PDF per iniziare.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: importedBanks.length,
              itemBuilder: (context, index) {
                return bankCard(
                  Map<String, dynamic>.from(importedBanks[index]),
                );
              },
            ),
          if (loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : () => importPdf(),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("Carica PDF"),
      ),
    );
  }
}
