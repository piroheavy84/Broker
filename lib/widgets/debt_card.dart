import 'package:flutter/material.dart';

class DebtCard extends StatefulWidget {

  final int numero;

  const DebtCard({
    super.key,
    required this.numero,
  });

  @override
  State<DebtCard> createState() => _DebtCardState();

}

class _DebtCardState extends State<DebtCard> {

  final istitutoController =
      TextEditingController();

  final rataController =
      TextEditingController();

  final residuoController =
      TextEditingController();

  String richiedente = "Richiedente 1";

  String tipologia = "Prestito Personale";

  @override
  void dispose() {

    istitutoController.dispose();

    rataController.dispose();

    residuoController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.only(bottom: 20),

      elevation: 3,

      child: Padding(

        padding: const EdgeInsets.all(15),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              "Debito ${widget.numero}",

              style: const TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(

              value: richiedente,

              decoration:
                  const InputDecoration(

                labelText: "Richiedente",

              ),

              items: const [

                DropdownMenuItem(
                  value: "Richiedente 1",
                  child:
                      Text("Richiedente 1"),
                ),

                DropdownMenuItem(
                  value: "Richiedente 2",
                  child:
                      Text("Richiedente 2"),
                ),

                DropdownMenuItem(
                  value: "Richiedente 3",
                  child:
                      Text("Richiedente 3"),
                ),

              ],

              onChanged: (v) {

                setState(() {

                  richiedente = v!;

                });

              },

            ),

            const SizedBox(height: 15),

            TextField(

              controller:
                  istitutoController,

              decoration:
                  const InputDecoration(

                labelText: "Istituto",

              ),

            ),

            const SizedBox(height: 15),

            TextField(

              controller: rataController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText:
                    "Rata Mensile (€)",

              ),

            ),

            const SizedBox(height: 15),

            TextField(

              controller:
                  residuoController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText:
                    "Capitale Residuo (€)",

              ),

            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(

              value: tipologia,

              decoration:
                  const InputDecoration(

                labelText: "Tipologia",

              ),

              items: const [

                DropdownMenuItem(
                  value:
                      "Prestito Personale",
                  child: Text(
                      "Prestito Personale"),
                ),

                DropdownMenuItem(
                  value: "Mutuo",
                  child: Text("Mutuo"),
                ),

                DropdownMenuItem(
                  value:
                      "Cessione Quinto",
                  child: Text(
                      "Cessione Quinto"),
                ),

                DropdownMenuItem(
                  value: "Leasing",
                  child:
                      Text("Leasing"),
                ),

                DropdownMenuItem(
                  value:
                      "Carta Rateale",
                  child: Text(
                      "Carta Rateale"),
                ),

                DropdownMenuItem(
                  value: "Altro",
                  child:
                      Text("Altro"),
                ),

              ],

              onChanged: (v) {

                setState(() {

                  tipologia = v!;

                });

              },

            ),

          ],

        ),

      ),

    );

  }

}