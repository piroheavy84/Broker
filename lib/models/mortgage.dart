enum MortgagePurpose {
  acquistoPrimaCasa,
  acquistoSecondaCasa,
  surroga,
  liquidita,
  ristrutturazione,
  costruzione,
  consolidamentoDebiti,
}

enum PropertyType {
  primaCasa,
  secondaCasa,
  commerciale,
  terreno,
  nessunImmobile,
}

enum MortgageRateType {
  fisso,
  variabile,
}

class Mortgage {
  final MortgagePurpose finalita;

  final PropertyType tipologia;

  final String classeEnergetica;

  final double valoreImmobile;

  final double importoRichiesto;

  final int durata;

  final MortgageRateType tipoTasso;

  final double irs;

  final double euribor;

  final DateTime? dataRogito;

  const Mortgage({
    required this.finalita,
    required this.tipologia,
    required this.classeEnergetica,
    required this.valoreImmobile,
    required this.importoRichiesto,
    required this.durata,
    required this.tipoTasso,
    required this.irs,
    required this.euribor,
    required this.dataRogito,
  });

  Mortgage copyWith({
    MortgagePurpose? finalita,
    PropertyType? tipologia,
    String? classeEnergetica,
    double? valoreImmobile,
    double? importoRichiesto,
    int? durata,
    MortgageRateType? tipoTasso,
    double? irs,
    double? euribor,
    DateTime? dataRogito,
  }) {
    return Mortgage(
      finalita: finalita ?? this.finalita,
      tipologia: tipologia ?? this.tipologia,
      classeEnergetica:
          classeEnergetica ?? this.classeEnergetica,
      valoreImmobile:
          valoreImmobile ?? this.valoreImmobile,
      importoRichiesto:
          importoRichiesto ?? this.importoRichiesto,
      durata: durata ?? this.durata,
      tipoTasso: tipoTasso ?? this.tipoTasso,
      irs: irs ?? this.irs,
      euribor: euribor ?? this.euribor,
      dataRogito: dataRogito ?? this.dataRogito,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "finalita": finalita.name,
      "tipologia": tipologia.name,
      "classeEnergetica": classeEnergetica,
      "valoreImmobile": valoreImmobile,
      "importoRichiesto": importoRichiesto,
      "durata": durata,
      "tipoTasso": tipoTasso.name,
      "irs": irs,
      "euribor": euribor,
      "dataRogito": dataRogito?.toIso8601String(),
    };
  }

  factory Mortgage.fromJson(
    Map<String, dynamic> json,
  ) {
    return Mortgage(
      finalita: MortgagePurpose.values.firstWhere(
        (e) => e.name == json["finalita"],
      ),
      tipologia: PropertyType.values.firstWhere(
        (e) => e.name == json["tipologia"],
      ),
      classeEnergetica: json["classeEnergetica"],
      valoreImmobile:
          (json["valoreImmobile"] as num).toDouble(),
      importoRichiesto:
          (json["importoRichiesto"] as num).toDouble(),
      durata: json["durata"],
      tipoTasso: MortgageRateType.values.firstWhere(
        (e) => e.name == json["tipoTasso"],
      ),
      irs: (json["irs"] as num).toDouble(),
      euribor: (json["euribor"] as num).toDouble(),
      dataRogito: json["dataRogito"] == null
          ? null
          : DateTime.parse(json["dataRogito"]),
    );
  }
}