import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_simulator/components/amqp_writer.dart';
import 'package:flutter/material.dart';

class CsvFileReader {
  bool _keepReading = false;
  final File _inputFile = File("./input/sensor.csv");
  int _readLines = 0;
  AmpqWriter ampqWriter = AmpqWriter();

  setKeepReading(bool value) {
    _keepReading = value;
  }

  stopAndReinitStream() {
    _keepReading = false;
    _readLines = 0;
  }

  readOneEntryPeriodically(int periodSec, String deviceId, int offset, Function(String) updateLog) async {
    _readLines = offset;
    Timer.periodic(Duration(seconds: periodSec), (timer) {
      if (!_keepReading) {
        timer.cancel();
      }
      Stream<List<int>> inputStream = _inputFile.openRead();
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
