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

class PermissionWrapperState extends State<PermissionWrapper> {
  Future<PermissionState> _permissionStateFuture;

  PermissionWrapperState()
      : _permissionStateFuture = PhotoManager.getPermissionState(
          requestOption: const PermissionRequestOption(),
        );

  void refresh() {
    setState(() {
      _permissionStateFuture = Future.delayed(const Duration(milliseconds: 500), () {
        return PhotoManager.getPermissionState(
          requestOption: const PermissionRequestOption(),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionState>(
      future: _permissionStateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == PermissionState.authorized) {
          return HomeScreen(onLocaleChanged: widget.onLocaleChanged);
        }

        return PermissionScreen(
          onPermissionGranted: refresh,
          onLocaleChanged: widget.onLocaleChanged,
        );
      },
    );
  }
}