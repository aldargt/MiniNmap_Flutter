import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final Device device;

  const DeviceDetailsScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del dispositivo'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono grande superior
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: device.detectionMethod == 'ICMP'
                    ? Colors.blue.shade100
                    : Colors.orange.shade100,
                child: Icon(
                  device.icon,
                  size: 50,
                  color: device.detectionMethod == 'ICMP'
                      ? Colors.blue
                      : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Información Básica
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información básica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow(context, 'Hostname', device.hostname),
                    _buildInfoRow(context, 'Dirección IP', device.ip),
                    _buildInfoRow(context, 'Tipo de dispositivo', device.deviceType),
                    _buildInfoRow(context, 'Método de detección', device.detectionMethod),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sección: Estado
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Divider(),
                    const Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 14,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Detectado en el último escaneo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sección: Información adicional (placeholders para futuras iteraciones)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información adicional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow(context, 'Fabricante', 'No disponible'),
                    _buildInfoRow(context, 'Servicios detectados', 'No disponible'),
                    _buildInfoRow(context, 'Puertos abiertos', 'No disponible'),
                    _buildInfoRow(context, 'Tiempo de respuesta', 'No disponible'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
