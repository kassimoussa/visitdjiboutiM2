import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  /// Génère un identifiant unique pour l'appareil
  Future<String> generateUniqueDeviceId() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(9999);
      
      // Créer un ID basé sur les informations de l'appareil et un timestamp
      final baseString = '${deviceInfo['platform']}_${deviceInfo['model']}_$timestamp$random';
      return 'device_${baseString.hashCode.abs()}';
    } catch (e) {
      // Fallback : générer un ID aléatoire
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(999999);
      return 'device_fallback_$timestamp$random';
    }
  }

  /// Obtient les informations de l'appareil
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        return _getWebDeviceInfo();
      } else if (Platform.isAndroid) {
        return await _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceInfo();
      } else {
        return _getDefaultDeviceInfo();
      }
    } catch (e) {
      print('Erreur lors de l\'obtention des informations de l\'appareil: $e');
      return _getDefaultDeviceInfo();
    }
  }

  Map<String, dynamic> _getWebDeviceInfo() {
    return {
      'platform': 'web',
      'model': 'Browser',
      'os_version': 'Web',
      'app_version': '1.0.0',
      'user_agent': kIsWeb ? 'Flutter Web' : 'Unknown',
    };
  }

  Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    try {
      // Utilisation de MethodChannel pour obtenir les infos Android
      const platform = MethodChannel('device_info');
      final result = await platform.invokeMethod('getDeviceInfo');
      
      return {
        'platform': 'android',
        'model': result['model'] ?? 'Unknown Android',
        'manufacturer': result['manufacturer'] ?? 'Unknown',
        'os_version': result['version'] ?? 'Unknown',
        'api_level': result['sdk'] ?? 0,
        'app_version': '1.0.0',
      };
    } catch (e) {
      return {
        'platform': 'android',
        'model': 'Android Device',
        'manufacturer': 'Unknown',
        'os_version': 'Unknown',
        'api_level': 0,
        'app_version': '1.0.0',
      };
    }
  }

  Future<Map<String, dynamic>> _getIOSDeviceInfo() async {
    try {
      // Utilisation de MethodChannel pour obtenir les infos iOS
      const platform = MethodChannel('device_info');
      final result = await platform.invokeMethod('getDeviceInfo');
      
      return {
        'platform': 'ios',
        'model': result['model'] ?? 'Unknown iPhone',
        'system_name': result['systemName'] ?? 'iOS',
        'os_version': result['systemVersion'] ?? 'Unknown',
        'app_version': '1.0.0',
      };
    } catch (e) {
      return {
        'platform': 'ios',
        'model': 'iOS Device',
        'system_name': 'iOS',
        'os_version': 'Unknown',
        'app_version': '1.0.0',
      };
    }
  }

  Map<String, dynamic> _getDefaultDeviceInfo() {
    return {
      'platform': 'unknown',
      'model': 'Unknown Device',
      'os_version': 'Unknown',
      'app_version': '1.0.0',
    };
  }

  /// Vérifie si l'appareil prend en charge certaines fonctionnalités
  Future<Map<String, bool>> getDeviceCapabilities() async {
    return {
      'has_camera': !kIsWeb,
      'has_gps': !kIsWeb,
      'has_internet': true, // Assumé vrai pour maintenant
      'supports_notifications': !kIsWeb,
      'supports_biometrics': !kIsWeb,
    };
  }

  /// Obtient la langue préférée de l'appareil
  String getDeviceLanguage() {
    try {
      final locale = PlatformDispatcher.instance.locale;
      return locale.languageCode;
    } catch (e) {
      return 'fr'; // Français par défaut
    }
  }

  /// Obtient le fuseau horaire de l'appareil
  String getDeviceTimezone() {
    try {
      return DateTime.now().timeZoneName;
    } catch (e) {
      return 'UTC';
    }
  }

  /// Vérifie si c'est le premier lancement de l'application
  static Future<bool> isFirstLaunch() async {
    try {
      // Cette méthode sera utilisée par AnonymousAuthService
      // pour déterminer si c'est le premier lancement
      return true; // Placeholder pour maintenant
    } catch (e) {
      return true;
    }
  }
}