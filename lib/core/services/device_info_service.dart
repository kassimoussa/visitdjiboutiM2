import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Obtient les informations complètes de l'appareil
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      final connectivity = await Connectivity().checkConnectivity();
      
      Map<String, dynamic> baseInfo = {
        'app_name': packageInfo.appName,
        'app_version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
        'package_name': packageInfo.packageName,
        'connectivity': connectivity.isNotEmpty ? connectivity.first.name : 'none',
        'timestamp': DateTime.now().toIso8601String(),
        'locale': PlatformDispatcher.instance.locale.toString(),
        'timezone': DateTime.now().timeZoneName,
        'timezone_offset': DateTime.now().timeZoneOffset.inHours,
      };

      if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        return {
          ...baseInfo,
          'platform': 'web',
          'browser_name': webInfo.browserName.name,
          'user_agent': webInfo.userAgent ?? 'Unknown',
          'vendor': webInfo.vendor ?? 'Unknown',
          'language': webInfo.language ?? 'fr',
          'platform_type': webInfo.platform ?? 'Unknown',
          'screen_width': PlatformDispatcher.instance.views.first.physicalSize.width,
          'screen_height': PlatformDispatcher.instance.views.first.physicalSize.height,
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return {
          ...baseInfo,
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'hardware': androidInfo.hardware,
          'android_id': androidInfo.id,
          'os_version': androidInfo.version.release,
          'api_level': androidInfo.version.sdkInt,
          'security_patch': androidInfo.version.securityPatch,
          'is_physical_device': androidInfo.isPhysicalDevice,
          'board': androidInfo.board,
          'bootloader': androidInfo.bootloader,
          'fingerprint': androidInfo.fingerprint,
          'supported_abis': androidInfo.supportedAbis,
          'supported_32bit_abis': androidInfo.supported32BitAbis,
          'supported_64bit_abis': androidInfo.supported64BitAbis,
          'system_features': androidInfo.systemFeatures,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return {
          ...baseInfo,
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'system_name': iosInfo.systemName,
          'os_version': iosInfo.systemVersion,
          'identifier_for_vendor': iosInfo.identifierForVendor,
          'is_physical_device': iosInfo.isPhysicalDevice,
          'machine': iosInfo.utsname.machine,
          'system_kernel': iosInfo.utsname.sysname,
          'kernel_version': iosInfo.utsname.version,
        };
      } else {
        return {
          ...baseInfo,
          'platform': Platform.operatingSystem,
          'os_version': Platform.operatingSystemVersion,
        };
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
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final hasInternet = connectivity.isNotEmpty && 
                         connectivity.first != ConnectivityResult.none;
      
      return {
        'has_camera': !kIsWeb,
        'has_gps': !kIsWeb,
        'has_internet': hasInternet,
        'supports_notifications': !kIsWeb,
        'supports_biometrics': !kIsWeb,
        'supports_wifi': !kIsWeb,
        'supports_bluetooth': !kIsWeb && (Platform.isAndroid || Platform.isIOS),
        'supports_nfc': !kIsWeb && Platform.isAndroid,
        'is_tablet': await _isTablet(),
        'is_emulator': await _isEmulator(),
      };
    } catch (e) {
      return {
        'has_camera': !kIsWeb,
        'has_gps': !kIsWeb,
        'has_internet': false,
        'supports_notifications': !kIsWeb,
        'supports_biometrics': !kIsWeb,
        'supports_wifi': !kIsWeb,
        'supports_bluetooth': false,
        'supports_nfc': false,
        'is_tablet': false,
        'is_emulator': false,
      };
    }
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
      final prefs = await SharedPreferences.getInstance();
      const firstLaunchKey = 'first_launch_completed';
      
      final isFirst = !prefs.containsKey(firstLaunchKey);
      if (isFirst) {
        await prefs.setBool(firstLaunchKey, true);
        await prefs.setString('first_launch_date', DateTime.now().toIso8601String());
      }
      
      return isFirst;
    } catch (e) {
      return true;
    }
  }

  /// Détecte si l'appareil est une tablette
  Future<bool> _isTablet() async {
    try {
      if (kIsWeb) return false;
      
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        // Une tablette Android a généralement une diagonale > 7 pouces
        // On peut utiliser la densité d'écran comme indicateur
        return false; // Nécessite plus de logique spécifique
      } else if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.model.toLowerCase().contains('ipad');
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Détecte si l'appareil est un émulateur
  Future<bool> _isEmulator() async {
    try {
      if (kIsWeb) return false;
      
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return !iosInfo.isPhysicalDevice;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtient des informations de performance/mémoire
  Future<Map<String, dynamic>> getPerformanceInfo() async {
    try {
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'available_memory_mb': await _getAvailableMemoryMB(),
        'battery_level': await _getBatteryLevel(),
        'storage_info': await _getStorageInfo(),
        'network_info': await _getNetworkInfo(),
      };
    } catch (e) {
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  Future<double?> _getAvailableMemoryMB() async {
    try {
      // Nécessiterait un plugin spécialisé ou du code natif
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int?> _getBatteryLevel() async {
    try {
      // Nécessiterait battery_plus package
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _getStorageInfo() async {
    try {
      // Informations de stockage disponible/utilisé
      return {
        'available': 'unknown',
        'total': 'unknown',
      };
    } catch (e) {
      return {
        'available': 'error',
        'total': 'error',
      };
    }
  }

  Future<Map<String, dynamic>> _getNetworkInfo() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final connectionType = connectivity.isNotEmpty ? connectivity.first : ConnectivityResult.none;
      return {
        'type': connectionType.name,
        'is_connected': connectionType != ConnectivityResult.none,
        'is_mobile': connectionType == ConnectivityResult.mobile,
        'is_wifi': connectionType == ConnectivityResult.wifi,
      };
    } catch (e) {
      return {
        'type': 'unknown',
        'is_connected': false,
        'is_mobile': false,
        'is_wifi': false,
      };
    }
  }

  /// Sauvegarde les informations device pour analytics
  Future<void> logDeviceInfo() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final capabilities = await getDeviceCapabilities();
      final performanceInfo = await getPerformanceInfo();
      
      final completeInfo = {
        'device_info': deviceInfo,
        'capabilities': capabilities,
        'performance': performanceInfo,
        'logged_at': DateTime.now().toIso8601String(),
      };
      
      // Log pour debug (en production, envoyer au backend analytics)
      print('Device Info Collected: ${completeInfo.keys}');
      
      // Optionnel : sauvegarder localement pour sync ultérieure
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_device_info', completeInfo.toString());
      
    } catch (e) {
      print('Erreur lors du logging des informations device: $e');
    }
  }
}