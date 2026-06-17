import '../models/bank.dart';

class PdfImportService {

  Future<Bank> importaBanca({

    required String nomeBanca,

  }) async {

    // In futuro qui leggeremo il PDF

    return Bank(

      nome: nomeBanca,

      rapportoRataReddito: 0.35,

      etaMassima: 80,

      istruttoriaPercentuale: 1,

      perizia: 300,

      provvigioneMassima: 3,

      sussistenza: 1200,

      prodotti: const [],

    );

  }

}