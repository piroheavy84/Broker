import '../models/practice.dart';
import '../models/applicant.dart';
import '../models/mortgage.dart';
import '../models/debt.dart';

class PracticeService {

  static Practice nuovaPratica() {

    return Practice(

      id: DateTime.now().millisecondsSinceEpoch.toString(),

      dataCreazione: DateTime.now(),

      richiedenti: const [],

      mortgage: null,

      debts: const [],

      note: "",

    );

  }

  static Practice aggiungiRichiedente(

    Practice pratica,

    Applicant applicant,

  ) {

    return Practice(

      id: pratica.id,

      dataCreazione: pratica.dataCreazione,

      richiedenti: [...pratica.richiedenti, applicant],

      mortgage: pratica.mortgage,

      debts: pratica.debts,

      note: pratica.note,

    );

  }

  static Practice aggiornaMutuo(

    Practice pratica,

    Mortgage mortgage,

  ) {

    return Practice(

      id: pratica.id,

      dataCreazione: pratica.dataCreazione,

      richiedenti: pratica.richiedenti,

      mortgage: mortgage,

      debts: pratica.debts,

      note: pratica.note,

    );

  }

  static Practice aggiungiDebito(

    Practice pratica,

    Debt debt,

  ) {

    return Practice(

      id: pratica.id,

      dataCreazione: pratica.dataCreazione,

      richiedenti: pratica.richiedenti,

      mortgage: pratica.mortgage,

      debts: [...pratica.debts, debt],

      note: pratica.note,

    );

  }

}