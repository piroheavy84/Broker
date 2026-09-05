import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/practice.dart';
import '../models/mortgage.dart';

class BrokerApi {
  static const String baseUrl = "http://127.0.0.1:8000";

  static String pdfUrl(String pdfName) {
    return "$baseUrl/pdf/${Uri.encodeComponent(pdfName)}";
  }

  static String quoteUrl(String filename) {
    return "$baseUrl/quotes/${Uri.encodeComponent(filename)}";
  }

  static Future<Map<String, dynamic>> search(
    Practice pratica,
  ) async {
    final mortgage = pratica.mortgage!;

    final String finalita = mortgage.finalita.normalizedCode;

    final String tipologiaImmobile =
        mortgage.tipologia.normalizedCode;

    String tasso = "FISSO";

    switch (mortgage.tipoTasso) {
      case MortgageRateType.fisso:
        tasso = "FISSO";
        break;
      case MortgageRateType.variabile:
        tasso = "VARIABILE";
        break;
    }

    final redditoMensile = pratica.richiedenti.fold<double>(
      0,
      (totale, richiedente) => totale + richiedente.reddito,
    );

    final response = await http.post(
      Uri.parse("$baseUrl/search"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "finalita": finalita,
        "tipologia_immobile": tipologiaImmobile,
        "tasso": tasso,
        "durata": mortgage.durata,
        "importo": mortgage.importoRichiesto,
        "valore": mortgage.valoreImmobile,
        "valore_perizia": mortgage.valorePerizia,
        "classe_energetica": mortgage.classeEnergetica,
        "reddito_mensile": redditoMensile,
        "richiedenti": pratica.richiedenti
            .map((r) => {
                  "nome": r.nome,
                  "cognome": r.cognome,
                  "data_nascita": r.dataNascita.toIso8601String(),
                  "reddito": r.reddito,
                  "nazionalita": r.nazionalita,
                  "anni_italia": r.anniItalia,
                  "area": r.area.name,
                  "regione": r.regione,
                  "provincia": r.provincia,
                  "tipo_centro": r.tipoCentro,
                  "figli": r.figli,
            "persone_a_carico": r.figli,
                })
            .toList(),
        "debiti": pratica.debts
            .map((d) => {
                  "rata": d.rata,
                  "residuo": d.residuo,
                  "istituto": d.istituto,
                })
            .toList(),
        "data_rogito": mortgage.dataRogito?.toIso8601String() ?? "",
        "polizza_vita_euro": mortgage.polizzaVitaEuro,
        "polizza_vita_rateizzata": mortgage.polizzaVitaRateizzata,
        "polizza_lavoro_euro": mortgage.polizzaLavoroEuro,
        "polizza_lavoro_rateizzata": mortgage.polizzaLavoroRateizzata,
        "polizza_vita_lavoro_euro": mortgage.polizzaVitaLavoroEuro,
        "polizza_vita_lavoro_rateizzata": mortgage.polizzaVitaLavoroRateizzata,
        "polizza_scoppio_incendio_euro": mortgage.polizzaScoppioIncendioEuro,
        "polizza_scoppio_incendio_compenso_euro": mortgage.polizzaScoppioIncendioCompensoEuro,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getRates() async {
    final response = await http.get(
      Uri.parse("$baseUrl/rates"),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getBanks() async {
    final response = await http.get(
      Uri.parse("$baseUrl/banks"),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getBankMemory(
    String banca,
  ) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/banks/memory/${Uri.encodeComponent(banca)}",
      ),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getClients() async {
    final response = await http.get(
      Uri.parse("$baseUrl/clients"),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getQuotes() async {
    final response = await http.get(
      Uri.parse("$baseUrl/quotes"),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateManualIrs(
    String text,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/rates/irs/manual"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> importBankPdf({
    required String banca,
    required bool tassoEsplicito,
    required double periziaEuro,
    required double impostaSostitutivaPercentuale,
    required double istruttoriaPercentuale,
    required double istruttoriaMinimo,
    required double istruttoriaMassimo,
    required String calcoloDebito,
    required double rapportoRataRedditoPercentuale,
    required int etaMassimaFinanziabile,
    required int anniResidenzaItaliaStraniero,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/banks/import-pdf"),
    );

    request.fields["banca"] = banca;
    request.fields["tasso_esplicito"] = tassoEsplicito.toString();
    request.fields["perizia_euro"] = periziaEuro.toString();
    request.fields["imposta_sostitutiva_percentuale"] =
        impostaSostitutivaPercentuale.toString();
    request.fields["istruttoria_percentuale"] =
        istruttoriaPercentuale.toString();
    request.fields["istruttoria_minimo"] = istruttoriaMinimo.toString();
    request.fields["istruttoria_massimo"] = istruttoriaMassimo.toString();
    request.fields["calcolo_debito"] = calcoloDebito;
    request.fields["rapporto_rata_reddito_percentuale"] =
        rapportoRataRedditoPercentuale.toString();
    request.fields["eta_massima_finanziabile"] =
        etaMassimaFinanziabile.toString();
    request.fields["anni_residenza_italia_straniero"] =
        anniResidenzaItaliaStraniero.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        fileBytes,
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getBankSussistenza(String banca) async {
    final response = await http.get(
      Uri.parse("$baseUrl/banks/sussistenza/${Uri.encodeComponent(banca)}"),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> saveBankSussistenza({
    required String banca,
    required Map<String, dynamic> soglie,
    required Map<String, dynamic> incrementoOltre5,
    String fonte = "MANUALE",
    String tipoGeografia = "AREA",
    String struttura = "SEMPLICE",
    Map<String, dynamic> matrice = const {},
    Map<String, dynamic> dimensioni = const {},
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/banks/sussistenza"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "banca": banca,
        "soglie": soglie,
        "incremento_oltre_5": incrementoOltre5,
        "fonte": fonte,
        "tipo_geografia": tipoGeografia,
        "struttura": struttura,
        "matrice": matrice,
        "dimensioni": dimensioni,
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception(response.body);
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> uploadBankSussistenzaFile({
    required String banca,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/banks/sussistenza/upload"),
    );

    request.fields["banca"] = banca;
    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        fileBytes,
        filename: fileName,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 400) {
      throw Exception(response.body);
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deferBankSussistenza(
    String banca,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/banks/sussistenza/defer"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"banca": banca}),
    );

    if (response.statusCode >= 400) {
      throw Exception(response.body);
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> analyzeBankSussistenza(
    String banca,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/banks/sussistenza/analyze/${Uri.encodeComponent(banca)}"),
    );
    if (response.statusCode >= 400) {
      throw Exception(response.body);
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> confirmBankSussistenzaInterpretation({
    required String banca,
    required String tipoGeografia,
    required Map<String, dynamic> soglie,
    required Map<String, dynamic> incrementoOltre5,
    String struttura = 'SEMPLICE',
    Map<String, dynamic> matrice = const {},
    Map<String, dynamic> dimensioni = const {},
  }) async {
    return saveBankSussistenza(
      banca: banca,
      soglie: soglie,
      incrementoOltre5: incrementoOltre5,
      fonte: 'FILE_INTERPRETATO_CONFERMATO',
      tipoGeografia: tipoGeografia,
      struttura: struttura,
      matrice: matrice,
      dimensioni: dimensioni,
    );
  }

  static Future<Map<String, dynamic>> verifyBankImport({
    required String banca,
    required String pdfPath,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/banks/verify-import"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "banca": banca,
        "pdf_path": pdfPath,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> confirmMemoryPhrases({
    required String banca,
    required List<String> phrases,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/banks/memory/confirm-phrases"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "banca": banca,
        "phrases": phrases,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> confirmMemoryFields({
    required String banca,
    required Map<String, dynamic> fields,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/banks/memory/confirm-fields"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "banca": banca,
        "fields": fields,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> confirmMemoryCategory({
    required String banca,
    required String category,
    required List<String> phrases,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/banks/memory/confirm-category"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "banca": banca,
        "category": category,
        "phrases": phrases,
      }),
    );

    return jsonDecode(response.body);
  }


  static Future<Map<String, dynamic>> createTechnicalReportPdf({
    required Map<String, dynamic> pratica,
    required List<Map<String, dynamic>> prodotti,
    Map<String, dynamic>? migliore,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reports/technical-pdf"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pratica": pratica,
        "prodotti": prodotti,
        "migliore": migliore,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createQuotePdf({
    required Map<String, dynamic> cliente,
    required Map<String, dynamic> pratica,
    required List<Map<String, dynamic>> prodotti,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/quotes/pdf"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cliente": cliente,
        "pratica": pratica,
        "prodotti": prodotti,
      }),
    );

    return jsonDecode(response.body);
  }
}