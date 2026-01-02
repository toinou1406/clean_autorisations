
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clean/permission_screen.dart';
import 'package:clean/main.dart'; // To get HomeScreen
import 'package:clean/permission_handler_service.dart';

class PermissionWrapper extends StatefulWidget {
  final void Function(Locale) onLocaleChanged;

  const PermissionWrapper({super.key, required this.onLocaleChanged});

  @override
  PermissionWrapperState createState() => PermissionWrapperState();
}

class PermissionWrapperState extends State<PermissionWrapper> with WidgetsBindingObserver {
  final PermissionHandlerService _permissionService = PermissionHandlerService();
  late final StreamSubscription<AppPermissionStatus> _subscription;

  AppPermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = _permissionService.onStatusChanged.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed, refreshing permission status.");
      _permissionService.refreshStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    _permissionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case AppPermissionStatus.authorized:
        return HomeScreen(onLocaleChanged: widget.onLocaleChanged);
      case AppPermissionStatus.limited:
      case AppPermissionStatus.denied:
      case AppPermissionStatus.permanentlyDenied:
        return PermissionScreen(
          initialStatus: _status!,
          permissionService: _permissionService,
          onLocaleChanged: widget.onLocaleChanged,
        );
      case AppPermissionStatus.unknown:
      case null:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}
