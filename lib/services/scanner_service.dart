import 'dart:async';
import 'package:lan_scanner/lan_scanner.dart';
import '../models/device.dart';
import '../utils/device_classifier.dart';
import 'hostname_service.dart';
import 'tcp_probe_service.dart';

class ScannerService {
  final HostnameService _hostnameService = HostnameService();
  final TcpProbeService _tcpProbeService = TcpProbeService();
  final LanScanner _lanScanner = LanScanner();

  final List<int> priorityPorts = [445, 135, 139, 80, 443, 22, 3389];
  final List<int> secondaryPorts = [21, 554, 8080, 8443, 9100, 5353, 1900];

  Future<Device> buildDevice(String ip, String method) async {
    String hostname = await _hostnameService.resolveHostname(ip);
    String type = DeviceClassifier.classifyDevice(hostname, ip);
    var icon = DeviceClassifier.getIconForType(type);

    return Device(
      ip: ip,
      hostname: hostname,
      deviceType: type,
      detectionMethod: method,
      icon: icon,
    );
  }

  Future<void> performScan({
    required String subnetBase,
    required bool isDeepScan,
    required void Function(String) onStatusChanged,
    required void Function(Device) onDeviceFound,
  }) async {
    // Fase 1: Escaneo ICMP
    onStatusChanged('Fase ICMP en curso...');
    final List<Host> icmpHosts = await _lanScanner.quickIcmpScanAsync(subnetBase);

    final Set<String> foundIps = {};

    for (var host in icmpHosts) {
      String addr = host.internetAddress.address;
      foundIps.add(addr);
      Device device = await buildDevice(addr, 'ICMP');
      onDeviceFound(device);
    }

    if (isDeepScan) {
      onStatusChanged('Fase ICMP completada. Iniciando Fallback TCP...');

      // Fase 2: Fallback TCP para IPs no encontradas
      List<String> remainingIps = [];
      for (int i = 1; i < 255; i++) {
        String targetIp = '$subnetBase.$i';
        if (!foundIps.contains(targetIp)) {
          remainingIps.add(targetIp);
        }
      }

      // Escaneo concurrente limitado
      const int batchSize = 20;
      for (int i = 0; i < remainingIps.length; i += batchSize) {
        int end = (i + batchSize < remainingIps.length)
            ? i + batchSize
            : remainingIps.length;
        List<String> batch = remainingIps.sublist(i, end);

        onStatusChanged('Escaneando bloque TCP ${i ~/ batchSize + 1}...');

        List<Future<void>> probes = batch.map((targetIp) async {
          // Nivel 1: Puertos prioritarios (300ms)
          bool isActive = await _tcpProbeService.probeIp(
            targetIp,
            priorityPorts,
            const Duration(milliseconds: 300),
          );

          // Nivel 2: Solo si falló el Nivel 1 (500ms)
          if (!isActive) {
            isActive = await _tcpProbeService.probeIp(
              targetIp,
              secondaryPorts,
              const Duration(milliseconds: 500),
            );
          }

          if (isActive) {
            Device device = await buildDevice(targetIp, 'TCP');
            onDeviceFound(device);
          }
        }).toList();

        await Future.wait(probes);
      }
    }
  }
}
