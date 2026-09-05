import 'package:flutter/material.dart';

class ApplicantCard extends StatelessWidget {

  final int numero;

  const ApplicantCard({
    super.key,
    required this.numero,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.only(bottom: 20),

      child: Padding(

        padding: const EdgeInsets.all(15),

        child: Column(

          children: [

            Text(

              "Richiedente $numero",

              style: const TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height:20),

            TextField(

              decoration: const InputDecoration(

                labelText: "Nome",

              ),

            ),

            const SizedBox(height:12),

            TextField(

              decoration: const InputDecoration(

                labelText: "Cognome",

              ),

            ),

            const SizedBox(height:12),

            TextField(

              decoration: const InputDecoration(

                labelText: "Residenza",

              ),

            ),

            const SizedBox(height:12),

            TextField(

              decoration: const InputDecoration(

                labelText: "Data di nascita",

              ),

            ),

            const SizedBox(height:12),

            TextField(

              decoration: const InputDecoration(

                labelText: "Nazionalità",

              ),

            ),

            const SizedBox(height:12),

            TextField(

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Reddito netto",

              ),

            ),

            const SizedBox(height:12),

            TextField(

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Persone a carico",

              ),

            ),

          ],

        ),

      ),

    );

  }

}