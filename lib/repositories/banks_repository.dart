import '../models/bank.dart';

// ==========================================================
//
// BANKS REPOSITORY
//
// Repository in memoria delle banche caricate
// nel sistema.
//
// Contiene:
//
// - elenco banche
// - prodotti
// - parametri di ricerca
//
// In V2.0 sarà sostituito da un database
// persistente (SQLite / Cloud).
//
// Versione: V1.0
//
// ==========================================================

class BanksRepository {

  static final List<Bank> _banks = [];

  static void addBank(Bank bank) {

    _banks.add(bank);

  }

  static List<Bank> getBanks() {

    return _banks;

  }

  static void removeBank(Bank bank) {

    _banks.remove(bank);

  }

  static void clear() {

    _banks.clear();

  }

}

// ==========================================================
//
// TODO V2.0
//
// - Salvataggio SQLite
// - Sincronizzazione Cloud
// - Versionamento listini
// - Cache locale
//
// ==========================================================