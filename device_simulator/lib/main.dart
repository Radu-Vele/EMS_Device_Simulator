import 'dart:ffi';

import 'package:device_simulator/components/csv_file_reader.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy MS Device Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Energy MS Device Simulator 📡'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _simulationRunning = false;

  String _deviceId = '';
  final TextEditingController _deviceIdController = TextEditingController();
  String _deviceIdError = '';

  int _offset = 0;
  final TextEditingController _offsetController = TextEditingController();
  String _offsetError = '';

  CsvFileReader fr = CsvFileReader();

  String _logText = '';

  void updateLog(String text) {
    setState(() => _logText = '$_logText\n$text');
  }

  void _toggleSimulation() {
    if (!_simulationRunning) {
      setState(() {
        _deviceId = _deviceIdController.text.trim();
      });

      if (_offsetController.text != "") {
        int? parsedInt = int.tryParse(_offsetController.text.trim());
        if (parsedInt != null) {
          setState(() {
            _offset = parsedInt;
          });
          _offsetError = '';
        } else {
          setState(() {
            _offsetError = "Must imput a valid number (default is 0)";
          });
        }
      }

      if (_deviceId == '') {
        setState(() {
          _deviceIdError = "Invalid device Id - empty";
        });
      } else {
        _deviceIdError = "";
        setState(() {
          _simulationRunning = true;
        });
        _logText = 'Sent messages:';
        fr.readOneEntryPeriodically(5, _deviceId, _offset, updateLog);
        fr.setKeepReading(true);
      }
    } else {
      fr.stopAndReinitStream();
      setState(() {
        _simulationRunning = false;
        _deviceId = '';
        _deviceIdController.text = '';
        _offset = 0;
        _offsetController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16.0),
            Container(
              width: 500,
              child: TextField(
                controller: _deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Device ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_deviceIdError.isNotEmpty)
              Text(
                _deviceIdError,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),
            Container(
              width: 400,
              child: TextField(
                controller: _offsetController,
                decoration: const InputDecoration(
                  labelText:
                      'Enter the offset in the data source file (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_offsetError.isNotEmpty)
              Text(
                _offsetError,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),
            Text(
              'Press the button below to start the simulation',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            FloatingActionButton(
              onPressed: _toggleSimulation,
              tooltip: 'Toggle Simulation',
              child: _simulationRunning
                  ? const Icon(Icons.pause_rounded)
                  : const Icon(Icons.play_arrow),
            ),
            const SizedBox(height: 16.0),
            Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      _logText,
                      style: const TextStyle(fontSize: 16),
                    ))),
          ],
        ),
      ),
    );
  }
}
