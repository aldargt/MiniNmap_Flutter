import 'package:flutter/material.dart';

class Device {
  final String ip;
  final String hostname;
  final String deviceType;
  final String detectionMethod;
  final IconData icon;

  // Port scan fields (lazy loaded)
  List<int> openPorts;
  Map<int, String> detectedServices;
  bool isPortScanCompleted;

  Device({
    required this.ip,
    required this.hostname,
    required this.deviceType,
    required this.detectionMethod,
    required this.icon,
    List<int>? openPorts,
    Map<int, String>? detectedServices,
    this.isPortScanCompleted = false,
  })  : openPorts = openPorts ?? [],
        detectedServices = detectedServices ?? {};
}
