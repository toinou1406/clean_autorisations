
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;

enum AppPermissionStatus {
  unknown,
  denied,
  authorized,
  limited,
  permanentlyDenied;

  factory AppPermissionStatus.from(perm_handler.PermissionStatus status) {
    switch (status) {
      case perm_handler.PermissionStatus.denied:
        return AppPermissionStatus.denied;
      case perm_handler.PermissionStatus.granted:
        return AppPermissionStatus.authorized;
      case perm_handler.PermissionStatus.limited:
        return AppPermissionStatus.limited;
      case perm_handler.PermissionStatus.restricted:
        return AppPermissionStatus.permanentlyDenied;
      case perm_handler.PermissionStatus.permanentlyDenied:
        return AppPermissionStatus.permanentlyDenied;
      // The 'provisional' status (for iOS push notifications) is not relevant for photo access.
      // We can treat it as 'denied' if it ever occurs.
      case perm_handler.PermissionStatus.provisional:
        return AppPermissionStatus.denied;
    }
  }
}

class PermissionHandlerService {
  final _controller = StreamController<AppPermissionStatus>.broadcast();
  
  Stream<AppPermissionStatus> get onStatusChanged => _controller.stream;

  PermissionHandlerService() {
    // For web, permissions work differently. We can assume it's granted as
    // the file picker will be used.
    if (kIsWeb) {
      _controller.add(AppPermissionStatus.authorized);
      return;
    }
    _checkInitialPermission();
  }

  Future<void> _checkInitialPermission() async {
    if (kIsWeb) return;
    final status = await perm_handler.Permission.photos.status;
    _controller.add(AppPermissionStatus.from(status));
  }

  Future<void> requestPermission() async {
    if (kIsWeb) return;
    final status = await perm_handler.Permission.photos.request();
    _controller.add(AppPermissionStatus.from(status));
  }

  Future<void> openAppSettings() async {
    await perm_handler.openAppSettings();
  }

  void refreshStatus() {
    _checkInitialPermission();
  }

  void dispose() {
    _controller.close();
  }
}
