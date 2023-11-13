import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';

class AmpqWriter {
  /// Not working a.t.m - lost connection
  sendAmpqMessage(Map<String, String> message) async {
    ConnectionSettings settings = ConnectionSettings(
      host: "host",
      virtualHost: "vhost",
      port: 5672,
      authProvider: const PlainAuthenticator(
          "user", "pass"),
    );
    Client client = Client(settings: settings);
    Channel channel = await client.channel();
    Exchange exchange = await channel.exchange("logs", ExchangeType.DIRECT);
    exchange.publish(message, null);
    client.close();
  }

  runPythonScriptToSendAmpqMessage(String message) async {
    var shell = Shell();
    debugPrint(message);
    await shell.run("python ./scripts/amqp_script.py '$message'");
  }
}
