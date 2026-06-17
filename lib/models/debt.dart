enum DebtType {
  mutuo,
  prestitoPersonale,
  cessioneQuinto,
  leasing,
  cartaRateale,
  altro,
}

class Debt {

  final int richiedente;

  final String istituto;

  final double rata;

  final double residuo;

  final DebtType tipologia;

  const Debt({

    required this.richiedente,

    required this.istituto,

    required this.rata,

    required this.residuo,

    required this.tipologia,

  });

}