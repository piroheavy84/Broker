import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/debt.dart';
import '../../providers/practice_provider.dart';
import 'verification_page.dart';

class DebtsPage extends ConsumerStatefulWidget {

  const DebtsPage({super.key});

  @override
  ConsumerState<DebtsPage> createState() =>
      _DebtsPageState();

}

class _DebtsPageState
    extends ConsumerState<DebtsPage> {

  bool nessunDebito = false;

  final istitutoController =
      TextEditingController();

  final rataController =
      TextEditingController();

  final residuoController =
      TextEditingController();

  String richiedente =
      "Richiedente 1";

  String tipologia =
      "Prestito Personale";

  @override
  void dispose() {

    istitutoController.dispose();

    rataController.dispose();

    residuoController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    final pratica =
        ref.watch(practiceProvider);

    double totaleRate = 0;

    for (final d in pratica.debts) {

      totaleRate += d.rata;

    }

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Situazione Debitoria",
        ),

      ),

      body: ListView(

        padding:
            const EdgeInsets.all(20),

        children: [

          CheckboxListTile(

            value: nessunDebito,

            title: const Text(
              "Il cliente non ha debiti",
            ),

            onChanged: (v) {

              setState(() {

                nessunDebito = v!;

              });

            },

          ),

          const SizedBox(height: 20),

          const Text(

            "Totale Rate Mensili",

            style: TextStyle(

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,

            ),

          ),

          const SizedBox(height: 10),

          Text(

            "€ ${totaleRate.toStringAsFixed(2)}",

            style: const TextStyle(

              fontSize: 30,

            ),

          ),

          if (!nessunDebito) ...[

            const SizedBox(height: 30),

            const Text(

              "NUOVO DEBITO",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(

              value: richiedente,

              decoration:
                  const InputDecoration(

                labelText: "Richiedente",

              ),

              items: const [

                DropdownMenuItem(
                  value: "Richiedente 1",
                  child:
                      Text("Richiedente 1"),
                ),

                DropdownMenuItem(
                  value: "Richiedente 2",
                  child:
                      Text("Richiedente 2"),
                ),

                DropdownMenuItem(
                  value: "Richiedente 3",
                  child:
                      Text("Richiedente 3"),
                ),

              ],

              onChanged: (v) {

                setState(() {

                  richiedente = v!;

                });

              },

            ),

            const SizedBox(height: 15),

            TextField(

              controller:
                  istitutoController,

              decoration:
                  const InputDecoration(

                labelText: "Istituto",

              ),

            ),

            const SizedBox(height: 15),

            TextField(

              controller:
                  rataController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText:
                    "Rata Mensile (€)",

              ),

            ),

            const SizedBox(height: 15),

            TextField(

              controller:
                  residuoController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText:
                    "Capitale Residuo (€)",

              ),

            ),
                        const SizedBox(height: 15),

            DropdownButtonFormField<String>(

              value: tipologia,

              decoration: const InputDecoration(

                labelText: "Tipologia Debito",

              ),

              items: const [

                DropdownMenuItem(

                  value: "Mutuo",

                  child: Text("Mutuo"),

                ),

                DropdownMenuItem(

                  value: "Prestito Personale",

                  child: Text("Prestito Personale"),

                ),

                DropdownMenuItem(

                  value: "Cessione Quinto",

                  child: Text("Cessione Quinto"),

                ),

                DropdownMenuItem(

                  value: "Leasing",

                  child: Text("Leasing"),

                ),

                DropdownMenuItem(

                  value: "Carta Rateale",

                  child: Text("Carta Rateale"),

                ),

                DropdownMenuItem(

                  value: "Altro",

                  child: Text("Altro"),

                ),

              ],

              onChanged: (v) {

                setState(() {

                  tipologia = v!;

                });

              },

            ),

            const SizedBox(height: 25),

            ElevatedButton(

              onPressed: () {

                final debt = Debt(

                  richiedente: richiedente == "Richiedente 1"
                      ? 1
                      : richiedente == "Richiedente 2"
                          ? 2
                          : 3,

                  istituto: istitutoController.text,

                  rata: double.tryParse(
                          rataController.text.replaceAll(",", "."),
                        ) ??
                        0,

                  residuo: double.tryParse(
                          residuoController.text.replaceAll(",", "."),
                        ) ??
                        0,

                  tipologia: tipologia == "Mutuo"
                      ? DebtType.mutuo
                      : tipologia == "Prestito Personale"
                          ? DebtType.prestitoPersonale
                          : tipologia == "Cessione Quinto"
                              ? DebtType.cessioneQuinto
                              : tipologia == "Leasing"
                                  ? DebtType.leasing
                                  : tipologia == "Carta Rateale"
                                      ? DebtType.cartaRateale
                                      : DebtType.altro,

                );

                ref
                    .read(practiceProvider.notifier)
                    .addDebt(debt);

                istitutoController.clear();

                rataController.clear();

                residuoController.clear();

                setState(() {});

              },

              child: const Text(

                "AGGIUNGI DEBITO",

              ),

            ),

          ],

          const SizedBox(height: 30),

          const Divider(),

          const SizedBox(height: 20),

          const Text(

            "Debiti Inseriti",

            style: TextStyle(

              fontSize: 20,

              fontWeight: FontWeight.bold,

            ),

          ),

          const SizedBox(height: 15),

          for (final d in pratica.debts)

            Card(

              child: ListTile(

                leading: const Icon(

                  Icons.account_balance_wallet,

                ),

                title: Text(d.istituto),

                subtitle: Text(

                  "Rata € ${d.rata.toStringAsFixed(2)}",

                ),

              ),

            ),

          const SizedBox(height: 30),

          ElevatedButton(

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) => const VerificationPage(),

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