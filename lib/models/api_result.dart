class ApiResult {

  final bool success;

  final int numeroProdotti;

  final double ltv;

  final Map<String, dynamic>? migliore;

  final List<dynamic> prodotti;

  ApiResult({

    required this.success,

    required this.numeroProdotti,

    required this.ltv,

    required this.migliore,

    required this.prodotti,

  });

  factory ApiResult.fromJson(

    Map<String, dynamic> json,

  ) {

    return ApiResult(

      success: json["success"],

      numeroProdotti:

          json["numero_prodotti"],

      ltv:

          (json["ltv"] as num).toDouble(),

      migliore: json["migliore"],

      prodotti: json["prodotti"],

    );

  }

}