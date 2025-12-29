import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:clean/permission_screen.dart';
import 'package:clean/main.dart'; // To get HomeScreen

class PermissionWrapper extends StatefulWidget {
  final void Function(Locale) onLocaleChanged;

  const PermissionWrapper({super.key, required this.onLocaleChanged});

  @override
  PermissionWrapperState createState() => PermissionWrapperState();
}

class PermissionWrapperState extends State<PermissionWrapper> with WidgetsBindingObserver {
  bool? _hasPermission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final state = await PhotoManager.requestPermissionExtend();
    if (mounted) {
      final hasPermission = state.hasAccess;
      if (hasPermission != _hasPermission) {
        setState(() {
          _hasPermission = hasPermission;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return _hasPermission!
        ? HomeScreen(onLocaleChanged: widget.onLocaleChanged)
        : PermissionScreen(
              onPermissionGranted: () {
                _checkPermissions();
              },
              onLocaleChanged: widget.onLocaleChanged,
            );
  }
}