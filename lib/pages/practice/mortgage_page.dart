import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mortgage.dart';
import '../../providers/practice_provider.dart';
import 'debts_page.dart';

class MortgagePage extends ConsumerStatefulWidget {

  const MortgagePage({super.key});

  @override
  ConsumerState<MortgagePage> createState() =>
      _MortgagePageState();

}

class _MortgagePageState
    extends ConsumerState<MortgagePage> {

  final valoreController =
      TextEditingController();

  final importoController =
      TextEditingController();

  final durataController =
      TextEditingController();

  final irsController =
      TextEditingController();

  final euriborController =
      TextEditingController();

  String finalita =
      "Acquisto Prima Casa";

  String tipologia =
      "Prima Casa";

  String classe =
      "A4";

  String tipoTasso =
      "Fisso";

  DateTime? dataRogito;

  Future<void> scegliData() async {

    final data =
        await showDatePicker(

      context: context,

      initialDate:
          DateTime.now(),

      firstDate:
          DateTime.now(),

      lastDate:
          DateTime(2035),

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

    importoController.dispose();

    durataController.dispose();

    irsController.dispose();

    euriborController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Immobile e Mutuo",
        ),

      ),

      body: ListView(

        padding:
            const EdgeInsets.all(20),

        children: [

          const Text(

            "DATI IMMOBILE E MUTUO",

            style: TextStyle(

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,

            ),

          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(

            value: finalita,

            decoration:
                const InputDecoration(

              labelText: "Finalità",

            ),

            items: const [

              DropdownMenuItem(
                value:
                    "Acquisto Prima Casa",
                child: Text(
                    "Acquisto Prima Casa"),
              ),

              DropdownMenuItem(
                value:
                    "Acquisto Seconda Casa",
                child: Text(
                    "Acquisto Seconda Casa"),
              ),

              DropdownMenuItem(
                value: "Surroga",
                child: Text("Surroga"),
              ),

              DropdownMenuItem(
                value: "Liquidità",
                child:
                    Text("Liquidità"),
              ),

              DropdownMenuItem(
                value:
                    "Ristrutturazione",
                child: Text(
                    "Ristrutturazione"),
              ),

              DropdownMenuItem(
                value:
                    "Costruzione",
                child:
                    Text("Costruzione"),
              ),

              DropdownMenuItem(
                value:
                    "Consolidamento Debiti",
                child: Text(
                    "Consolidamento Debiti"),
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

            decoration:
                const InputDecoration(

              labelText:
                  "Tipologia immobile",

            ),

            items: const [

              DropdownMenuItem(
                value:
                    "Prima Casa",
                child:
                    Text("Prima Casa"),
              ),

              DropdownMenuItem(
                value:
                    "Seconda Casa",
                child: Text(
                    "Seconda Casa"),
              ),

              DropdownMenuItem(
                value:
                    "Commerciale",
                child:
                    Text("Commerciale"),
              ),

              DropdownMenuItem(
                value:
                    "Terreno",
                child:
                    Text("Terreno"),
              ),

              DropdownMenuItem(
                value:
                    "Nessun Immobile",
                child: Text(
                    "Nessun Immobile"),
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

          if (tipoTasso == "Fisso")
            TextField(
              controller: irsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "IRS (%)",
              ),
            ),

          if (tipoTasso == "Variabile")
            TextField(
              controller: euriborController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "EURIBOR 3M (%)",
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

          ElevatedButton(
            onPressed: () {

              final mortgage = Mortgage(

                finalita: finalita == "Acquisto Prima Casa"
                    ? MortgagePurpose.acquistoPrimaCasa
                    : finalita == "Acquisto Seconda Casa"
                        ? MortgagePurpose.acquistoSecondaCasa
                        : finalita == "Surroga"
                            ? MortgagePurpose.surroga
                            : finalita == "Liquidità"
                                ? MortgagePurpose.liquidita
                                : finalita == "Ristrutturazione"
                                    ? MortgagePurpose.ristrutturazione
                                    : finalita == "Costruzione"
                                        ? MortgagePurpose.costruzione
                                        : MortgagePurpose.consolidamentoDebiti,

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
                        valoreController.text.replaceAll(",", ".")) ??
                    0,

                importoRichiesto: double.tryParse(
                        importoController.text.replaceAll(",", ".")) ??
                    0,

                durata:
                    int.tryParse(durataController.text) ?? 0,

                tipoTasso: tipoTasso == "Fisso"
                    ? MortgageRateType.fisso
                    : MortgageRateType.variabile,

                irs: double.tryParse(
                        irsController.text.replaceAll(",", ".")) ??
                    0,

                euribor: double.tryParse(
                        euriborController.text.replaceAll(",", ".")) ??
                    0,

                dataRogito: dataRogito,

              );

              ref
                  .read(practiceProvider.notifier)
                  .setMortgage(mortgage);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DebtsPage(),
                ),
              );

            },

            child: const Text(
              "Continua",
            ),

          ),

        ],

      

    ),

  );

}

}