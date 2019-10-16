import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:mock_web_server/mock_web_server.dart';

import 'package:blockcypher/blockcypher.dart';

MockWebServer server;
Client wsClient;
Client httpClient;

void main() {
  setUp(() async {
    server = MockWebServer();
    await server.start();
    wsClient = Client.websocket("ws://${server.host}:${server.port}/ws", "token");
    httpClient = Client.http(server.url, "token");
  });

  tearDown(() async {
    server.shutdown();
  });

  test("initialize", () {
    expect(wsClient, isNotNull);
    expect(wsClient.url.host, "127.0.0.1");
  });

  test("blockchain()", () async {
    var cannedResponse = await File('test/files/blockchain.json').readAsString();
		server.enqueue(body: cannedResponse);
		String blockchain = await httpClient.blockchain();
		expect(json.decode(blockchain)['name'], 'BTC.main');
  });

  test("transactionConfirmation()", () async {
    var cannedResponse = await File('test/files/transaction_conf.json').readAsString();
    server.enqueue(body: cannedResponse);
    Stream<String> tx = wsClient.transactionConfirmation('some-txhash');
    tx.listen(expectAsync1((message) {}, count: 1));
  });

  test("newBlocks()", () async {
    var cannedResponse = await File('test/files/block.json').readAsString();
    server.enqueue(body: cannedResponse);
    Stream<String> blocks = wsClient.newBlocks();
    blocks.listen(expectAsync1((message) { }, count: 1));
  });

  test("unconfirmedTransactions()", () async {
    var tx1 = await File('test/files/P2PKH.json').readAsString();
    var tx2 = await File('test/files/P2WPKH.json').readAsString();
    server.messageGenerator = (StreamSink sink) async {
      sink.add(tx1);
      sink.add(tx2);
    };

    Stream<String> blocks = wsClient.unconfirmedTransactions();
    blocks.listen(expectAsync1((message) { }, count: 2));
  });
}
