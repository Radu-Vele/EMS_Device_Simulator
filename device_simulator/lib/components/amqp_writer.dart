import 'package:dart_amqp/dart_amqp.dart';
import 'package:process_run/shell.dart';

class AmpqWriter {
  /// Not working a.t.m - unable to conect to Server
  sendAmpqMessage(Map<String, String> message) async {
    ConnectionSettings settings = ConnectionSettings(
        host:
            "hostname",
        authProvider: const PlainAuthenticator(
            "user", "pass"));
    Client client = Client(settings: settings);
    Channel channel = await client.channel();
    Exchange exchange = await channel.exchange("logs", ExchangeType.FANOUT);
    exchange.publish(message.toString(), null);
    client.close();
  }

  runPythonScriptToSendAmpqMessage(Map<String, String> message) async {
    var shell = Shell();
    await shell.run("python ./scripts/amqp_script.py \"$message\"");
  }
}
