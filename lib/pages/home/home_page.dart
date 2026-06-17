import 'package:flutter/material.dart';

import '../practice/client_page.dart';
import '../admin/banks_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget menuCard(
    BuildContext context,
    IconData icon,
    String titolo,
    String sottotitolo,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          size: 35,
        ),
        title: Text(
          titolo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(sottotitolo),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Kiron Broker Engine"),

        centerTitle: true,

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: ListView(

          children: [

            const SizedBox(height: 20),

            const Text(

              "Benvenuto",

              style: TextStyle(

                fontSize: 30,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 30),

            menuCard(

              context,

              Icons.add_circle,

              "Nuova Pratica",

              "Inserisci una nuova richiesta di mutuo",

              () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => const ClientPage(),

                  ),

                );

              },

            ),

            menuCard(

              context,

              Icons.people,

              "Archivio Clienti",

              "Pratiche salvate",

              () {

              },

            ),

            menuCard(

              context,

              Icons.account_balance,

              "Gestione Banche",

              "Importazione PDF e configurazione",

              () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => const BanksPage(),

                  ),

                );

              },

            ),

            menuCard(

              context,

              Icons.description,

              "Archivio Preventivi",

              "Preventivi salvati",

              () {

              },

            ),

            menuCard(

              context,

              Icons.settings,

              "Impostazioni",

              "Configurazione applicazione",

              () {

              },

            ),

          ],

        ),

      ),

    );

  }

}