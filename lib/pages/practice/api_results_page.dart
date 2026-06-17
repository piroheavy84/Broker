import 'package:flutter/material.dart';

class ApiResultsPage extends StatelessWidget {
  final Map<String, dynamic> response;

  const ApiResultsPage({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final migliore = response["migliore"];

    final prodotti =
        response["prodotti"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Broker Engine",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: ListView(
          children: [

            const Text(
              "🏆 MIGLIORE OFFERTA",
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            if (migliore != null)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                          15),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      Text(
                        "Banca: ${migliore["banca"]}",
                      ),

                      Text(
                        "Listino: ${migliore["listino"]}",
                      ),

                      Text(
                        "Spread: ${migliore["spread"]}",
                      ),

                      Text(
                        "Durata: ${migliore["durata"]}",
                      ),

                      Text(
                        "LTV: ${migliore["ltv"]}",
                      ),

                      Text(
                        "PDF: ${migliore["pdf"]}",
                      ),

                      Text(
                        "Pagina: ${migliore["pagina"]}",
                      ),

                    ],
                  ),
                ),
              ),

            const SizedBox(
              height: 30,
            ),

            Text(
              "ALTRE SOLUZIONI (${prodotti.length})",
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            ...prodotti.map(
              (p) => Card(
                child: ListTile(
                  leading:
                      const Icon(
                    Icons.account_balance,
                  ),
                  title: Text(
                    p["banca"],
                  ),
                  subtitle: Text(
                    "${p["listino"]}   |   ${p["spread"]}",
                  ),
                  trailing: Text(
                    p["durata"],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}