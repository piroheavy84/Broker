import '../models/practice.dart';
import 'age_engine.dart';
import 'income_engine.dart';
import 'sussistenza_engine.dart';

// ==========================================================
//
// BANK ENGINE
//
// Scopo:
// Verificare se una pratica può essere presa in carico
// dalla banca prima della ricerca dei prodotti.
//
// Controlli effettuati:
//
// ✔ Presenza richiedenti
// ✔ Presenza mutuo
// ✔ Rapporto rata/reddito
// ✔ Sussistenza
// ✔ Età massima a fine mutuo
//
// NON controlla:
//
// ✘ LTV
// ✘ Finalità
// ✘ Durata
// ✘ Classe energetica
// ✘ Tipo immobile
// ✘ Tipo tasso
// ✘ Validità prodotto
//
// Tutti questi controlli vengono eseguiti
// successivamente dal ProductSearchEngine.
//
// Versione: V1.0
//
// ==========================================================

class BankEngine {

  static bool verificaPratica({

    required Practice pratica,

    required double rapportoRataReddito,

    required double sussistenza,

    required int etaMassima,

  }) {

    //----------------------------
    // Verifica presenza richiedenti
    //----------------------------

    if (pratica.richiedenti.isEmpty) {
      return false;
    }

    //----------------------------
    // Verifica presenza mutuo
    //----------------------------

    if (pratica.mortgage == null) {
      return false;
    }

    //----------------------------
    // Calcolo reddito totale
    //----------------------------

    double redditoTotale = 0;

    for (final r in pratica.richiedenti) {
      redditoTotale += r.reddito;
    }

    //----------------------------
    // Calcolo rate esistenti
    //----------------------------

    double rateTotali = 0;

    for (final d in pratica.debts) {
      rateTotali += d.rata;
    }

    //----------------------------
    // Verifica rapporto rata/reddito
    //----------------------------

    final rataMassima = IncomeEngine.rataMassima(
      redditoTotale,
      rapportoRataReddito,
    );

    if (rateTotali > rataMassima) {
      return false;
    }

    //----------------------------
    // Verifica sussistenza
    //----------------------------

    if (!SussistenzaEngine.verifica(
      redditoTotale,
      rateTotali,
      sussistenza,
    )) {
      return false;
    }

    //----------------------------
    // Il controllo LTV NON viene
    // effettuato qui.
    //
    // Sarà eseguito dal
    // ProductSearchEngine sul
    // singolo prodotto bancario.
    //----------------------------

    //----------------------------
    // Verifica età massima
    //----------------------------

    for (final r in pratica.richiedenti) {

      if (!AgeEngine.verificaEtaMassima(
        r,
        pratica.mortgage!.durata,
        etaMassima,
      )) {

        return false;

      }

    }

    //----------------------------

    return true;

  }

}

// ==========================================================
//
// TODO FUTURI
//
// - Gestione Fondo Consap
// - Gestione garanti
// - Gestione coobbligati
// - Gestione deroghe banca
// - Gestione pratiche estero
// - Gestione eccezioni commerciali
//
// ==========================================================