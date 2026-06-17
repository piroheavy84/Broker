import '../models/applicant.dart';

class ApplicantMapper {

  static Applicant create({

    required String nome,
    required String cognome,
    required String residenza,
    required GeographicArea area,
    required DateTime dataNascita,
    required String nazionalita,
    required int anniItalia,
    required String statoCivile,
    required ContractType contratto,
    required double reddito,
    required int figli,

  }) {

    return Applicant(

      nome: nome,

      cognome: cognome,

      residenza: residenza,

      area: area,

      dataNascita: dataNascita,

      nazionalita: nazionalita,

      anniItalia: anniItalia,

      statoCivile: statoCivile,

      contratto: contratto,

      reddito: reddito,

      figli: figli,

    );

  }

}