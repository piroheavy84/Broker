enum MortgagePurpose {
  acquistoPrimaCasa,
  acquistoSecondaCasa,
  acquistoRistrutturazione,
  sostituzione,
  sostituzioneRistrutturazione,
  surroga,
  rifinanziamento,
  liquidita,
  ristrutturazione,
  costruzione,
  consolidamentoDebiti,
  dismissioniEnasarco,
}

extension MortgagePurposeExtension on MortgagePurpose {
  String get normalizedCode {
    switch (this) {
      case MortgagePurpose.acquistoPrimaCasa:
      case MortgagePurpose.acquistoSecondaCasa:
        return "ACQUISTO";
      case MortgagePurpose.acquistoRistrutturazione:
        return "ACQUISTO_RISTRUTTURAZIONE";
      case MortgagePurpose.sostituzione:
        return "SOSTITUZIONE";
      case MortgagePurpose.sostituzioneRistrutturazione:
        return "SOSTITUZIONE_RISTRUTTURAZIONE";
      case MortgagePurpose.surroga:
        return "SURROGA";
      case MortgagePurpose.rifinanziamento:
        return "RIFINANZIAMENTO";
      case MortgagePurpose.liquidita:
        return "LIQUIDITA";
      case MortgagePurpose.ristrutturazione:
        return "RISTRUTTURAZIONE";
      case MortgagePurpose.costruzione:
        return "COSTRUZIONE";
      case MortgagePurpose.consolidamentoDebiti:
        return "CONSOLIDAMENTO";
      case MortgagePurpose.dismissioniEnasarco:
        return "DISMISSIONI_ENASARCO";
    }
  }

  String get displayLabel {
    switch (this) {
      case MortgagePurpose.acquistoPrimaCasa:
        return "Acquisto Prima Casa";
      case MortgagePurpose.acquistoSecondaCasa:
        return "Acquisto Seconda Casa";
      case MortgagePurpose.acquistoRistrutturazione:
        return "Acquisto + Ristrutturazione";
      case MortgagePurpose.sostituzione:
        return "Sostituzione";
      case MortgagePurpose.sostituzioneRistrutturazione:
        return "Sostituzione + Ristrutturazione";
      case MortgagePurpose.surroga:
        return "Surroga";
      case MortgagePurpose.rifinanziamento:
        return "Rifinanziamento";
      case MortgagePurpose.liquidita:
        return "Liquidità";
      case MortgagePurpose.ristrutturazione:
        return "Ristrutturazione";
      case MortgagePurpose.costruzione:
        return "Costruzione";
      case MortgagePurpose.consolidamentoDebiti:
        return "Consolidamento Debiti";
      case MortgagePurpose.dismissioniEnasarco:
        return "Dismissioni Enasarco";
    }
  }
}

extension PropertyTypeExtension on PropertyType {
  String get normalizedCode {
    switch (this) {
      case PropertyType.primaCasa:
        return "PRIMA_CASA";
      case PropertyType.secondaCasa:
        return "SECONDA_CASA";
      case PropertyType.commerciale:
        return "COMMERCIALE";
      case PropertyType.terreno:
        return "TERRENO";
      case PropertyType.nessunImmobile:
        return "NESSUN_IMMOBILE";
    }
  }
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

  final double? valorePerizia;

  final double importoRichiesto;

  final int durata;

  final MortgageRateType tipoTasso;

  final double irs;

  final double euribor;

  final DateTime? dataRogito;

  final double polizzaVitaEuro;

  final bool polizzaVitaRateizzata;

  final double polizzaLavoroEuro;

  final bool polizzaLavoroRateizzata;

  final double polizzaVitaLavoroEuro;

  final bool polizzaVitaLavoroRateizzata;

  final double polizzaScoppioIncendioEuro;

  final double polizzaScoppioIncendioCompensoEuro;

  const Mortgage({
    required this.finalita,
    required this.tipologia,
    required this.classeEnergetica,
    required this.valoreImmobile,
    required this.valorePerizia,
    required this.importoRichiesto,
    required this.durata,
    required this.tipoTasso,
    required this.irs,
    required this.euribor,
    required this.dataRogito,
    this.polizzaVitaEuro = 0,
    this.polizzaVitaRateizzata = false,
    this.polizzaLavoroEuro = 0,
    this.polizzaLavoroRateizzata = false,
    this.polizzaVitaLavoroEuro = 0,
    this.polizzaVitaLavoroRateizzata = false,
    this.polizzaScoppioIncendioEuro = 0,
    this.polizzaScoppioIncendioCompensoEuro = 0,
  });

