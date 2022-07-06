import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:barometer/barometer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _barometerPlugin = Barometer();

  double _reading = 0.0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = "QWERTY";
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      // platformVersion =
      //     await _barometerPlugin.getPlatformVersion() ?? 'Unknown platform version';
      await _barometerPlugin.initializeBarometer();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Latest reading: $_reading\n'),
              ElevatedButton(
                  onPressed: () async {
                    final reading = await _barometerPlugin.getReading();
                    setState(() {
                      _reading = reading ?? 1.0;
                    });
                  },
                  child: const Text("Get Latest Reading")),
              StreamBuilder<dynamic>(
                  stream: _barometerPlugin.getPressureStream(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return Text("PRESSURE STREAM: ${snapshot.data!}");
                    }

                    return const Text("NO DATA");
                  })
            ],
          ),
        ),
      ),
    );
  }
}
