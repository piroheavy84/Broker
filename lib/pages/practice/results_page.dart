import 'package:flutter/material.dart';

import '../../models/search_result.dart';

class ResultsPage extends StatelessWidget {

  final List<SearchResult> risultati;

  const ResultsPage({

    super.key,

    required this.risultati,

  });

  Widget resultCard(

    SearchResult r,

  ) {

    return Card(

      margin: const EdgeInsets.only(

        bottom: 15,

      ),

      elevation: 3,

      child: Padding(

        padding: const EdgeInsets.all(15),

        child: Column(

          crossAxisAlignment:

              CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Icon(

                  Icons.account_balance,

                  color: r.semaforoVerde

                      ? Colors.green

                      : Colors.red,

                ),

                const SizedBox(

                  width: 10,

                ),

                Expanded(

                  child: Text(

                    r.banca.nome,

                    style: const TextStyle(

                      fontSize: 22,

                      fontWeight:

                          FontWeight.bold,

                    ),

                  ),

                ),

              ],

            ),

            const Divider(),

            Text(

              "Prodotto: ${r.prodotto.nomeProdotto}",

            ),

            Text(

              "Importo finanziato: € ${r.importoFinanziato.toStringAsFixed(2)}",

            ),

            Text(

              "LTV: ${r.ltv.toStringAsFixed(2)}%",

            ),

            Text(

              "Spread: ${r.spread.toStringAsFixed(2)}%",

            ),

            Text(

              "Indice: ${r.indice.toStringAsFixed(2)}%",

            ),

            Text(

              "Tasso finito: ${r.tassoFinito.toStringAsFixed(2)}%",

            ),
                        Text(
              "Rata: € ${r.rata.toStringAsFixed(2)}",
            ),

            Text(
              "Retrocessione: € ${r.retrocessioneEuro.toStringAsFixed(2)}",
            ),

            Text(
              "Istruttoria: € ${r.istruttoriaEuro.toStringAsFixed(2)}",
            ),

            Text(
              "Perizia: € ${r.periziaEuro.toStringAsFixed(2)}",
            ),

            const SizedBox(
              height: 15,
            ),

            Row(

              children: [

                Icon(

                  r.semaforoVerde
                      ? Icons.check_circle
                      : Icons.cancel,

                  color:
                      r.semaforoVerde
                          ? Colors.green
                          : Colors.red,

                ),

                const SizedBox(
                  width: 8,
                ),

                Text(

                  r.semaforoVerde
                      ? "Semaforo Verde"
                      : "Semaforo Rosso",

                  style: TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    color:
                        r.semaforoVerde
                            ? Colors.green
                            : Colors.red,

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }

  @override

  Widget build(

    BuildContext context,

  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "Risultati Ricerca",

        ),

      ),

      body: Padding(

        padding: const EdgeInsets.all(

          20,

        ),

        child: risultati.isEmpty
                    ? const Center(

                child: Text(

                  "Nessun prodotto compatibile trovato.",

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight: FontWeight.bold,

                  ),

                ),

              )

            : ListView.builder(

                itemCount: risultati.length,

                itemBuilder: (

                  context,

                  index,

                ) {

                  return resultCard(

                    risultati[index],

                  );

                },

              ),

      ),

    );

  }

}