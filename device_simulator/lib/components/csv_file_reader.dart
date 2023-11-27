import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_simulator/components/amqp_writer.dart';
import 'package:path_provider/path_provider.dart';

class CsvFileReader {
  bool _keepReading = false;
  int _readLines = 0;
  AmpqWriter ampqWriter = AmpqWriter();

  Future<File> get _inputFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/flutter/sensor.csv");
  }

  setKeepReading(bool value) {
    _keepReading = value;
  }

  stopAndReinitStream() {
    _keepReading = false;
    _readLines = 0;
  }

  readOneEntryPeriodically(int periodSec, String deviceId, int offset,
      Function(String) updateLog) async {
    _readLines = offset;
    Timer.periodic(Duration(seconds: periodSec), (timer) async {
      if (!_keepReading) {
        timer.cancel();
        return;
      }
      Stream<List<int>> inputStream = (await _inputFile).openRead();
      inputStream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .skip(_readLines)
          .take(1)
          .forEach((line) async {
        _readLines++;
        await ampqWriter.sendAmpqMessage(formatMessage(deviceId, line));
        updateLog(formatMessage(deviceId, line));
      });
      if (!_keepReading) {
        timer.cancel();
        return;
      }
    });
  }

  String formatMessage(deviceId, readValue) {
    Map<String, String> messageMap = {
      'timestamp': (DateTime.now().millisecondsSinceEpoch).toString(),
      'device_id': deviceId,
      'measurement_value': readValue.toString(),
    };
    return jsonEncode(messageMap);
  }
}
