class Bank {

  final String nome;

  final double rapportoRataReddito;

  final int etaMassima;

  final double istruttoriaPercentuale;

  final double perizia;

  final double provvigioneMassima;

  final double sussistenza;

  final List<BankProduct> prodotti;

  const Bank({

    required this.nome,

    required this.rapportoRataReddito,

    required this.etaMassima,

    required this.istruttoriaPercentuale,

    required this.perizia,

    required this.provvigioneMassima,

    required this.sussistenza,

    required this.prodotti,

  });

}

class BankProduct {

  final String nomeProdotto;

  final String finalita;

  final String tipoImmobile;

  final String tipoTasso;

  final double ltvMassimo;

  final int durataMassima;

  final String classeEnergetica;

  final double spread;

  final double retrocessione;

  final DateTime validita;

  const BankProduct({

    required this.nomeProdotto,

    required this.finalita,

    required this.tipoImmobile,

    required this.tipoTasso,

    required this.ltvMassimo,

    required this.durataMassima,

    required this.classeEnergetica,

    required this.spread,

    required this.retrocessione,

    required this.validita,

  });

}