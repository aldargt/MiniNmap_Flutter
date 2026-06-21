import '../models/device.dart';

class IpSorter {
  static void sortDevicesByIp(List<Device> devices) {
    devices.sort((a, b) {
      List<int> aParts = a.ip.split('.').map(int.parse).toList();
      List<int> bParts = b.ip.split('.').map(int.parse).toList();
      for (int i = 0; i < 4; i++) {
        if (aParts[i] != bParts[i]) return aParts[i].compareTo(bParts[i]);
      }
      return 0;
    });
  }
}
