import 'services/broker_api.dart';

void provaApi() async {

  final result = await BrokerApi.search(

    finalita: "ACQUISTO",

    tasso: "FISSO",

    durata: 23,

    importo: 170000,

    valore: 250000,

  );

  print(result);

}