import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/applicant.dart';
import '../../data/italian_geography.dart';
import '../../providers/practice_provider.dart';
import 'mortgage_page.dart';

class ClientPage extends ConsumerStatefulWidget {

  const ClientPage({super.key});

  @override
  ConsumerState<ClientPage> createState() => _ClientPageState();

}

class _ClientPageState extends ConsumerState<ClientPage> {

  final nomeController = TextEditingController();

  final cognomeController = TextEditingController();

  final residenzaController = TextEditingController();

  final anniItaliaController = TextEditingController();

  final redditoController = TextEditingController();

  final figliController = TextEditingController();

  String? area;

  String? regione;

  String? provincia;

  String? tipoCentro;

  String nazionalita = "Italiana";

  String statoCivile = "Celibe/Nubile";

  String contratto = "Indeterminato";

  DateTime? dataNascita;

  Future<void> scegliData() async {

    DateTime? data = await showDatePicker(

      context: context,

      initialDate: DateTime(1990),

      firstDate: DateTime(1940),

      lastDate: DateTime.now(),

    );

    if (data != null) {

      setState(() {

        dataNascita = data;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "Richiedente 1",

        ),

      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          const Text(

            "DATI RICHIEDENTE",

            style: TextStyle(

              fontSize: 24,

              fontWeight: FontWeight.bold,

            ),

          ),

          const SizedBox(height: 20),

          TextField(

            controller: nomeController,

            decoration: const InputDecoration(

              labelText: "Nome",

            ),

          ),

          const SizedBox(height: 15),

          TextField(

            controller: cognomeController,

            decoration: const InputDecoration(

              labelText: "Cognome",

            ),

          ),

          const SizedBox(height: 15),

          TextField(

            controller: residenzaController,

            decoration: const InputDecoration(

              labelText: "Residenza",

            ),

          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: area,
            decoration: const InputDecoration(
              labelText: "Area geografica",
            ),
            items: const [
              DropdownMenuItem(value: "Nord", child: Text("Nord")),
              DropdownMenuItem(value: "Centro", child: Text("Centro")),
              DropdownMenuItem(value: "Sud", child: Text("Sud")),
            ],
            onChanged: (v) => setState(() => area = v),
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: regione,
            decoration: const InputDecoration(
              labelText: "Regione",
            ),
            items: ItalianGeography.regions
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) {
              setState(() {
                regione = v;
                provincia = null;
                if (v != null) {
                  area = ItalianGeography.areaByRegion[v] ?? area;
                }
              });
            },
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: provincia,
            decoration: const InputDecoration(
              labelText: "Provincia",
            ),
            items: regione == null
                ? const []
                : ItalianGeography.provinces(regione!)
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
            onChanged: regione == null
                ? null
                : (v) => setState(() => provincia = v),
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: tipoCentro,
            decoration: const InputDecoration(
              labelText: "Tipologia centro",
              helperText: "Usata solo dalle banche che distinguono Metropoli, Grande Centro e Piccolo Centro.",
            ),
            items: const [
              DropdownMenuItem(value: "METROPOLI", child: Text("Metropoli")),
              DropdownMenuItem(value: "GRANDE_CENTRO", child: Text("Grande Centro")),
              DropdownMenuItem(value: "PICCOLO_CENTRO", child: Text("Piccolo Centro")),
            ],
            onChanged: (v) => setState(() => tipoCentro = v),
          ),

          const SizedBox(height: 15),

          InkWell(

            onTap: scegliData,

            child: InputDecorator(

              decoration: const InputDecoration(

                labelText: "Data di nascita",

                border: OutlineInputBorder(),

              ),

              child: Text(

                dataNascita == null

                    ? "Seleziona Data"

                    : "${dataNascita!.day.toString().padLeft(2, '0')}/"
                      "${dataNascita!.month.toString().padLeft(2, '0')}/"
                      "${dataNascita!.year}",

              ),

            ),

          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(

            value: nazionalita,

            decoration: const InputDecoration(

              labelText: "Nazionalità",

            ),

            items: const [

              DropdownMenuItem(

                value: "Italiana",

                child: Text("Italiana"),

              ),

              DropdownMenuItem(

                value: "Albanese",

                child: Text("Albanese"),

              ),

              DropdownMenuItem(

                value: "Rumena",

                child: Text("Rumena"),

              ),

              DropdownMenuItem(

                value: "Marocchina",

                child: Text("Marocchina"),

              ),

              DropdownMenuItem(

                value: "Francese",

                child: Text("Francese"),

              ),

            ],

            onChanged: (v) {

              setState(() {

                nazionalita = v!;

              });

            },

          ),

          if (nazionalita != "Italiana") ...[

            const SizedBox(height: 15),

            TextField(

              controller: anniItaliaController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Anni in Italia",

              ),

            ),

          ],

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(

            value: statoCivile,

            decoration: const InputDecoration(

              labelText: "Stato Civile",

            ),

            items: const [

              DropdownMenuItem(

                value: "Celibe/Nubile",

                child: Text("Celibe/Nubile"),

              ),

              DropdownMenuItem(

                value: "Coniugato",

                child: Text("Coniugato"),

              ),

              DropdownMenuItem(

                value: "Separato",

                child: Text("Separato"),

              ),

              DropdownMenuItem(

                value: "Divorziato",

                child: Text("Divorziato"),

              ),

            ],

            onChanged: (v) {

              setState(() {

                statoCivile = v!;

              });

            },

          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(

            value: contratto,

            decoration: const InputDecoration(

              labelText: "Tipo contratto",

            ),

            items: const [

              DropdownMenuItem(

                value: "Indeterminato",

                child: Text("Indeterminato"),

              ),

              DropdownMenuItem(

                value: "Determinato",

                child: Text("Determinato"),

              ),

              DropdownMenuItem(

                value: "Autonomo",

                child: Text("Autonomo"),

              ),

            ],

            onChanged: (v) {

              setState(() {

                contratto = v!;

              });

            },

          ),

          const SizedBox(height: 15),

          TextField(

            controller: redditoController,

            keyboardType: TextInputType.number,

            decoration: const InputDecoration(

              labelText: "Reddito netto mensile (€)",

            ),

          ),

          const SizedBox(height: 15),

          TextField(

            controller: figliController,

            keyboardType: TextInputType.number,

            decoration: const InputDecoration(

              labelText: "Persone a carico",

            ),

          ),

          const SizedBox(height: 30),
                    ElevatedButton(

            onPressed: () {

              final nome = nomeController.text.trim();
              final cognome = cognomeController.text.trim();

              if (nome.isEmpty || cognome.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nome e cognome sono obbligatori.")),
                );
                return;
              }

              if (area == null || regione == null || provincia == null || tipoCentro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Area geografica, Regione, Provincia e Tipologia centro sono obbligatorie."),
                  ),
                );
                return;
              }

              final applicant = Applicant(

                nome: nome,

                cognome: cognome,

                residenza: residenzaController.text,

                area: area == "Nord"
                    ? GeographicArea.nord
                    : area == "Centro"
                        ? GeographicArea.centro
                        : GeographicArea.sud,

                regione: regione!,

                provincia: provincia!,

                tipoCentro: tipoCentro!,

                dataNascita:
                    dataNascita ?? DateTime(1990, 1, 1),

                nazionalita: nazionalita,

                anniItalia:
                    int.tryParse(
                          anniItaliaController.text,
                        ) ??
                        0,

                statoCivile: statoCivile,

                contratto:
                    contratto == "Indeterminato"
                        ? ContractType.indeterminato
                        : contratto == "Determinato"
                            ? ContractType.determinato
                            : ContractType.autonomo,

                reddito:
                    double.tryParse(
                          redditoController.text
                              .replaceAll(",", "."),
                        ) ??
                        0,

                figli:
                    int.tryParse(
                          figliController.text,
                        ) ??
                        0,

              );

              final notifier =
                  ref.read(practiceProvider.notifier);
              final praticaCorrente =
                  ref.read(practiceProvider);

              // Questa schermata rappresenta Richiedente 1.
              // Se si torna indietro da Mutuo/Debiti e si preme di nuovo
              // Continua, aggiorniamo il richiedente esistente invece di
              // aggiungerne una copia.
              if (praticaCorrente.richiedenti.isEmpty) {
                notifier.addApplicant(applicant);
              } else {
                notifier.updateApplicant(0, applicant);
              }

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) => const MortgagePage(),

                ),

              );

            },

            child: const Text(

              "Continua",

            ),

          ),

          const SizedBox(height: 20),

        ],


    ),

  );

 }

}