import 'package:flutter/material.dart';

import '../../repositories/banks_repository.dart';

class BanksPage extends StatelessWidget {

  const BanksPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Gestione Banche"),

      ),

      body: ListView.builder(

        itemCount: BanksRepository.getBanks().length,

        itemBuilder: (context,index){

          final banca = BanksRepository.getBanks()[index];

          return Card(

            child: ListTile(

              leading: const Icon(

                Icons.account_balance,

              ),

              title: Text(

                banca.nome,

              ),

            ),

          );

        },

      ),

      floatingActionButton: FloatingActionButton(

        child: const Icon(Icons.add),

        onPressed: (){

        },

      ),

    );

  }

}