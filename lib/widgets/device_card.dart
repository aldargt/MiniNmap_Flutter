import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: device.detectionMethod == 'ICMP'
              ? Colors.blue.shade100
              : Colors.orange.shade100,
          child: Icon(
            device.icon,
            color: device.detectionMethod == 'ICMP' ? Colors.blue : Colors.orange,
          ),
        ),
        title: Text(
          device.hostname,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.ip,
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
            Text(
              device.deviceType,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            'Vía ${device.detectionMethod}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
          backgroundColor: device.detectionMethod == 'ICMP' ? Colors.blue : Colors.orange,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
