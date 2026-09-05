enum ContractType {
  indeterminato,
  determinato,
  autonomo,
}

enum GeographicArea {
  nord,
  centro,
  sud,
}

class Applicant {

  final String nome;
  final String cognome;
  final String residenza;
  final GeographicArea area;
  final String regione;
  final String provincia;
  final String tipoCentro;
  final DateTime dataNascita;
  final String nazionalita;
  final int anniItalia;
  final String statoCivile;
  final ContractType contratto;
  final double reddito;
  final int figli;

  const Applicant({
    required this.nome,
    required this.cognome,
    required this.residenza,
    required this.area,
    required this.regione,
    required this.provincia,
    this.tipoCentro = "",
    required this.dataNascita,
    required this.nazionalita,
    required this.anniItalia,
    required this.statoCivile,
    required this.contratto,
    required this.reddito,
    required this.figli,
  });

  Applicant copyWith({
    String? nome,
    String? cognome,
    String? residenza,
    GeographicArea? area,
    String? regione,
    String? provincia,
    String? tipoCentro,
    DateTime? dataNascita,
    String? nazionalita,
    int? anniItalia,
    String? statoCivile,
    ContractType? contratto,
    double? reddito,
    int? figli,
  }) {
    return Applicant(
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      residenza: residenza ?? this.residenza,
      area: area ?? this.area,
      regione: regione ?? this.regione,
      provincia: provincia ?? this.provincia,
      tipoCentro: tipoCentro ?? this.tipoCentro,
      dataNascita: dataNascita ?? this.dataNascita,
      nazionalita: nazionalita ?? this.nazionalita,
      anniItalia: anniItalia ?? this.anniItalia,
      statoCivile: statoCivile ?? this.statoCivile,
      contratto: contratto ?? this.contratto,
      reddito: reddito ?? this.reddito,
      figli: figli ?? this.figli,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nome": nome,
      "cognome": cognome,
      "residenza": residenza,
      "area": area.name,
      "regione": regione,
      "provincia": provincia,
      "tipo_centro": tipoCentro,
      "dataNascita": dataNascita.toIso8601String(),
      "nazionalita": nazionalita,
      "anniItalia": anniItalia,
      "statoCivile": statoCivile,
      "contratto": contratto.name,
      "reddito": reddito,
      "figli": figli,
      "persone_a_carico": figli,
    };
  }

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      nome: json["nome"],
      cognome: json["cognome"],
      residenza: json["residenza"],
      area: GeographicArea.values.firstWhere(
        (e) => e.name == json["area"],
      ),
      regione: (json["regione"] ?? "").toString(),
      provincia: (json["provincia"] ?? "").toString(),
      tipoCentro: (json["tipo_centro"] ?? json["tipoCentro"] ?? "").toString(),
      dataNascita: DateTime.parse(json["dataNascita"]),
      nazionalita: json["nazionalita"],
      anniItalia: json["anniItalia"],
      statoCivile: json["statoCivile"],
      contratto: ContractType.values.firstWhere(
        (e) => e.name == json["contratto"],
      ),
      reddito: (json["reddito"] as num).toDouble(),
      figli: json["figli"],
    );
  }
}