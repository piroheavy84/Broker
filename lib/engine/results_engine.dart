import 'dart:math';
import '../models/bank.dart';
import '../models/practice.dart';
import '../models/search_result.dart';
import 'ltv_engine.dart';

class ResultsEngine {

  static List<SearchResult> genera({

    required Practice pratica,

    required List<Bank> banche,

    required double indiceMercato,

  }) {

    List<SearchResult> risultati = [];

    if (pratica.mortgage == null) {
      return risultati;
    }

    final mortgage = pratica.mortgage!;

    final ltv = LtvEngine.calcolaLTV(
      mortgage.importoRichiesto,
      mortgage.valoreImmobile,
    );

    for (final banca in banche) {

      for (final prodotto in banca.prodotti) {

        //-----------------------------------
        // Controllo LTV
        //-----------------------------------

        if (ltv > prodotto.ltvMassimo) {
          continue;
        }

        //-----------------------------------
        // Controllo durata
        //-----------------------------------

        if (mortgage.durata > prodotto.durataMassima) {
          continue;
        }

        //-----------------------------------
        // Controllo validità
        //-----------------------------------

        if (DateTime.now().isAfter(prodotto.validita)) {
          continue;
        }

        //-----------------------------------
        // Tasso finito
        //-----------------------------------

        final tassoFinito =
            indiceMercato + prodotto.spread;

        //-----------------------------------
// Calcolo rata ammortamento francese
//-----------------------------------

final r =
    tassoFinito / 100 / 12;

final n =
    mortgage.durata * 12;

final rata =
    mortgage.importoRichiesto *
    (r /
        (1 -
            (1 /
                pow(
                  1 + r,
                  n,
                ))));

        //-----------------------------------
        // Retrocessione
        //-----------------------------------

        final retrocessioneEuro =
            mortgage.importoRichiesto *
            prodotto.retrocessione /
            100;

        //-----------------------------------
        // Istruttoria
        //-----------------------------------

        final istruttoriaEuro =
            mortgage.importoRichiesto *
            banca.istruttoriaPercentuale /
            100;

        //-----------------------------------

        risultati.add(

          SearchResult(

            banca: banca,

            prodotto: prodotto,

            importoFinanziato:
                mortgage.importoRichiesto,

            ltv: ltv,

            spread: prodotto.spread,

            indice: indiceMercato,

            tassoFinito: tassoFinito,

            rata: rata,

            retrocessioneEuro:
                retrocessioneEuro,

            istruttoriaEuro:
                istruttoriaEuro,

            periziaEuro:
                banca.perizia,

            semaforoVerde: true,

          ),

        );

      }

    }

    risultati.sort(

      (a, b) => a.rata.compareTo(b.rata),

    );

    return risultati;

  }

}