  Mortgage copyWith({
    MortgagePurpose? finalita,
    PropertyType? tipologia,
    String? classeEnergetica,
    double? valoreImmobile,
    double? valorePerizia,
    double? importoRichiesto,
    int? durata,
    MortgageRateType? tipoTasso,
    double? irs,
    double? euribor,
    DateTime? dataRogito,
    double? polizzaVitaEuro,
    bool? polizzaVitaRateizzata,
    double? polizzaLavoroEuro,
    bool? polizzaLavoroRateizzata,
    double? polizzaVitaLavoroEuro,
    bool? polizzaVitaLavoroRateizzata,
    double? polizzaScoppioIncendioEuro,
    double? polizzaScoppioIncendioCompensoEuro,
  }) {
    return Mortgage(
      finalita: finalita ?? this.finalita,
      tipologia: tipologia ?? this.tipologia,
      classeEnergetica:
          classeEnergetica ?? this.classeEnergetica,
      valoreImmobile:
          valoreImmobile ?? this.valoreImmobile,
      valorePerizia:
          valorePerizia ?? this.valorePerizia,
      importoRichiesto:
          importoRichiesto ?? this.importoRichiesto,
      durata: durata ?? this.durata,
      tipoTasso: tipoTasso ?? this.tipoTasso,
      irs: irs ?? this.irs,
      euribor: euribor ?? this.euribor,
      dataRogito: dataRogito ?? this.dataRogito,
      polizzaVitaEuro: polizzaVitaEuro ?? this.polizzaVitaEuro,
      polizzaVitaRateizzata: polizzaVitaRateizzata ?? this.polizzaVitaRateizzata,
      polizzaLavoroEuro: polizzaLavoroEuro ?? this.polizzaLavoroEuro,
      polizzaLavoroRateizzata: polizzaLavoroRateizzata ?? this.polizzaLavoroRateizzata,
      polizzaVitaLavoroEuro: polizzaVitaLavoroEuro ?? this.polizzaVitaLavoroEuro,
      polizzaVitaLavoroRateizzata: polizzaVitaLavoroRateizzata ?? this.polizzaVitaLavoroRateizzata,
      polizzaScoppioIncendioEuro: polizzaScoppioIncendioEuro ?? this.polizzaScoppioIncendioEuro,
      polizzaScoppioIncendioCompensoEuro: polizzaScoppioIncendioCompensoEuro ?? this.polizzaScoppioIncendioCompensoEuro,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "finalita": finalita.name,
      "tipologia": tipologia.name,
      "classeEnergetica": classeEnergetica,
      "valoreImmobile": valoreImmobile,
      "valorePerizia": valorePerizia,
      "importoRichiesto": importoRichiesto,
      "durata": durata,
      "tipoTasso": tipoTasso.name,
      "irs": irs,
      "euribor": euribor,
      "dataRogito": dataRogito?.toIso8601String(),
      "polizzaVitaEuro": polizzaVitaEuro,
      "polizzaVitaRateizzata": polizzaVitaRateizzata,
      "polizzaLavoroEuro": polizzaLavoroEuro,
      "polizzaLavoroRateizzata": polizzaLavoroRateizzata,
      "polizzaVitaLavoroEuro": polizzaVitaLavoroEuro,
      "polizzaVitaLavoroRateizzata": polizzaVitaLavoroRateizzata,
      "polizzaScoppioIncendioEuro": polizzaScoppioIncendioEuro,
      "polizzaScoppioIncendioCompensoEuro": polizzaScoppioIncendioCompensoEuro,
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
      valorePerizia: json["valorePerizia"] == null
          ? null
          : (json["valorePerizia"] as num).toDouble(),
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
      polizzaVitaEuro: ((json["polizzaVitaEuro"] ?? 0) as num).toDouble(),
      polizzaVitaRateizzata: json["polizzaVitaRateizzata"] ?? false,
      polizzaLavoroEuro: ((json["polizzaLavoroEuro"] ?? 0) as num).toDouble(),
      polizzaLavoroRateizzata: json["polizzaLavoroRateizzata"] ?? false,
      polizzaVitaLavoroEuro: ((json["polizzaVitaLavoroEuro"] ?? 0) as num).toDouble(),
      polizzaVitaLavoroRateizzata: json["polizzaVitaLavoroRateizzata"] ?? false,
      polizzaScoppioIncendioEuro: ((json["polizzaScoppioIncendioEuro"] ?? 0) as num).toDouble(),
      polizzaScoppioIncendioCompensoEuro: ((json["polizzaScoppioIncendioCompensoEuro"] ?? 0) as num).toDouble(),
    );
  }
}