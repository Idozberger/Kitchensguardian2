import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showPermissionDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Camera Permission Required"),
      content: const Text(
        "Camera access is permanently denied. Please enable it in app settings to use this feature.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await openAppSettings();
          },
          child: const Text("Open Settings"),
        ),
      ],
    ),
  );
}
