import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../service/service.dart';
class LoggerService {
  static Future<void> log(String message) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Unknown';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = "${iosInfo.name} ${iosInfo.model}";
      }
      final packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      await HttpService.sendLogs({
        "message": message,
        "device": deviceName,
        "appVersion": version,
        "timestamp": DateTime.now().toIso8601String(),
      });
      print("[LOG][$deviceName][v$version] $message");
    } catch (e) {
      print("LoggerService failed: $e");
    }
  }
}
