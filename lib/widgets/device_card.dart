import 'package:flutter/material.dart';
import '../models/device.dart';
import '../screens/device_details_screen.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailsScreen(device: device),
            ),
          );
        },
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
              '${device.deviceType} • ${device.detectionMethod}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }
}
