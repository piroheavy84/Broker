import 'services/broker_api.dart';

Future<void> testBackend(

  dynamic pratica,

) async {

  final result =

      await BrokerApi.search(

    pratica,

  );

  print(result);

}