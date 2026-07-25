import 'dart:async';
import 'dart:io';

class PortScannerService {
  const PortScannerService();

  static const Map<int, String> serviceMap = {
    21: 'FTP',
    22: 'SSH',
    80: 'HTTP',
    135: 'RPC',
    139: 'NetBIOS',
    443: 'HTTPS',
    445: 'SMB',
    554: 'RTSP',
    3389: 'RDP',
    5357: 'WSDAPI',
    8080: 'HTTP Alt',
    8443: 'HTTPS Alt',
    9100: 'Printer',
  };

  /// Scans the predefined ports for a given [ip] address concurrently.
  /// Returns a Map of open ports and their service names.
  Future<Map<int, String>> scanPorts(
    String ip, {
    Duration timeout = const Duration(milliseconds: 600),
  }) async {
    final Map<int, String> openServices = {};
    final List<Future<void>> scanTasks = [];

    for (final port in serviceMap.keys) {
      scanTasks.add(_probePort(ip, port, timeout, openServices));
    }

    await Future.wait(scanTasks);
    return openServices;
  }

  Future<void> _probePort(
    String ip,
    int port,
    Duration timeout,
    Map<int, String> openServices,
  ) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      await socket.close();
      openServices[port] = serviceMap[port]!;
    } on SocketException {
      // The port is closed, filtered, or the connection timed out
    } on TimeoutException {
      // The connection attempt exceeded the configured timeout
    }
  }
}
