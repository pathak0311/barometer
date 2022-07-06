import 'barometer_platform_interface.dart';

class Barometer {
  Future<String?> getPlatformVersion() {
    return BarometerPlatform.instance.getPlatformVersion();
  }

  Future<double?> getReading() {
    return BarometerPlatform.instance.getReading();
  }

  Future<bool?> initializeBarometer() {
    return BarometerPlatform.instance.initializeBarometer();
  }

  Stream<double> getPressureStream() {
    return BarometerPlatform.instance.getPressureStream();
  }
}
