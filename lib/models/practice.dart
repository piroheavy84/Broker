import 'applicant.dart';
import 'mortgage.dart';
import 'debt.dart';

class Practice {

  final String id;

  final DateTime dataCreazione;

  final List<Applicant> richiedenti;

  final Mortgage? mortgage;

  final List<Debt> debts;

  final String note;

  const Practice({

    required this.id,

    required this.dataCreazione,

    required this.richiedenti,

    this.mortgage,

    this.debts = const [],

    this.note = "",

  });

}