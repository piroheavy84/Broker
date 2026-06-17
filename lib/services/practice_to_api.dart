import '../models/mortgage.dart';
import '../providers/practice_provider.dart';

class PracticeToApi {

  static Map<String, dynamic> convert(
    dynamic pratica,
  ) {

    final mortgage = pratica.mortgage;

    String finalita = "ACQUISTO";

    switch (mortgage.finalita) {

      case MortgagePurpose.acquistoPrimaCasa:
      case MortgagePurpose.acquistoSecondaCasa:
        finalita = "ACQUISTO";
        break;

      case MortgagePurpose.surroga:
        finalita = "SURROGA";
        break;

      case MortgagePurpose.liquidita:
        finalita = "LIQUIDITA";
        break;

      case MortgagePurpose.ristrutturazione:
        finalita = "RISTRUTTURAZIONE";
        break;

      case MortgagePurpose.costruzione:
        finalita = "COSTRUZIONE";
        break;

      case MortgagePurpose.consolidamentoDebiti:
        finalita = "CONSOLIDAMENTO";
        break;

    }

    String tasso = "FISSO";

    switch (mortgage.tipoTasso) {

      case MortgageRateType.fisso:
        tasso = "FISSO";
        break;

      case MortgageRateType.variabile:
        tasso = "VARIABILE";
        break;

    }

    return {

      "finalita": finalita,

      "tasso": tasso,

      "durata": mortgage.durata,

      "importo": mortgage.importoRichiesto,

      "valore": mortgage.valoreImmobile,

    };

  }

}