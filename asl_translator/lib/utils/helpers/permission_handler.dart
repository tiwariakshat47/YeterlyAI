import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionHandler {
  // Check if this is the first time launch
  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = !prefs.containsKey('first_launch');
    if (isFirst) {
      await prefs.setBool('first_launch', true);
    }
    return isFirst;
  }

  // Check if user has accepted the agreement
  static Future<bool> hasAcceptedAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('agreement_accepted') ?? false;
  }

  // Mark agreement as accepted
  static Future<void> markAgreementAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreement_accepted', true);
  }

  // Check and request required permissions
  static Future<bool> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    return statuses[Permission.camera]!.isGranted &&
        statuses[Permission.storage]!.isGranted;
  }

  // Mark permissions as checked
  static Future<void> markPermissionsChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_checked', true);
  }

  // Check if permissions have been checked before
  static Future<bool> havePermissionsBeenChecked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('permissions_checked') ?? false;
  }

  // Reset all preferences (useful for testing or account deletion)
  static Future<void> resetAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check individual permission status
  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> isStoragePermissionGranted() async {
    return await Permission.storage.isGranted;
  }

  // Request individual permissions
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}