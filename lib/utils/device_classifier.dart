import 'package:flutter/material.dart';

class DeviceClassifier {
  static String classifyDevice(String hostname, String ip) {
    String host = hostname.toLowerCase();

    // 1. Router
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

    if (hostname == "Host desconocido" || hostname == ip) {
      if (ip.endsWith('.1') || ip.endsWith('.254')) {
        return "Router";
      }
    }

    // 2. Impresora
    if (host.contains('printer') ||
        host.contains('epson') ||
        host.contains('canon') ||
        host.contains('brother') ||
        host.contains('xerox') ||
        host.contains('pantum') ||
        host.contains('ricoh') ||
        host.contains('lexmark') ||
        host.contains('kyocera')) {
      return "Impresora";
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
        host.contains('gigabyte') ||
        host.contains('alienware') ||
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

    // 4. Servidor / NAS
    if (host.contains('synology') ||
        host.contains('qnap') ||
        host.contains('nas') ||
        host.contains('server') ||
        host.contains('ubuntu') ||
        host.contains('debian') ||
        host.contains('raspberry') ||
        host.contains('raspberrypi') ||
        host.contains('openmediavault')) {
      return "Servidor / NAS";
    }

    // 5. Teléfono
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
        host.contains('asus') ||
        host.contains('moto') ||
        host.contains('poco') ||
        host.contains('sm-')) {
      return "Teléfono";
    }

    // 6. Consola
    if (host.contains('playstation') ||
        host.contains('ps4') ||
        host.contains('ps5') ||
        host.contains('xbox') ||
        host.contains('nintendo') ||
        host.contains('switch')) {
      return "Consola";
    }

    // 7. Cámara IP
    if (host.contains('hikvision') ||
        host.contains('dahua') ||
        host.contains('ezviz') ||
        host.contains('imou') ||
        host.contains('reolink') ||
        host.contains('yi') ||
        host.contains('camera') ||
        host.contains('cam') ||
        host.contains('tapo')) {
      return "Cámara IP";
    }

    // 8. IoT
    if (host.contains('esp32') ||
        host.contains('esp8266') ||
        host.contains('sonoff') ||
        host.contains('shelly') ||
        host.contains('tuya') ||
        host.contains('iot') ||
        host.contains('smartlife') ||
        host.contains('ewelink')) {
      return "IoT";
    }

    // 9. Altavoz inteligente
    if (host.contains('alexa') ||
        host.contains('echo') ||
        host.contains('googlehome') ||
        host.contains('nest') ||
        host.contains('homepod')) {
      return "Altavoz inteligente";
    }

    // 10. Repetidor WiFi
    if (host.contains('extender') ||
        host.contains('repeater') ||
        host.contains('range') ||
        host.contains('deco') ||
        host.contains('mesh')) {
      return "Repetidor WiFi";
    }

    // 11. TV
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
        host.contains('sony') ||
        host.contains('webos') ||
        host.contains('vizio') ||
        host.contains('androidtv')) {
      return "TV";
    }

    return "Dispositivo";
  }

  static IconData getIconForType(String type) {
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
      case "Servidor / NAS":
        return Icons.storage;
      case "Consola":
        return Icons.videogame_asset;
      case "Cámara IP":
        return Icons.videocam;
      case "IoT":
        return Icons.developer_board;
      case "Altavoz inteligente":
        return Icons.speaker_group;
      case "Repetidor WiFi":
        return Icons.wifi_tethering;
      default:
        return Icons.power;
    }
  }
}
