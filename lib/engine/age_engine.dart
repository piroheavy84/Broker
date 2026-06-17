import '../models/applicant.dart';

class AgeEngine {

  static int calcolaEta(DateTime nascita) {

    final oggi = DateTime.now();

    int eta = oggi.year - nascita.year;

    if (oggi.month < nascita.month) {
      eta--;
    }

    if (oggi.month == nascita.month &&
        oggi.day < nascita.day) {
      eta--;
    }

    return eta;
  }

  static bool verificaEtaMassima(

    Applicant applicant,

    int durata,

    int etaMassima,

  ) {

    final eta = calcolaEta(applicant.dataNascita);

    return eta + durata <= etaMassima;

  }

}