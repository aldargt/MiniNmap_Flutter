import 'package:flutter/material.dart';

class ScanButtons extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onQuickScanPressed;
  final VoidCallback onDeepScanPressed;

  const ScanButtons({
    super.key,
    required this.isScanning,
    required this.onQuickScanPressed,
    required this.onDeepScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: isScanning ? null : onQuickScanPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Column(
            children: [
              const Text(
                '⚡ Escaneo rápido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Descubre dispositivos comunes',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: isScanning ? null : onDeepScanPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Column(
            children: [
              const Text(
                '🔎 Escaneo profundo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Busca dispositivos ocultos y protegidos',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
