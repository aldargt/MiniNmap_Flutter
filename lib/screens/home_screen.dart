import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/network_service.dart';
import '../services/scanner_service.dart';
import '../utils/ip_sorter.dart';
import '../widgets/device_card.dart';
import '../widgets/scan_buttons.dart';
import '../widgets/loading_state.dart';

class MiniNmapHome extends StatefulWidget {
  const MiniNmapHome({super.key});

  @override
  State<MiniNmapHome> createState() => _MiniNmapHomeState();
}

class _MiniNmapHomeState extends State<MiniNmapHome> {
  bool _isScanning = false;
  bool _scanCompleted = false;
  String _subnet = 'No escaneada';
  String _statusMessage = '';
  final List<Device> _devices = [];

  final ScannerService _scannerService = ScannerService();
  final NetworkService _networkService = NetworkService();

  Future<void> _performScan({bool isDeepScan = false}) async {
    setState(() {
      _isScanning = true;
      _scanCompleted = false;
      _devices.clear();
      _subnet = 'Buscando red...';
      _statusMessage = isDeepScan
          ? 'Iniciando escaneo profundo...'
          : 'Iniciando escaneo rápido...';
    });

    try {
      String? ip = await _networkService.getWifiIP();

      if (ip == null || ip.isEmpty) {
        setState(() {
          _isScanning = false;
          _subnet = 'Error: No se pudo obtener la IP local';
        });
        return;
      }

      final String subnetBase = _networkService.getSubnetBase(ip);
      setState(() {
        _subnet = '$subnetBase.0/24';
      });

      await _scannerService.performScan(
        subnetBase: subnetBase,
        isDeepScan: isDeepScan,
        onStatusChanged: (status) {
          setState(() {
            _statusMessage = status;
          });
        },
        onDeviceFound: (device) {
          setState(() {
            _devices.add(device);
          });
        },
      );

      setState(() {
        _isScanning = false;
        _scanCompleted = true;
        _statusMessage = 'Escaneo finalizado';
        IpSorter.sortDevicesByIp(_devices);
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _subnet = 'Error durante el escaneo: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Nmap'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Red detectada:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subnet,
                      style: TextStyle(
                        fontSize: 16,
                        color: _scanCompleted ? Colors.blue : Colors.grey,
                        fontWeight: _scanCompleted
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ScanButtons(
              isScanning: _isScanning,
              onQuickScanPressed: () => _performScan(isDeepScan: false),
              onDeepScanPressed: () => _performScan(isDeepScan: true),
            ),
            if (_isScanning) ...[
              const SizedBox(height: 24),
              LoadingState(statusMessage: _statusMessage),
            ],
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dispositivos encontrados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_scanCompleted)
                  Text(
                    'Total: ${_devices.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _devices.isEmpty && !_isScanning
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.devices_other,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Ningún dispositivo encontrado',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        return DeviceCard(device: device);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
