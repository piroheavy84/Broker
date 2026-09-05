import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mortgage.dart';
import '../../providers/practice_provider.dart';
import 'debts_page.dart';

class MortgagePage extends ConsumerStatefulWidget {
  const MortgagePage({super.key});

  @override
  ConsumerState<MortgagePage> createState() => _MortgagePageState();
}

class _MortgagePageState extends ConsumerState<MortgagePage> {
  final valoreController = TextEditingController();
  final valorePeriziaController = TextEditingController();
  final importoController = TextEditingController();
  final durataController = TextEditingController();
  final polizzaVitaController = TextEditingController();
  final polizzaLavoroController = TextEditingController();
  final polizzaVitaLavoroController = TextEditingController();
  final polizzaScoppioIncendioController = TextEditingController();
  final polizzaScoppioIncendioCompensoController = TextEditingController();

  bool polizzaVitaRateizzata = false;
  bool polizzaLavoroRateizzata = false;
  bool polizzaVitaLavoroRateizzata = false;

  String finalita = "Acquisto Prima Casa";
  String tipologia = "Prima Casa";
  String classe = "A4";
  String tipoTasso = "Fisso";

  DateTime? dataRogito;

  MortgagePurpose _purposeFromLabel(String value) {
    switch (value) {
      case "Acquisto Prima Casa":
        return MortgagePurpose.acquistoPrimaCasa;
      case "Acquisto Seconda Casa":
        return MortgagePurpose.acquistoSecondaCasa;
      case "Acquisto + Ristrutturazione":
        return MortgagePurpose.acquistoRistrutturazione;
      case "Sostituzione":
        return MortgagePurpose.sostituzione;
      case "Sostituzione + Ristrutturazione":
        return MortgagePurpose.sostituzioneRistrutturazione;
      case "Surroga":
        return MortgagePurpose.surroga;
      case "Rifinanziamento":
        return MortgagePurpose.rifinanziamento;
      case "Liquidità":
        return MortgagePurpose.liquidita;
      case "Ristrutturazione":
        return MortgagePurpose.ristrutturazione;
      case "Costruzione":
        return MortgagePurpose.costruzione;
      case "Consolidamento Debiti":
        return MortgagePurpose.consolidamentoDebiti;
      case "Dismissioni Enasarco":
        return MortgagePurpose.dismissioniEnasarco;
      default:
        return MortgagePurpose.acquistoPrimaCasa;
    }
  }

