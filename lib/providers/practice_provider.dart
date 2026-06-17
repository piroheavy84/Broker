import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/applicant.dart';
import '../models/debt.dart';
import '../models/mortgage.dart';
import '../models/practice.dart';

class PracticeNotifier extends StateNotifier<Practice> {
  PracticeNotifier()
      : super(
          Practice(
            id: "",
            dataCreazione: DateTime.now(),
            richiedenti: [],
            mortgage: null,
            debts: const [],
            note: "",
          ),
        );

  // ==========================
  // RICHIEDENTI
  // ==========================

  void addApplicant(Applicant applicant) {
    state = Practice(
      id: state.id,
      dataCreazione: state.dataCreazione,
      richiedenti: [...state.richiedenti, applicant],
      mortgage: state.mortgage,
      debts: state.debts,
      note: state.note,
    );
  }

  void removeApplicant(int index) {
    final lista = [...state.richiedenti];
    lista.removeAt(index);

    state = Practice(
      id: state.id,
      dataCreazione: state.dataCreazione,
      richiedenti: lista,
      mortgage: state.mortgage,
      debts: state.debts,
      note: state.note,
    );
  }

  // ==========================
  // MUTUO
  // ==========================

  void setMortgage(Mortgage mortgage) {
    state = Practice(
      id: state.id,
      dataCreazione: state.dataCreazione,
      richiedenti: state.richiedenti,
      mortgage: mortgage,
      debts: state.debts,
      note: state.note,
    );
  }

  // ==========================
  // DEBITI
  // ==========================

  void addDebt(Debt debt) {
    state = Practice(
      id: state.id,
      dataCreazione: state.dataCreazione,
      richiedenti: state.richiedenti,
      mortgage: state.mortgage,
      debts: [...state.debts, debt],
      note: state.note,
    );
  }

  void removeDebt(int index) {
    final lista = [...state.debts];
    lista.removeAt(index);

    state = Practice(
      id: state.id,
      dataCreazione: state.dataCreazione,
      richiedenti: state.richiedenti,
      mortgage: state.mortgage,
      debts: lista,
      note: state.note,
    );
  }

  // ==========================
  // NOTE
  // ==========================

  void setNote(String note) {
    state = Practice(
      id: state.id,
      dataCreazione: state.dataCreazione,
      richiedenti: state.richiedenti,
      mortgage: state.mortgage,
      debts: state.debts,
      note: note,
    );
  }

  // ==========================
  // RESET PRATICA
  // ==========================

  void resetPractice() {
    state = Practice(
      id: "",
      dataCreazione: DateTime.now(),
      richiedenti: [],
      mortgage: null,
      debts: const [],
      note: "",
    );
  }
}

final practiceProvider =
    StateNotifierProvider<PracticeNotifier, Practice>((ref) {
  return PracticeNotifier();
});