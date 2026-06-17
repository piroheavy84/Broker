import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/age_engine.dart';
import '../../engine/income_engine.dart';
import '../../engine/ltv_engine.dart';
import '../../engine/search_engine.dart';
import '../../engine/sussistenza_engine.dart';
import '../../providers/practice_provider.dart';
import 'results_page.dart';

class VerificationPage extends ConsumerWidget {

  const VerificationPage({super.key});

  Widget buildCheck(
    String titolo,
    bool ok,
  ) {

    return Card(

      child: ListTile(

        leading: Icon(

          ok
              ? Icons.check_circle
              : Icons.cancel,

          color:
              ok
                  ? Colors.green
                  : Colors.red,

        ),

        title: Text(titolo),

      ),

    );

  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final pratica =
        ref.watch(practiceProvider);

    final richiedentiOk =
        pratica.richiedenti.isNotEmpty;

    final mutuoOk =
        pratica.mortgage != null;

    final debitiOk = true;

    bool etaOk = true;

    bool anniItaliaOk = true;

    bool redditoOk = true;

    bool sussistenzaOk = true;

    bool ltvOk = true;

    bool finalitaOk = true;

    if (mutuoOk) {

      final mortgage =
          pratica.mortgage!;

      final ltv =
          LtvEngine.calcolaLTV(

        mortgage.importoRichiesto,

        mortgage.valoreImmobile,

      );

      ltvOk = ltv <= 100;

      for (final r
          in pratica.richiedenti) {

        if (!AgeEngine.verificaEtaMassima(

          r,

          mortgage.durata,

          80,

        )) {

          etaOk = false;

        }

        if (r.nazionalita !=
                "Italiana" &&
            r.anniItalia < 2) {

          anniItaliaOk = false;

        }

      }

      double redditoTotale = 0;

      for (final r
          in pratica.richiedenti) {

        redditoTotale +=
            r.reddito;

      }

      double rateTotali = 0;

      for (final d
          in pratica.debts) {

        rateTotali +=
            d.rata;

      }

      final rataMax =
          IncomeEngine.rataMassima(

        redditoTotale,

        35,

      );

      redditoOk =
          rateTotali <= rataMax;

      sussistenzaOk =
          SussistenzaEngine.verifica(

        redditoTotale,

        rateTotali,

        1000,

      );

    }

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "Verifica Pratica",

        ),

      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: ListView(

          children: [

            buildCheck(
              "Richiedenti",
              richiedentiOk,
            ),

            buildCheck(
              "Mutuo",
              mutuoOk,
            ),

            buildCheck(
              "Debiti",
              debitiOk,
            ),

            buildCheck(
              "Età finanziabile",
              etaOk,
            ),

            buildCheck(
              "Anni in Italia",
              anniItaliaOk,
            ),

            buildCheck(
              "Rapporto rata/reddito",
              redditoOk,
            ),

            buildCheck(
              "Sussistenza",
              sussistenzaOk,
            ),

            buildCheck(
              "LTV",
              ltvOk,
            ),

            buildCheck(
              "Classe energetica",
              true,
            ),

            buildCheck(
              "Finalità",
              finalitaOk,
            ),

            const SizedBox(
              height: 30,
            ),

            ElevatedButton(

              onPressed: () {

                final risultati =
                    SearchEngine.ricerca(

                  pratica: pratica,

                  indiceMercato: 2.35,

                );

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        ResultsPage(

                      risultati:
                          risultati,

                    ),

                  ),

                );

              },

              child: const Text(

                "CALCOLA PRODOTTI",

              ),

            ),

          ],

        ),

      ),

    );

  }

}