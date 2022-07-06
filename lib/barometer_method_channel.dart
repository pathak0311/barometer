import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'barometer_platform_interface.dart';

/// An implementation of [BarometerPlatform] that uses method channels.
class MethodChannelBarometer extends BarometerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('barometer');
  final eventChannel = const EventChannel('pressureStream');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<double?> getReading() async {
    final reading = await methodChannel.invokeMethod<double>('getReading');
    return reading;
  }

  @override
  Future<bool?> initializeBarometer() async {
    final initialized =
        await methodChannel.invokeMethod<bool>('initializeBarometer');
    return initialized;
  }

  @override
  Stream<double> getPressureStream() {
    final pressureStream = eventChannel.receiveBroadcastStream().distinct().map<double>((value) => value);
    return pressureStream;
  }
}
