import 'package:flutter/material.dart';

class Device {
  final String ip;
  final String hostname;
  final String deviceType;
  final String detectionMethod;
  final IconData icon;

  Device({
    required this.ip,
    required this.hostname,
    required this.deviceType,
    required this.detectionMethod,
    required this.icon,
  });
}
