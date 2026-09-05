import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/practice.dart';
import '../../models/mortgage.dart';
import '../../services/broker_api.dart';

class ResultsPage extends StatefulWidget {
  final Map<String, dynamic> response;
  final Practice pratica;

  const ResultsPage({
    super.key,
    required this.response,
    required this.pratica,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final Set<int> selected = {};

  final Map<int, TextEditingController> istruttoriaControllers = {};
  final Map<int, TextEditingController> periziaControllers = {};
  final Map<int, TextEditingController> retrocessioneControllers = {};
  final Map<int, TextEditingController> provvigioneControllers = {};

  final Map<int, TextEditingController> polizzaVitaControllers = {};
  final Map<int, TextEditingController> polizzaLavoroControllers = {};
  final Map<int, TextEditingController> polizzaVitaLavoroControllers = {};
  final Map<int, TextEditingController> polizzaScoppioIncendioControllers = {};
  final Map<int, TextEditingController> polizzaScoppioIncendioCompensoControllers = {};

  final Map<int, bool> polizzaVitaRateizzata = {};
  final Map<int, bool> polizzaLavoroRateizzata = {};
  final Map<int, bool> polizzaVitaLavoroRateizzata = {};

  bool generatingPdf = false;
  bool generatingTechnicalReport = false;

  @override
  void dispose() {
    for (final c in istruttoriaControllers.values) {
      c.dispose();
    }
    for (final c in periziaControllers.values) {
      c.dispose();
    }
    for (final c in retrocessioneControllers.values) {
      c.dispose();
    }
    for (final c in provvigioneControllers.values) {
      c.dispose();
    }
    for (final c in polizzaVitaControllers.values) {
      c.dispose();
    }
    for (final c in polizzaLavoroControllers.values) {
      c.dispose();
    }
    for (final c in polizzaVitaLavoroControllers.values) {
      c.dispose();
    }
    for (final c in polizzaScoppioIncendioControllers.values) {
      c.dispose();
    }
    for (final c in polizzaScoppioIncendioCompensoControllers.values) {
      c.dispose();
    }

    super.dispose();
  }

  TextEditingController controllerFor(
    Map<int, TextEditingController> map,
    int index,
  ) {
    if (!map.containsKey(index)) {
      map[index] = TextEditingController();
    }

    return map[index]!;
  }


  void setDefaultPercentIfEmpty(
    TextEditingController controller,
    dynamic value,
  ) {
    if (controller.text.trim().isNotEmpty) {
      return;
    }

    if (value is num && value > 0) {
      controller.text = value.toStringAsFixed(2);
    }
  }

  double parsePercent(String value) {
    return double.tryParse(value.replaceAll(",", ".")) ?? 0;
  }

  double parseEuro(String value) {
    return double.tryParse(
          value.replaceAll(".", "").replaceAll(",", "."),
        ) ??
        0;
  }

  double calcolaPercentuale(
    double importo,
    String percentuale,
  ) {
    return importo * parsePercent(percentuale) / 100;
  }

  String euro(double value) {
    return "€ ${value.toStringAsFixed(2)}";
  }

  double polizzaImporto(
    Map<String, dynamic> r,
    int index,
    String backendKey,
    Map<int, TextEditingController> controllers,
  ) {
    final controller = controllerFor(controllers, index);

    if (controller.text.trim().isNotEmpty) {
      return parseEuro(controller.text);
    }

    final value = r[backendKey];
    if (value is num && value > 0) {
      controller.text = value.toStringAsFixed(2);
      return value.toDouble();
    }

    return 0;
  }

  bool polizzaRate(
    Map<String, dynamic> r,
    int index,
    String backendKey,
    Map<int, bool> values,
  ) {
    if (values.containsKey(index)) {
      return values[index]!;
    }

    final value = r[backendKey] == true;
    values[index] = value;
    return value;
  }

  double compensoPolizza({
    required double importoMutuo,
    required double premioCliente,
    required bool rateizzata,
    required double percentualeRateizzata,
  }) {
    if (rateizzata) {
      return importoMutuo * percentualeRateizzata / 100;
    }

    return premioCliente * 10 / 100;
  }

  double percentualeCompensoPolizza({
    required bool rateizzata,
    required double percentualeRateizzata,
  }) {
    return rateizzata ? percentualeRateizzata : 10;
  }

  Widget polizzaInput({
    required String title,
    required TextEditingController controller,
    required bool rateizzata,
    required ValueChanged<bool> onRateizzataChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Premio / costo cliente (€)",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Premio rateizzato"),
              subtitle: Text(
                rateizzata
                    ? "Compenso calcolato sull'importo mutuo"
                    : "Compenso calcolato sul premio inserito",
              ),
              value: rateizzata,
              onChanged: onRateizzataChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget polizzeClienteBox(
    Map<String, dynamic> r,
    int index,
  ) {
    final banca = (r["banca"] ?? "").toString().toLowerCase();
    final pdf = (r["pdf"] ?? "").toString().toLowerCase();
    final hasPolizze = ((r["polizze_rule_page"] ?? 0) as num?) != 0 ||
        banca.contains("che") ||
        pdf.contains("chebanca");

    if (!hasPolizze) {
      return const SizedBox.shrink();
    }

    final vitaController = controllerFor(polizzaVitaControllers, index);
    final lavoroController = controllerFor(polizzaLavoroControllers, index);
    final vitaLavoroController = controllerFor(polizzaVitaLavoroControllers, index);
    final scoppioController = controllerFor(polizzaScoppioIncendioControllers, index);
    final scoppioCompensoController = controllerFor(polizzaScoppioIncendioCompensoControllers, index);

    final vitaRate = polizzaRate(r, index, "polizza_vita_rateizzata", polizzaVitaRateizzata);
    final lavoroRate = polizzaRate(r, index, "polizza_lavoro_rateizzata", polizzaLavoroRateizzata);
    final vitaLavoroRate = polizzaRate(r, index, "polizza_vita_lavoro_rateizzata", polizzaVitaLavoroRateizzata);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text(
        "POLIZZE CLIENTE",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        ((r["polizze_rule_page"] ?? 0) as num).toInt() > 0
            ? "Regole polizze banca: pag. ${r["polizze_rule_page"]}"
            : "Inserimento manuale legato alle regole banca",
      ),
      children: [
        polizzaInput(
          title: "Polizza Vita",
          controller: vitaController,
          rateizzata: vitaRate,
          onRateizzataChanged: (value) {
            setState(() {
              polizzaVitaRateizzata[index] = value;
            });
          },
        ),
        polizzaInput(
          title: "Polizza Lavoro",
          controller: lavoroController,
          rateizzata: lavoroRate,
          onRateizzataChanged: (value) {
            setState(() {
              polizzaLavoroRateizzata[index] = value;
            });
          },
        ),
        polizzaInput(
          title: "Polizza Vita + Lavoro",
          controller: vitaLavoroController,
          rateizzata: vitaLavoroRate,
          onRateizzataChanged: (value) {
            setState(() {
              polizzaVitaLavoroRateizzata[index] = value;
            });
          },
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Polizza Scoppio e Incendio",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: scoppioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Costo cliente (€)",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: scoppioCompensoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Compenso broker manuale (€)",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int scoreValue(Map<String, dynamic> r) {
    final raw = r["score"];

    if (raw is num) {
      return raw.round();
    }

    return int.tryParse(raw?.toString() ?? "") ?? 0;
  }

  Color semaforoColor(String semaforo) {
    switch (semaforo) {
      case "ROSSO":
        return Colors.red;
      case "GIALLO":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData semaforoIcon(String semaforo) {
    switch (semaforo) {
      case "ROSSO":
        return Icons.cancel;
      case "GIALLO":
        return Icons.warning;
      default:
        return Icons.check_circle;
    }
  }

  String semaforoLabel(String semaforo) {
    switch (semaforo) {
      case "ROSSO":
        return "Semaforo Rosso";
      case "GIALLO":
        return "Semaforo Giallo";
      default:
        return "Semaforo Verde";
    }
  }

  Future<void> apriPdf(
    String pdfName,
    int pagina,
  ) async {
    final url = "${BrokerApi.pdfUrl(pdfName)}#page=$pagina";
    final uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> apriPreventivo(
    String fileName,
  ) async {
    final uri = Uri.parse(
      BrokerApi.quoteUrl(fileName),
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Map<String, dynamic> clienteJson() {
    if (widget.pratica.richiedenti.isEmpty) {
      return {
        "nome": "",
        "cognome": "",
        "reddito": 0,
      };
    }

    final r = widget.pratica.richiedenti.first;

    return {
      "nome": r.nome,
      "cognome": r.cognome,
      "reddito": r.reddito,
    };
  }

  Map<String, dynamic> praticaJson() {
    final mortgage = widget.pratica.mortgage!;

    return {
      "finalita": mortgage.finalita.normalizedCode,
      "finalita_label": mortgage.finalita.displayLabel,
      "tipologia_immobile": mortgage.tipologia.normalizedCode,
      "classe_energetica": mortgage.classeEnergetica,
      "valore_perizia": mortgage.valorePerizia,
      "importo": mortgage.importoRichiesto,
      "valore_immobile": mortgage.valoreImmobile,
      "durata": mortgage.durata,
      "ltv": widget.response["ltv"] ?? 0,
      "valore_perizia": mortgage.valorePerizia,
      "classe_energetica": mortgage.classeEnergetica.toString(),
      "tipo_tasso": mortgage.tipoTasso.toString(),
      "data_rogito": mortgage.dataRogito?.toIso8601String() ?? "",
    };
  }

  Map<String, dynamic> prodottoConCosti(
    Map<String, dynamic> prodotto,
    int index,
  ) {
    final importo = (prodotto["importo_finanziato"] as num).toDouble();

    final retrocessioneController = controllerFor(
      retrocessioneControllers,
      index,
    );
    final provvigioneController = controllerFor(
      provvigioneControllers,
      index,
    );

    setDefaultPercentIfEmpty(
      retrocessioneController,
      prodotto["retrocessione_percentuale"],
    );
    setDefaultPercentIfEmpty(
      provvigioneController,
      prodotto["provvigione_percentuale"],
    );

    final istruttoriaEuro =
        ((prodotto["istruttoria_euro"] ?? 0) as num).toDouble();
    final istruttoriaPercentuale =
        ((prodotto["istruttoria_percentuale"] ?? 0) as num).toDouble();
    final periziaEuro =
        ((prodotto["perizia_euro"] ?? 0) as num).toDouble();

    final impostaSostitutivaPercentuale =
        ((prodotto["imposta_sostitutiva_percentuale"] ??
                    prodotto["costi_avviamento_percentuale"] ??
                    0.25)
                as num)
            .toDouble();

    final impostaSostitutivaEuro =
        ((prodotto["imposta_sostitutiva_euro"] ??
                    prodotto["costi_avviamento_euro"] ??
                    (importo * impostaSostitutivaPercentuale / 100))
                as num)
            .toDouble();

    // IMPORTANTISSIMO:
    // usiamo gli stessi controller della schermata risultati, quindi il PDF
    // riceve esattamente gli importi inseriti/modificati manualmente.
    final polizzaVitaEuro = polizzaImporto(
      prodotto,
      index,
      "polizza_vita_euro",
      polizzaVitaControllers,
    );
    final polizzaLavoroEuro = polizzaImporto(
      prodotto,
      index,
      "polizza_lavoro_euro",
      polizzaLavoroControllers,
    );
    final polizzaVitaLavoroEuro = polizzaImporto(
      prodotto,
      index,
      "polizza_vita_lavoro_euro",
      polizzaVitaLavoroControllers,
    );
    final polizzaScoppioIncendioEuro = polizzaImporto(
      prodotto,
      index,
      "polizza_scoppio_incendio_euro",
      polizzaScoppioIncendioControllers,
    );

    final vitaRate = polizzaRate(
      prodotto,
      index,
      "polizza_vita_rateizzata",
      polizzaVitaRateizzata,
    );
    final lavoroRate = polizzaRate(
      prodotto,
      index,
      "polizza_lavoro_rateizzata",
      polizzaLavoroRateizzata,
    );
    final vitaLavoroRate = polizzaRate(
      prodotto,
      index,
      "polizza_vita_lavoro_rateizzata",
      polizzaVitaLavoroRateizzata,
    );

    final totalePolizzeCliente = polizzaVitaEuro +
        polizzaLavoroEuro +
        polizzaVitaLavoroEuro +
        polizzaScoppioIncendioEuro;

    final retrocessionePercentuale = parsePercent(
      retrocessioneController.text,
    );
    final provvigionePercentuale = parsePercent(
      provvigioneController.text,
    );

    final retrocessioneEuro = importo * retrocessionePercentuale / 100;
    final provvigioneEuro = importo * provvigionePercentuale / 100;

    final polizzaVitaCompenso = compensoPolizza(
      importoMutuo: importo,
      premioCliente: polizzaVitaEuro,
      rateizzata: vitaRate,
      percentualeRateizzata: 0.15,
    );
    final polizzaLavoroCompenso = compensoPolizza(
      importoMutuo: importo,
      premioCliente: polizzaLavoroEuro,
      rateizzata: lavoroRate,
      percentualeRateizzata: 0.05,
    );
    final polizzaVitaLavoroCompenso = compensoPolizza(
      importoMutuo: importo,
      premioCliente: polizzaVitaLavoroEuro,
      rateizzata: vitaLavoroRate,
      percentualeRateizzata: 0.15,
    );
    final polizzaScoppioIncendioCompenso = parseEuro(
      controllerFor(
        polizzaScoppioIncendioCompensoControllers,
        index,
      ).text,
    );

    final totaleCompensiPolizze = polizzaVitaCompenso +
        polizzaLavoroCompenso +
        polizzaVitaLavoroCompenso +
        polizzaScoppioIncendioCompenso;

    // Per il preventivo cliente "Compensi KIRON" = provvigione di mediazione,
    // senza mostrare la percentuale. Retrocessione e compensi polizze restano
    // dati interni/report tecnico.
    final totaleCostiPreventivoCliente =
        istruttoriaEuro +
        impostaSostitutivaEuro +
        periziaEuro +
        totalePolizzeCliente +
        provvigioneEuro;

    final result = Map<String, dynamic>.from(prodotto);

    result["istruttoria_percentuale"] = istruttoriaPercentuale;
    result["istruttoria_euro"] = istruttoriaEuro;
    result["perizia_euro"] = periziaEuro;

    result["imposta_sostitutiva_percentuale"] =
        impostaSostitutivaPercentuale;
    result["imposta_sostitutiva_euro"] = impostaSostitutivaEuro;

    // Alias legacy.
    result["costi_avviamento_percentuale"] =
        impostaSostitutivaPercentuale;
    result["costi_avviamento_euro"] = impostaSostitutivaEuro;

    result["polizza_vita_euro"] = polizzaVitaEuro;
    result["polizza_lavoro_euro"] = polizzaLavoroEuro;
    result["polizza_vita_lavoro_euro"] = polizzaVitaLavoroEuro;
    result["polizza_scoppio_incendio_euro"] =
        polizzaScoppioIncendioEuro;
    result["polizza_vita_rateizzata"] = vitaRate;
    result["polizza_lavoro_rateizzata"] = lavoroRate;
    result["polizza_vita_lavoro_rateizzata"] = vitaLavoroRate;
    result["totale_polizze_cliente"] = totalePolizzeCliente;

    result["retrocessione_percentuale"] = retrocessionePercentuale;
    result["retrocessione_euro"] = retrocessioneEuro;
    result["provvigione_percentuale"] = provvigionePercentuale;
    result["provvigione_euro"] = provvigioneEuro;

    result["polizza_vita_compenso_euro"] = polizzaVitaCompenso;
    result["polizza_lavoro_compenso_euro"] = polizzaLavoroCompenso;
    result["polizza_vita_lavoro_compenso_euro"] =
        polizzaVitaLavoroCompenso;
    result["polizza_scoppio_incendio_compenso_euro"] =
        polizzaScoppioIncendioCompenso;
    result["totale_compensi_polizze"] = totaleCompensiPolizze;

    result["totale_costi_cliente"] =
        istruttoriaEuro +
        impostaSostitutivaEuro +
        periziaEuro +
        totalePolizzeCliente;
    result["totale_costi_preventivo_cliente"] =
        totaleCostiPreventivoCliente;

    // Dato interno mantenuto per report tecnico.
    result["compenso_totale"] =
        retrocessioneEuro + provvigioneEuro + totaleCompensiPolizze;

    return result;
  }

  List<Map<String, dynamic>> prodottiSelezionatiConCosti() {
    final prodotti = widget.response["prodotti"] as List<dynamic>? ?? [];

    final lista = <Map<String, dynamic>>[];

    for (final index in selected) {
      if (index >= 0 && index < prodotti.length) {
        lista.add(
          prodottoConCosti(
            Map<String, dynamic>.from(prodotti[index]),
            index,
          ),
        );
      }
    }

    lista.sort(
      (a, b) => ((a["rata"] as num).toDouble()).compareTo(
        (b["rata"] as num).toDouble(),
      ),
    );

    return lista;
  }
  Future<void> generaPreventivoPdf() async {
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Seleziona almeno un prodotto.",
          ),
        ),
      );

      return;
    }

    final prodottiSelezionati =
        prodottiSelezionatiConCosti();

    setState(() {
      generatingPdf = true;
    });

    try {
      final result =
          await BrokerApi.createQuotePdf(
        cliente: clienteJson(),
        pratica: praticaJson(),
        prodotti: prodottiSelezionati,
      );

      if (!mounted) {
        return;
      }

      if (result["success"] == true) {
        await apriPreventivo(
          result["filename"],
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Errore nella generazione del preventivo.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Errore preventivo PDF: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          generatingPdf = false;
        });
      }
    }
  }

  Future<void> generaReportTecnicoPdf() async {
    final prodotti = widget.response["prodotti"] as List<dynamic>? ?? [];

    if (prodotti.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nessun prodotto da esportare."),
        ),
      );
      return;
    }

    setState(() {
      generatingTechnicalReport = true;
    });

    try {
      final result = await BrokerApi.createTechnicalReportPdf(
        pratica: praticaJson(),
        prodotti: prodotti
            .map((p) => Map<String, dynamic>.from(p as Map))
            .toList(),
        migliore: widget.response["migliore"] == null
            ? null
            : Map<String, dynamic>.from(widget.response["migliore"] as Map),
      );

      if (!mounted) {
        return;
      }

      if (result["success"] == true) {
        await apriPreventivo(result["filename"]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Errore nella generazione del report tecnico."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore report tecnico PDF: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          generatingTechnicalReport = false;
        });
      }
    }
  }

  Widget importoCalcolato({
    required String label,
    required double value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
      ),
      child: Text(
        "$label: € ${value.toStringAsFixed(2)}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget confrontoProdotti() {
    final lista =
        prodottiSelezionatiConCosti();

    if (lista.length < 2) {
      return const SizedBox.shrink();
    }

    final rataMigliore =
        (lista.first["rata"] as num)
            .toDouble();

    return Card(
      color: Colors.green.shade50,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(
          14,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "📊 Confronto prodotti selezionati",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1.2),
                5: FlexColumnWidth(1.2),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.all(6),
                      child: Text(
                        "Banca",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(6),
                      child: Text(
                        "Rata",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(6),
                      child: Text(
                        "Diff.",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(6),
                      child: Text(
                        "Tasso",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(6),
                      child: Text(
                        "Spread",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(6),
                      child: Text(
                        "Costi",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                for (final p in lista)
                  TableRow(
                    decoration: p == lista.first
                        ? BoxDecoration(
                            color: Colors
                                .green
                                .shade100,
                          )
                        : null,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.all(
                          6,
                        ),
                        child: Text(
                          "${p["banca"]}",
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(
                          6,
                        ),
                        child: Text(
                          euro(
                            (p["rata"]
                                    as num)
                                .toDouble(),
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(
                          6,
                        ),
                        child: Text(
                          "+${euro(((p["rata"] as num).toDouble()) - rataMigliore)}",
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(
                          6,
                        ),
                        child: Text(
                          "${(p["tasso_finito"] as num).toStringAsFixed(2)}%",
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(
                          6,
                        ),
                        child: Text(
                          "${(p["spread"] as num).toStringAsFixed(2)}%",
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(
                          6,
                        ),
                        child: Text(
                          euro(
                            (p["totale_costi_cliente"]
                                    as num)
                                .toDouble(),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRiga({
    required String label,
    required String value,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget costiClienteBox(
    Map<String, dynamic> r,
    int index,
  ) {
    final istruttoriaEuro =
        ((r["istruttoria_euro"] ?? 0) as num).toDouble();
    final periziaEuro = ((r["perizia_euro"] ?? 0) as num).toDouble();
    final costiAvviamentoPercentuale =
        ((r["imposta_sostitutiva_percentuale"] ??
          r["costi_avviamento_percentuale"] ??
          0.25) as num).toDouble();
    final costiAvviamentoEuro =
        ((r["imposta_sostitutiva_euro"] ??
          r["costi_avviamento_euro"] ??
          0) as num).toDouble();

    final polizzaVitaEuro = polizzaImporto(
      r,
      index,
      "polizza_vita_euro",
      polizzaVitaControllers,
    );
    final polizzaLavoroEuro = polizzaImporto(
      r,
      index,
      "polizza_lavoro_euro",
      polizzaLavoroControllers,
    );
    final polizzaVitaLavoroEuro = polizzaImporto(
      r,
      index,
      "polizza_vita_lavoro_euro",
      polizzaVitaLavoroControllers,
    );
    final polizzaScoppioIncendioEuro = polizzaImporto(
      r,
      index,
      "polizza_scoppio_incendio_euro",
      polizzaScoppioIncendioControllers,
    );

    final totalePolizzeCliente = polizzaVitaEuro +
        polizzaLavoroEuro +
        polizzaVitaLavoroEuro +
        polizzaScoppioIncendioEuro;
    final totaleCostiCliente = istruttoriaEuro +
        periziaEuro +
        costiAvviamentoEuro +
        totalePolizzeCliente;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "COSTI CLIENTE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            infoRiga(
              label: "Istruttoria",
              value: euro(istruttoriaEuro),
            ),
            infoRiga(
              label: "Perizia",
              value: euro(periziaEuro),
            ),
            infoRiga(
              label:
                  "Imposta sostitutiva (${costiAvviamentoPercentuale.toStringAsFixed(2)}%)",
              value: euro(costiAvviamentoEuro),
            ),
            if (polizzaVitaEuro > 0)
              infoRiga(
                label: polizzaRate(r, index, "polizza_vita_rateizzata", polizzaVitaRateizzata)
                    ? "Polizza Vita (rateizzata)"
                    : "Polizza Vita",
                value: euro(polizzaVitaEuro),
              ),
            if (polizzaLavoroEuro > 0)
              infoRiga(
                label: polizzaRate(r, index, "polizza_lavoro_rateizzata", polizzaLavoroRateizzata)
                    ? "Polizza Lavoro (rateizzata)"
                    : "Polizza Lavoro",
                value: euro(polizzaLavoroEuro),
              ),
            if (polizzaVitaLavoroEuro > 0)
              infoRiga(
                label: polizzaRate(r, index, "polizza_vita_lavoro_rateizzata", polizzaVitaLavoroRateizzata)
                    ? "Polizza Vita + Lavoro (rateizzata)"
                    : "Polizza Vita + Lavoro",
                value: euro(polizzaVitaLavoroEuro),
              ),
            if (polizzaScoppioIncendioEuro > 0)
              infoRiga(
                label: "Polizza Scoppio e Incendio",
                value: euro(polizzaScoppioIncendioEuro),
              ),
            const Divider(),
            infoRiga(
              label: "Totale costi cliente",
              value: euro(totaleCostiCliente),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget compensiBroker(
    Map<String, dynamic> r,
    int index,
  ) {
    final importo = (r["importo_finanziato"] as num).toDouble();

    final retrocessioneController = controllerFor(
      retrocessioneControllers,
      index,
    );

    final provvigioneController = controllerFor(
      provvigioneControllers,
      index,
    );

    setDefaultPercentIfEmpty(
      retrocessioneController,
      r["retrocessione_percentuale"],
    );

    setDefaultPercentIfEmpty(
      provvigioneController,
      r["provvigione_percentuale"],
    );

    final retrocessionePercentuale = parsePercent(
      retrocessioneController.text,
    );
    final provvigionePercentuale = parsePercent(
      provvigioneController.text,
    );

    final retrocessioneEuro = importo * retrocessionePercentuale / 100;
    final provvigioneEuro = importo * provvigionePercentuale / 100;

    final polizzaVitaEuro = polizzaImporto(
      r,
      index,
      "polizza_vita_euro",
      polizzaVitaControllers,
    );
    final polizzaLavoroEuro = polizzaImporto(
      r,
      index,
      "polizza_lavoro_euro",
      polizzaLavoroControllers,
    );
    final polizzaVitaLavoroEuro = polizzaImporto(
      r,
      index,
      "polizza_vita_lavoro_euro",
      polizzaVitaLavoroControllers,
    );

    final vitaRate = polizzaRate(r, index, "polizza_vita_rateizzata", polizzaVitaRateizzata);
    final lavoroRate = polizzaRate(r, index, "polizza_lavoro_rateizzata", polizzaLavoroRateizzata);
    final vitaLavoroRate = polizzaRate(r, index, "polizza_vita_lavoro_rateizzata", polizzaVitaLavoroRateizzata);

    final polizzaVitaPercentuale = percentualeCompensoPolizza(
      rateizzata: vitaRate,
      percentualeRateizzata: 0.15,
    );
    final polizzaLavoroPercentuale = percentualeCompensoPolizza(
      rateizzata: lavoroRate,
      percentualeRateizzata: 0.05,
    );
    final polizzaVitaLavoroPercentuale = percentualeCompensoPolizza(
      rateizzata: vitaLavoroRate,
      percentualeRateizzata: 0.15,
    );

    final polizzaVitaCompenso = compensoPolizza(
      importoMutuo: importo,
      premioCliente: polizzaVitaEuro,
      rateizzata: vitaRate,
      percentualeRateizzata: 0.15,
    );
    final polizzaLavoroCompenso = compensoPolizza(
      importoMutuo: importo,
      premioCliente: polizzaLavoroEuro,
      rateizzata: lavoroRate,
      percentualeRateizzata: 0.05,
    );
    final polizzaVitaLavoroCompenso = compensoPolizza(
      importoMutuo: importo,
      premioCliente: polizzaVitaLavoroEuro,
      rateizzata: vitaLavoroRate,
      percentualeRateizzata: 0.15,
    );
    final polizzaScoppioIncendioCompenso = parseEuro(
      controllerFor(polizzaScoppioIncendioCompensoControllers, index).text,
    );
    final totaleCompensiPolizze = polizzaVitaCompenso +
        polizzaLavoroCompenso +
        polizzaVitaLavoroCompenso +
        polizzaScoppioIncendioCompenso;
    final compensoTotale = retrocessioneEuro + provvigioneEuro + totaleCompensiPolizze;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text(
        "COMPENSI BROKER",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      children: [
        if ((r["retrocessione_source_text"] ?? "").toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Regola retrocessione: ${r["retrocessione_source_text"]}",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        if ((r["retrocessione_rule_page"] ?? 0) != 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Riferimento retrocessioni: pag. ${r["retrocessione_rule_page"]}",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        if (((r["provvigione_massima_percentuale"] ?? 0) as num).toDouble() > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Provvigione di mediazione max: ${((r["provvigione_massima_percentuale"] ?? 0) as num).toDouble().toStringAsFixed(2)}%",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        TextField(
          controller: retrocessioneController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Retrocessione (%)",
            border: OutlineInputBorder(),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        infoRiga(
          label: "Retrocessione percentuale",
          value: "${retrocessionePercentuale.toStringAsFixed(2)}%",
        ),
        infoRiga(
          label: "Retrocessione importo",
          value: euro(retrocessioneEuro),
          bold: true,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: provvigioneController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Provvigione (%)",
            border: OutlineInputBorder(),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        infoRiga(
          label: "Provvigione percentuale",
          value: "${provvigionePercentuale.toStringAsFixed(2)}%",
        ),
        infoRiga(
          label: "Provvigione importo",
          value: euro(provvigioneEuro),
          bold: true,
        ),
        if (polizzaVitaCompenso > 0 || polizzaLavoroCompenso > 0 || polizzaVitaLavoroCompenso > 0 || polizzaScoppioIncendioCompenso > 0) ...[
          const Divider(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Compensi polizze",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if ((r["polizze_rule_page"] ?? 0) != 0)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Riferimento polizze: pag. ${r["polizze_rule_page"]}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          if (polizzaVitaCompenso > 0)
            infoRiga(
              label: 'Polizza Vita (${polizzaVitaPercentuale.toStringAsFixed(2)}% ${vitaRate ? "su mutuo" : "su premio"})',
              value: euro(polizzaVitaCompenso),
            ),
          if (polizzaLavoroCompenso > 0)
            infoRiga(
              label: 'Polizza Lavoro (${polizzaLavoroPercentuale.toStringAsFixed(2)}% ${lavoroRate ? "su mutuo" : "su premio"})',
              value: euro(polizzaLavoroCompenso),
            ),
          if (polizzaVitaLavoroCompenso > 0)
            infoRiga(
              label: 'Polizza Vita + Lavoro (${polizzaVitaLavoroPercentuale.toStringAsFixed(2)}% ${vitaLavoroRate ? "su mutuo" : "su premio"})',
              value: euro(polizzaVitaLavoroCompenso),
            ),
          if (polizzaScoppioIncendioCompenso > 0)
            infoRiga(
              label: "Scoppio e incendio manuale",
              value: euro(polizzaScoppioIncendioCompenso),
            ),
          infoRiga(
            label: "Totale compensi polizze",
            value: euro(totaleCompensiPolizze),
            bold: true,
          ),
        ],
        const Divider(),
        infoRiga(
          label: "Compenso totale broker",
          value: euro(compensoTotale),
          bold: true,
        ),
      ],
    );
  }

  Widget costiManuali(
    Map<String, dynamic> r,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        compensiBroker(r, index),
      ],
    );
  }

  Widget warningsBox(List warnings) {
    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Motivazioni / attenzioni",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            for (final warning in warnings)
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 6,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        warning.toString(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget resultCard(
    Map<String, dynamic> r,
    int index,
  ) {
    final bool isSelected =
        selected.contains(index);

    final pdfName =
        r["pdf"]?.toString() ?? "";

    final paginaPdf = int.tryParse(
          r["pagina"].toString(),
        ) ??
        1;

    return Card(
      margin:
          const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selected.add(index);
                      } else {
                        selected.remove(index);
                      }
                    });
                  },
                ),
                const Icon(
                  Icons.account_balance,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${index + 1}) ${r["banca"]}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: pdfName.isEmpty
                      ? null
                      : () {
                          apriPdf(
                            pdfName,
                            paginaPdf,
                          );
                        },
                  icon: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  label: Text(
                    "Apri PDF pag. $paginaPdf",
                  ),
                ),
              ],
            ),
            const Divider(),
            Text("Prodotto: ${r["prodotto"]}"),
            if (r["prodotto_speciale"] == true) ...[
              if (r["promozione"] == "GREEN") ...[
                Text("Promozione: Green"),
                if (r["green_tipo_label"] != null)
                  Text("Tipo Green: ${r["green_tipo_label"]}"),
                if (r["green_finalita"] != null)
                  Text("Finalità Green: ${r["green_finalita"]}"),
                if (r["green_classe_energetica"] != null)
                  Text("Classe Green: ${r["green_classe_energetica"]}"),
                if (r["green_sconto"] is num)
                  Text("Sconto Green: -${(r["green_sconto"] as num).toStringAsFixed(2)}%"),
                if (r["green_limite_importo_applicato"] == true && r["green_limite_importo"] is num)
                  Text("Limite Green: importo inferiore a € ${(r["green_limite_importo"] as num).toStringAsFixed(2)}"),
                if (r["green_limite_importo_applicato"] == false)
                  const Text("Limite Green 250.000: non applicato su Acquisto semplice A/B"),
                if (r["green_note_applicazione"] != null)
                  Text("Nota Green: ${r["green_note_applicazione"]}"),
                if (r["green_requisiti"] is List && (r["green_requisiti"] as List).isNotEmpty) ...[
                  const Text("Requisiti Green:"),
                  for (final requisito in r["green_requisiti"] as List)
                    Text("• ${requisito.toString()}"),
                ],
                if (r["pagina_regola_green"] != null)
                  Text("Riferimento regola Green: pag. ${r["pagina_regola_green"]}"),
              ],
              if (r["convenzione"] != null)
                Text("Convenzione: ${r["convenzione"] ?? "-"}"),
              if (r["ltc_periodo"] != null)
                Text("Periodo LTC: ${r["ltc_periodo"]}"),
              if (r["ltc_reddito_minimo"] is num)
                Text("Reddito minimo LTC: € ${(r["ltc_reddito_minimo"] as num).toStringAsFixed(2)}"),
              if (r["ltc_reddito_soglia"] is num && r["ltc_reddito_operatore"] != null)
                Text("Soglia requisito: mutuo ${r["ltc_reddito_operatore"]} € ${(r["ltc_reddito_soglia"] as num).toStringAsFixed(2)}"),
              if (r["valore_perizia"] is num)
                Text("Valore perizia: € ${(r["valore_perizia"] as num).toStringAsFixed(2)}"),
              if (r["massimo_finanziabile_ltc"] is num)
                Text("Massimo finanziabile LTC: € ${(r["massimo_finanziabile_ltc"] as num).toStringAsFixed(2)}"),
              if (r["pagina_regola_ltc"] != null)
                Text("Riferimento regola LTC: pag. ${r["pagina_regola_ltc"]}"),
              if (r["motivo_prodotto_speciale"] != null)
                Text("Nota: ${r["motivo_prodotto_speciale"]}"),
            ],
            Text("Listino: ${r["listino"]}"),
            Text(
              "Importo finanziato: € ${(r["importo_finanziato"] as num).toStringAsFixed(2)}",
            ),
            Text(
              "LTV pratica: ${(r["ltv"] as num).toStringAsFixed(2)}%",
            ),
            Text(
              "LTV massimo: ${r["ltv_massimo"]}%",
            ),
            Text(
              "Spread: ${(r["spread"] as num).toStringAsFixed(2)}%",
            ),
            if (r["prodotto_speciale"] == true && r["spread_base"] != null)
              Text("Spread base: ${r["spread_base"]}"),
            if (r["prodotto_speciale"] == true && r["spread_delta"] is num)
              Text(
                (r["spread_delta"] as num) < 0
                    ? "Sconto: ${(r["spread_delta"] as num).toStringAsFixed(2)}%"
                    : "Maggiorazione: +${(r["spread_delta"] as num).toStringAsFixed(2)}%",
              ),
            Text(
              "Indice: ${(r["indice"] as num).toStringAsFixed(2)}%",
            ),
            Text(
              "Indice riferimento: ${r["indice_riferimento"] ?? "-"}",
            ),
            Text(
              "Tasso esplicito: ${r["tasso_esplicito"] == true ? "Sì" : "No"}",
            ),
            Text(
              "Tasso finito: ${(r["tasso_finito"] as num).toStringAsFixed(2)}%",
            ),
            Text(
              "Rata: € ${(r["rata"] as num).toStringAsFixed(2)}",
            ),
            polizzeClienteBox(r, index),
            costiClienteBox(r, index),
            Text("PDF: ${r["pdf"]}"),
            if (r["pdf_pagine_riferimento"] is List && (r["pdf_pagine_riferimento"] as List).isNotEmpty)
              Text("Pagine PDF riferimento: ${(r["pdf_pagine_riferimento"] as List).join(", ")}")
            else
              Text("Pagina PDF: ${r["pagina"]}"),
            if (isSelected) ...[
              const SizedBox(height: 20),
              costiManuali(
                r,
                index,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final prodotti =
        widget.response["prodotti"]
                as List<dynamic>? ??
            [];

    final migliore =
        widget.response["migliore"];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Risultati Ricerca",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: prodotti.isEmpty
            ? const Center(
                child: Text(
                  "Nessun prodotto compatibile trovato.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              )
            : ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: generatingPdf
                              ? null
                              : generaPreventivoPdf,
                          icon: generatingPdf
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.description,
                                ),
                          label: Text(
                            generatingPdf
                                ? "Generazione in corso..."
                                : "Genera Preventivo PDF",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: generatingTechnicalReport
                              ? null
                              : generaReportTecnicoPdf,
                          icon: generatingTechnicalReport
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.bug_report,
                                ),
                          label: Text(
                            generatingTechnicalReport
                                ? "Report in corso..."
                                : "Esporta Report Tecnico",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  confrontoProdotti(),
                  const SizedBox(height: 20),
                  if (migliore != null) ...[
                    const Text(
                      "🏆 MIGLIORE OFFERTA",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    resultCard(
                      Map<String, dynamic>.from(
                        migliore,
                      ),
                      0,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "ALTRE SOLUZIONI (${prodotti.length})",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                  for (int i = 0;
                      i < prodotti.length;
                      i++)
                    resultCard(
                      Map<String, dynamic>.from(
                        prodotti[i],
                      ),
                      i,
                    ),
                ],
              ),
      ),
    );
  }
}