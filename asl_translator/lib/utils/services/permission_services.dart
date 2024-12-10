import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static Future<bool> requestPermissions() async {
    final camera = await Permission.camera.request();
    final storage = await Permission.storage.request();

    return camera.isGranted && storage.isGranted;
  }

  static Future<void> markPermissionsChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_checked', true);
  }
}
