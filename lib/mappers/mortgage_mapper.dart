import '../models/mortgage.dart';

class MortgageMapper {

  static Mortgage create({

    required MortgagePurpose finalita,
    required PropertyType tipologia,
    required String classe,
    required double valore,
    required double importo,
    required int durata,
    required MortgageRateType tipo,
    required double irs,
    required double euribor,
    required DateTime? rogito,

  }) {

    return Mortgage(

      finalita: finalita,

      tipologia: tipologia,

      classeEnergetica: classe,

      valoreImmobile: valore,

      importoRichiesto: importo,

      durata: durata,

      tipoTasso: tipo,

      irs: irs,

      euribor: euribor,

      dataRogito: rogito,

    );

  }

}