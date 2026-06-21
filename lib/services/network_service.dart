import 'package:network_info_plus/network_info_plus.dart';

class NetworkService {
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<String?> getWifiIP() async {
    return await _networkInfo.getWifiIP();
  }

  String getSubnetBase(String ip) {
    return ip.substring(0, ip.lastIndexOf('.'));
  }
}
