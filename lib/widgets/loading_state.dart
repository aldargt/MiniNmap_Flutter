import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final String statusMessage;

  const LoadingState({super.key, required this.statusMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            '📡 Escaneando la red...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Buscando dispositivos activos',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            statusMessage,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
