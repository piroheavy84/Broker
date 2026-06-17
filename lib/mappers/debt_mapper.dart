import '../models/debt.dart';

class DebtMapper {

  static Debt create({

    required int richiedente,
    required String istituto,
    required double rata,
    required double residuo,
    required DebtType tipologia,

  }) {

    return Debt(

      richiedente: richiedente,

      istituto: istituto,

      rata: rata,

      residuo: residuo,

      tipologia: tipologia,

    );

  }

}