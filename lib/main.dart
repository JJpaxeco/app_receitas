import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'home_page.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => AppReceitas(),
    ),
  );
}
