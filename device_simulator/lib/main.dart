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
  CsvFileReader fr = CsvFileReader();

  void _toggleSimulation() {
    if (!_simulationRunning) {
      setState(() {
        _deviceId = _deviceIdController.text.trim();
      });

      if (_deviceId == '') {
        debugPrint("Invalid device Id - empty");
      } else {
        debugPrint("Started simulation with id $_deviceId");
        setState(() {
          _simulationRunning = true;
        });

        fr.readOneEntryPeriodically(5, _deviceId);
        fr.setKeepReading(true);
      }
    } else {
      fr.stopAndReinitStream();
      setState(() {
        _simulationRunning = false;
        _deviceId = '';
        _deviceIdController.text = '';
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
          ],
        ),
      ),
    );
  }
}
