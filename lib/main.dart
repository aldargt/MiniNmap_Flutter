import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Nmap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MiniNmapHome(),
    );
  }
}

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

  final List<int> _priorityPorts = [445, 135, 139, 80, 443, 22, 3389];
  final List<int> _secondaryPorts = [21, 554, 8080, 8443, 9100, 5353, 1900];

  Future<String> _resolveHostname(String ip) async {
    try {
      final address = InternetAddress(ip);
      // Timeout de 800ms para no penalizar el rendimiento
      final host = await address.reverse().timeout(
        const Duration(milliseconds: 800),
      );
      return host.host;
    } catch (_) {
      return "Host desconocido";
    }
  }

  String _classifyDevice(String hostname, String ip) {
    String host = hostname.toLowerCase();

    // 1. Prioridad Router por hostname
    if (host.contains('router') ||
        host.contains('gateway') ||
        host.contains('tplink') ||
        host.contains('tp-link') ||
        host.contains('huawei') ||
        host.contains('zte') ||
        host.contains('asus') ||
        host.contains('mikrotik') ||
        host.contains('mercusys') ||
        host.contains('netgear') ||
        host.contains('dlink') ||
        host.contains('zyxel') ||
        host.contains('totolink') ||
        host.contains('cisco') ||
        host.contains('ubiquiti')) {
      return "Router";
    }

    // 2. Fallback Router por IP heurística (solo si hostname es desconocido)
    if (hostname == "Host desconocido") {
      if (ip.endsWith('.1') || ip.endsWith('.254')) {
        return "Router";
      }
    }

    // 3. PC
    if (host.contains('desktop') ||
        host.contains('desktop-') ||
        host.contains('laptop') ||
        host.contains('pc') ||
        host.contains('windows') ||
        host.contains('msi') ||
        host.contains('dell') ||
        host.contains('hp') ||
        host.contains('lenovo') ||
        host.contains('thinkpad') ||
        host.contains('ideapad') ||
        host.contains('victus') ||
        host.contains('omen') ||
        host.contains('latitude') ||
        host.contains('inspiron') ||
        host.contains('elitebook') ||
        host.contains('probook') ||
        host.contains('pavilion') ||
        host.contains('acer') ||
        host.contains('surface') ||
        host.contains('vaio') ||
        host.contains('workstation')) {
      return "PC";
    }

    // 4. Teléfono
    if (host.contains('android') ||
        host.contains('galaxy') ||
        host.contains('redmi') ||
        host.contains('xiaomi') ||
        host.contains('infinix') ||
        host.contains('iphone') ||
        host.contains('pixel') ||
        host.contains('motorola') ||
        host.contains('realme') ||
        host.contains('honor') ||
        host.contains('huawei') ||
        host.contains('oppo') ||
        host.contains('vivo') ||
        host.contains('oneplus') ||
        host.contains('tecno') ||
        host.contains('nokia') ||
        host.contains('sony') ||
        host.contains('asus') ||
        host.contains('moto') ||
        host.contains('poco') ||
        host.contains('sm-')) {
      return "Teléfono";
    }

    // 5. Impresora
    if (host.contains('tv') ||
        host.contains('smarttv') ||
        host.contains('samsung') ||
        host.contains('lg') ||
        host.contains('bravia') ||
        host.contains('roku') ||
        host.contains('chromecast') ||
        host.contains('firestick') ||
        host.contains('firetv') ||
        host.contains('hisense') ||
        host.contains('tcl') ||
        host.contains('philips') ||
        host.contains('webos') ||
        host.contains('androidtv')) {
      return "Impresora";
    }

    // 6. TV
    if (host.contains('tv') ||
        host.contains('smarttv') ||
        host.contains('samsung') ||
        host.contains('lg') ||
        host.contains('bravia') ||
        host.contains('roku') ||
        host.contains('chromecast') ||
        host.contains('firestick') ||
        host.contains('firetv') ||
        host.contains('hisense') ||
        host.contains('tcl') ||
        host.contains('philips') ||
        host.contains('webos') ||
        host.contains('androidtv')) {
      return "TV";
    }

    return "Dispositivo";
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case "Router":
        return Icons.router;
      case "PC":
        return Icons.computer;
      case "Teléfono":
        return Icons.smartphone;
      case "TV":
        return Icons.tv;
      case "Impresora":
        return Icons.print;
      default:
        return Icons.power;
    }
  }

  Future<Device> _buildDevice(String ip, String method) async {
    String hostname = await _resolveHostname(ip);
    String type = _classifyDevice(hostname, ip);
    IconData icon = _getIconForType(type);

    return Device(
      ip: ip,
      hostname: hostname,
      deviceType: type,
      detectionMethod: method,
      icon: icon,
    );
  }

  Future<bool> _probeIp(String ip, List<int> ports, Duration timeout) async {
    for (int port in ports) {
      try {
        final socket = await Socket.connect(ip, port, timeout: timeout);
        await socket.close();
        return true; // Host activo
      } catch (_) {
        // Continuar con el siguiente puerto
      }
    }
    return false;
  }

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
      final info = NetworkInfo();
      String? ip = await info.getWifiIP();

      if (ip == null || ip.isEmpty) {
        setState(() {
          _isScanning = false;
          _subnet = 'Error: No se pudo obtener la IP local';
        });
        return;
      }

      final String subnetBase = ip.substring(0, ip.lastIndexOf('.'));
      setState(() {
        _subnet = '$subnetBase.0/24';
      });

      // Fase 1: Escaneo ICMP
      setState(() {
        _statusMessage = 'Fase ICMP en curso...';
      });
      final scanner = LanScanner();
      final List<Host> icmpHosts = await scanner.quickIcmpScanAsync(subnetBase);

      final Set<String> foundIps = {};

      for (var host in icmpHosts) {
        String addr = host.internetAddress.address;
        foundIps.add(addr);
        Device device = await _buildDevice(addr, 'ICMP');
        setState(() {
          _devices.add(device);
        });
      }

      if (isDeepScan) {
        setState(() {
          _statusMessage = 'Fase ICMP completada. Iniciando Fallback TCP...';
        });

        // Fase 2: Fallback TCP para IPs no encontradas
        List<String> remainingIps = [];
        for (int i = 1; i < 255; i++) {
          String targetIp = '$subnetBase.$i';
          if (!foundIps.contains(targetIp)) {
            remainingIps.add(targetIp);
          }
        }

        // Escaneo concurrente limitado para eficiencia
        const int batchSize = 20;
        for (int i = 0; i < remainingIps.length; i += batchSize) {
          int end = (i + batchSize < remainingIps.length)
              ? i + batchSize
              : remainingIps.length;
          List<String> batch = remainingIps.sublist(i, end);

          setState(() {
            _statusMessage = 'Escaneando bloque TCP ${i ~/ batchSize + 1}...';
          });

          List<Future<void>> probes = batch.map((targetIp) async {
            // Nivel 1: Puertos prioritarios (300ms)
            bool isActive = await _probeIp(
              targetIp,
              _priorityPorts,
              const Duration(milliseconds: 300),
            );

            // Nivel 2: Solo si falló el Nivel 1 (500ms)
            if (!isActive) {
              isActive = await _probeIp(
                targetIp,
                _secondaryPorts,
                const Duration(milliseconds: 500),
              );
            }

            if (isActive) {
              Device device = await _buildDevice(targetIp, 'TCP');
              setState(() {
                _devices.add(device);
              });
            }
          }).toList();

          await Future.wait(probes);
        }
      }

      setState(() {
        _isScanning = false;
        _scanCompleted = true;
        _statusMessage = 'Escaneo finalizado';
        // Ordenar dispositivos por IP al final
        _devices.sort((a, b) {
          List<int> aParts = a.ip.split('.').map(int.parse).toList();
          List<int> bParts = b.ip.split('.').map(int.parse).toList();
          for (int i = 0; i < 4; i++) {
            if (aParts[i] != bParts[i]) return aParts[i].compareTo(bParts[i]);
          }
          return 0;
        });
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _isScanning
                      ? null
                      : () => _performScan(isDeepScan: false),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
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
                  onPressed: _isScanning
                      ? null
                      : () => _performScan(isDeepScan: true),
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
            ),
            if (_isScanning) ...[
              const SizedBox(height: 24),
              Center(
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
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
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
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: device.detectionMethod == 'ICMP'
                                  ? Colors.blue.shade100
                                  : Colors.orange.shade100,
                              child: Icon(
                                device.icon,
                                color: device.detectionMethod == 'ICMP'
                                    ? Colors.blue
                                    : Colors.orange,
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
                              backgroundColor: device.detectionMethod == 'ICMP'
                                  ? Colors.blue
                                  : Colors.orange,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
