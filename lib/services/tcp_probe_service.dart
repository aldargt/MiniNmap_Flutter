import 'dart:io';

class TcpProbeService {
  Future<bool> probeIp(String ip, List<int> ports, Duration timeout) async {
    for (int port in ports) {
      try {
        final socket = await Socket.connect(ip, port, timeout: timeout);
        await socket.close();
        return true;
      } catch (_) {
        // Continuar al siguiente puerto
      }
    }
    return false;
  }
}
