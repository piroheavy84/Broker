import 'package:kiron_broker_engine/models/bank.dart';

class SearchResult {
  final Bank banca;

  final BankProduct prodotto;

  final double importoFinanziato;

  final double ltv;

  final double spread;

  final double indice;

  final double tassoFinito;

  final double rata;

  final double retrocessioneEuro;

  final double istruttoriaEuro;

  final double periziaEuro;

  final bool semaforoVerde;

  const SearchResult({
    required this.banca,
    required this.prodotto,
    required this.importoFinanziato,
    required this.ltv,
    required this.spread,
    required this.indice,
    required this.tassoFinito,
    required this.rata,
    required this.retrocessioneEuro,
    required this.istruttoriaEuro,
    required this.periziaEuro,
    required this.semaforoVerde,
  });
}