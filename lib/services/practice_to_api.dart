import '../models/mortgage.dart';
import '../providers/practice_provider.dart';

class PracticeToApi {

  static Map<String, dynamic> convert(
    dynamic pratica,
  ) {

    final mortgage = pratica.mortgage;

    final String finalita = mortgage.finalita.normalizedCode;

    final String tipologiaImmobile =
        mortgage.tipologia.normalizedCode;

    String tasso = "FISSO";

    switch (mortgage.tipoTasso) {

      case MortgageRateType.fisso:
        tasso = "FISSO";
        break;

      case MortgageRateType.variabile:
        tasso = "VARIABILE";
        break;

    }

    final redditoMensile = pratica.richiedenti.fold<double>(
      0,
      (totale, richiedente) => totale + richiedente.reddito,
    );

    return {

      "finalita": finalita,

      "tipologia_immobile": tipologiaImmobile,

      "tasso": tasso,

      "durata": mortgage.durata,

      "importo": mortgage.importoRichiesto,

      "valore": mortgage.valoreImmobile,

      "valore_perizia": mortgage.valorePerizia,

      "classe_energetica": mortgage.classeEnergetica,

      "reddito_mensile": redditoMensile,

      "data_rogito": mortgage.dataRogito?.toIso8601String() ?? "",

    };

  }

}