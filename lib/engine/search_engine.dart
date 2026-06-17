import '../repositories/banks_repository.dart';
import '../models/practice.dart';
import '../models/search_result.dart';
import 'bank_engine.dart';
import 'results_engine.dart';

class SearchEngine {

  static List<SearchResult> ricerca({

    required Practice pratica,

    required double indiceMercato,

  }) {

    List<SearchResult> risultati = [];

    final banche = BanksRepository.getBanks();

    for (final banca in banche) {

      final praticaValida = BankEngine.verificaPratica(

        pratica: pratica,

        rapportoRataReddito: banca.rapportoRataReddito,

        sussistenza: banca.sussistenza,

        etaMassima: banca.etaMassima,

      );

      if (!praticaValida) {
        continue;
      }

      risultati.addAll(

        ResultsEngine.genera(

          pratica: pratica,

          banche: [banca],

          indiceMercato: indiceMercato,

        ),

      );

    }

    risultati.sort(

      (a, b) => a.rata.compareTo(b.rata),

    );

    return risultati;

  }

}