import 'package:flutter/material.dart';

class BankFormPage extends StatelessWidget {

  const BankFormPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Nuova Banca"),

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: ListView(

          children: [

            const TextField(

              decoration: InputDecoration(

                labelText: "Nome banca",

              ),

            ),

            const SizedBox(height:20),

            ElevatedButton(

              onPressed: (){

              },

              child: const Text(

                "Carica PDF Principale",

              ),

            ),

            const SizedBox(height:10),

            ElevatedButton(

              onPressed: (){

              },

              child: const Text(

                "Carica PDF Sussistenza",

              ),

            ),

            const SizedBox(height:20),

            const TextField(

              decoration: InputDecoration(

                labelText: "Rapporto rata/reddito",

              ),

            ),

            const SizedBox(height:15),

            const TextField(

              decoration: InputDecoration(

                labelText: "Età massima",

              ),

            ),

            const SizedBox(height:15),

            const TextField(

              decoration: InputDecoration(

                labelText: "Istruttoria %",

              ),

            ),

            const SizedBox(height:15),

            const TextField(

              decoration: InputDecoration(

                labelText: "Perizia €",

              ),

            ),

            const SizedBox(height:15),

            const TextField(

              decoration: InputDecoration(

                labelText: "Provvigione massima %",

              ),

            ),

            const SizedBox(height:30),

            ElevatedButton(

              onPressed: (){

              },

              child: const Text(

                "SALVA BANCA",

              ),

            ),

          ],

        ),

      ),

    );

  }

}