  Future<void> scegliData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (data != null) {
      setState(() {
        dataRogito = data;
      });
    }
  }

  @override
  void dispose() {
    valoreController.dispose();
    valorePeriziaController.dispose();
    importoController.dispose();
    durataController.dispose();
    polizzaVitaController.dispose();
    polizzaLavoroController.dispose();
    polizzaVitaLavoroController.dispose();
    polizzaScoppioIncendioController.dispose();
    polizzaScoppioIncendioCompensoController.dispose();

    super.dispose();
  }

  double euroValue(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(",", ".")) ?? 0;
  }

  Widget polizzaField({
    required String title,
    required TextEditingController controller,
    required bool rateizzata,
    required ValueChanged<bool> onRateizzataChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Premio rateizzato"),
              subtitle: Text(
                rateizzata
                    ? "Provvigione calcolata su importo mutuo"
                    : "Provvigione calcolata sul premio inserito",
              ),
              value: rateizzata,
              onChanged: onRateizzataChanged,
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
        title: const Text("Immobile e Mutuo"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "DATI IMMOBILE E MUTUO",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: finalita,
            decoration: const InputDecoration(
              labelText: "Finalità",
            ),
            items: const [
              DropdownMenuItem(
                value: "Acquisto Prima Casa",
                child: Text("Acquisto Prima Casa"),
              ),
              DropdownMenuItem(
                value: "Acquisto Seconda Casa",
                child: Text("Acquisto Seconda Casa"),
              ),
              DropdownMenuItem(
                value: "Acquisto + Ristrutturazione",
                child: Text("Acquisto + Ristrutturazione"),
              ),
              DropdownMenuItem(
                value: "Sostituzione",
                child: Text("Sostituzione"),
              ),
              DropdownMenuItem(
                value: "Sostituzione + Ristrutturazione",
                child: Text("Sostituzione + Ristrutturazione"),
              ),
              DropdownMenuItem(
                value: "Surroga",
                child: Text("Surroga"),
              ),
              DropdownMenuItem(
                value: "Rifinanziamento",
                child: Text("Rifinanziamento"),
              ),
              DropdownMenuItem(
                value: "Liquidità",
                child: Text("Liquidità"),
              ),
              DropdownMenuItem(
                value: "Ristrutturazione",
                child: Text("Ristrutturazione"),
              ),
              DropdownMenuItem(
                value: "Costruzione",
                child: Text("Costruzione"),
              ),
              DropdownMenuItem(
                value: "Consolidamento Debiti",
                child: Text("Consolidamento Debiti"),
              ),
              DropdownMenuItem(
                value: "Dismissioni Enasarco",
                child: Text("Dismissioni Enasarco"),
              ),
            ],
            onChanged: (v) {
              setState(() {
                finalita = v!;
              });
            },
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: tipologia,
            decoration: const InputDecoration(
              labelText: "Tipologia immobile",
            ),
            items: const [
              DropdownMenuItem(
                value: "Prima Casa",
                child: Text("Prima Casa"),
              ),
              DropdownMenuItem(
                value: "Seconda Casa",
                child: Text("Seconda Casa"),
              ),
              DropdownMenuItem(
                value: "Commerciale",
                child: Text("Commerciale"),
              ),
              DropdownMenuItem(
                value: "Terreno",
                child: Text("Terreno"),
              ),
              DropdownMenuItem(
                value: "Nessun Immobile",
                child: Text("Nessun Immobile"),
              ),
            ],
            onChanged: (v) {
              setState(() {
                tipologia = v!;
              });
            },
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: classe,
            decoration: const InputDecoration(
              labelText: "Classe Energetica",
            ),
            items: const [
              DropdownMenuItem(value: "A4", child: Text("A4")),
              DropdownMenuItem(value: "A3", child: Text("A3")),
              DropdownMenuItem(value: "A2", child: Text("A2")),
              DropdownMenuItem(value: "A1", child: Text("A1")),
              DropdownMenuItem(value: "B", child: Text("B")),
              DropdownMenuItem(value: "C", child: Text("C")),
              DropdownMenuItem(value: "D", child: Text("D")),
              DropdownMenuItem(value: "E", child: Text("E")),
              DropdownMenuItem(value: "F", child: Text("F")),
              DropdownMenuItem(value: "G", child: Text("G")),
            ],
            onChanged: (v) {
              setState(() {
                classe = v!;
              });
            },
          ),

          const SizedBox(height: 15),

          TextField(
            controller: valoreController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Valore commerciale immobile (€)",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: valorePeriziaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Valore perizia (€) - opzionale",
              helperText: "Serve per verificare eventuali prodotti LTC.",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: importoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Importo richiesto (€)",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: durataController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Durata (anni)",
            ),
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: tipoTasso,
            decoration: const InputDecoration(
              labelText: "Tipo Tasso",
            ),
            items: const [
              DropdownMenuItem(
                value: "Fisso",
                child: Text("Fisso"),
              ),
              DropdownMenuItem(
                value: "Variabile",
                child: Text("Variabile"),
              ),
            ],
            onChanged: (v) {
              setState(() {
                tipoTasso = v!;
              });
            },
          ),

          const SizedBox(height: 15),

          Text(
            tipoTasso == "Fisso"
                ? "IRS calcolato automaticamente dalla tabella EURIRS."
                : "Euribor calcolato automaticamente dalla tabella EURIBOR.",
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 15),

          InkWell(
            onTap: scegliData,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Rogito / Stipula entro il",
                border: OutlineInputBorder(),
              ),
              child: Text(
                dataRogito == null
                    ? "Seleziona Data"
                    : "${dataRogito!.day.toString().padLeft(2, '0')}/${dataRogito!.month.toString().padLeft(2, '0')}/${dataRogito!.year}",
              ),
            ),
          ),

          const SizedBox(height: 30),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () {
              final mortgage = Mortgage(
                finalita: _purposeFromLabel(finalita),
                tipologia: tipologia == "Prima Casa"
                    ? PropertyType.primaCasa
                    : tipologia == "Seconda Casa"
                        ? PropertyType.secondaCasa
                        : tipologia == "Commerciale"
                            ? PropertyType.commerciale
                            : tipologia == "Terreno"
                                ? PropertyType.terreno
                                : PropertyType.nessunImmobile,
                classeEnergetica: classe,
                valoreImmobile: double.tryParse(
                      valoreController.text.replaceAll(",", "."),
                    ) ??
                    0,
                valorePerizia: valorePeriziaController.text.trim().isEmpty
                    ? null
                    : double.tryParse(
                        valorePeriziaController.text.replaceAll(",", "."),
                      ),
                importoRichiesto: double.tryParse(
                      importoController.text.replaceAll(",", "."),
                    ) ??
                    0,
                durata: int.tryParse(durataController.text) ?? 0,
                tipoTasso: tipoTasso == "Fisso"
                    ? MortgageRateType.fisso
                    : MortgageRateType.variabile,
                irs: 0,
                euribor: 0,
                dataRogito: dataRogito,
                polizzaVitaEuro: euroValue(polizzaVitaController),
                polizzaVitaRateizzata: polizzaVitaRateizzata,
                polizzaLavoroEuro: euroValue(polizzaLavoroController),
                polizzaLavoroRateizzata: polizzaLavoroRateizzata,
                polizzaVitaLavoroEuro: euroValue(polizzaVitaLavoroController),
                polizzaVitaLavoroRateizzata: polizzaVitaLavoroRateizzata,
                polizzaScoppioIncendioEuro: euroValue(polizzaScoppioIncendioController),
                polizzaScoppioIncendioCompensoEuro: euroValue(polizzaScoppioIncendioCompensoController),
              );

              ref.read(practiceProvider.notifier).setMortgage(mortgage);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DebtsPage(),
                ),
              );
            },
            child: const Text("Continua"),
          ),
        ],
      ),
    );
  }
}