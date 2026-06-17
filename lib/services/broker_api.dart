import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/practice.dart';
import '../models/mortgage.dart';

class BrokerApi {

  static Future<Map<String, dynamic>> search(

    Practice pratica,

  ) async {

    final mortgage = pratica.mortgage!;

    String finalita = "ACQUISTO";

    switch (mortgage.finalita) {

      case MortgagePurpose.acquistoPrimaCasa:
      case MortgagePurpose.acquistoSecondaCasa:
        finalita = "ACQUISTO";
        break;

      case MortgagePurpose.surroga:
        finalita = "SURROGA";
        break;

      case MortgagePurpose.liquidita:
        finalita = "LIQUIDITA";
        break;

      case MortgagePurpose.ristrutturazione:
        finalita = "RISTRUTTURAZIONE";
        break;

      case MortgagePurpose.costruzione:
        finalita = "COSTRUZIONE";
        break;

      case MortgagePurpose.consolidamentoDebiti:
        finalita = "CONSOLIDAMENTO";
        break;

    }

    String tasso = "FISSO";

    switch (mortgage.tipoTasso) {

      case MortgageRateType.fisso:
        tasso = "FISSO";
        break;

      case MortgageRateType.variabile:
        tasso = "VARIABILE";
        break;

    }

    final response = await http.post(

      Uri.parse(

        "http://127.0.0.1:8000/search",

      ),

      headers: {

        "Content-Type": "application/json",

      },

      body: jsonEncode(

        {

          "finalita": finalita,

          "tasso": tasso,

          "durata": mortgage.durata,

          "importo": mortgage.importoRichiesto,

          "valore": mortgage.valoreImmobile,

        },

      ),

    );

    return jsonDecode(

      response.body,

    );

  }

}