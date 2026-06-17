import '../models/bank.dart';
import '../models/practice.dart';
import 'ltv_engine.dart';

class ProductSearchEngine {

  static List<BankProduct> cerca({

    required Practice pratica,

    required List<Bank> banche,

  }) {

    List<BankProduct> risultati = [];

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

        //--------------------------------
        // LTV
        //--------------------------------

        if (ltv > prodotto.ltvMassimo) {
          continue;
        }

        //--------------------------------
        // Durata
        //--------------------------------

        if (mortgage.durata > prodotto.durataMassima) {
          continue;
        }

        //--------------------------------
        // Data validità
        //--------------------------------

        if (DateTime.now().isAfter(prodotto.validita)) {
          continue;
        }

        //--------------------------------
        // Se supera tutti i controlli
        //--------------------------------

        risultati.add(prodotto);

      }

    }

    return risultati;

  }

}