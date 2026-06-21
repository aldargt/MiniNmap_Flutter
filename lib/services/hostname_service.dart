import 'dart:io';

class HostnameService {
  Future<String> resolveHostname(String ip) async {
    try {
      final address = InternetAddress(ip);
      final host = await address.reverse().timeout(
        const Duration(milliseconds: 800),
      );
      return host.host;
    } catch (_) {
      return "Host desconocido";
    }
  }
}
