import 'package:blockcypher/blockcypher.dart';

void main(List<String> args) async {
  var token = args[0];
  var client =
      Client.websocket("wss://socket.blockcypher.com/v1/btc/main", token);

  Stream<String> confs = await client
      .transactionConfirmation("737ead59ffa50566334ca2323195696f0bb32800f604b516792fa210eb6e0733");
  await for (String conf in confs) {
    print(conf);
  }
}