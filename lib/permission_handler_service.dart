
import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

enum AppPermissionStatus {
  authorized,
  limited,
  denied,
  permanentlyDenied,
  unknown
}

class PermissionHandlerService {
  final StreamController<AppPermissionStatus> _statusController = StreamController.broadcast();
  Stream<AppPermissionStatus> get onStatusChanged => _statusController.stream;

  PermissionHandlerService() {
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final status = await _getMappedPermissionStatus();
    _statusController.add(status);
  }

  Future<AppPermissionStatus> _getMappedPermissionStatus() async {
    final photoStatus = await PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption());
    if (photoStatus == PermissionState.authorized) {
      return AppPermissionStatus.authorized;
    }
    if (photoStatus == PermissionState.limited) {
      return AppPermissionStatus.limited;
    }
    // If not authorized or limited, check with permission_handler for more details
    final preciseStatus = await handler.Permission.photos.status;
    if (preciseStatus == handler.PermissionStatus.denied) {
      return AppPermissionStatus.denied;
    }
    if (preciseStatus == handler.PermissionStatus.permanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    }
    return AppPermissionStatus.unknown;
  }

  Future<void> requestPermission() async {
    await PhotoManager.requestPermissionExtend();
    await _checkCurrentStatus();
  }

  Future<void> openAppSettings() async {
    await handler.openAppSettings();
  }

  void refreshStatus() {
    _checkCurrentStatus();
  }

  void dispose() {
    _statusController.close();
  }
}
