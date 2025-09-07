import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  // Stream pour écouter les changements de connectivité
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialise le service de connectivité
  Future<void> initialize() async {
    // Vérifier l'état initial de connectivité
    await _updateConnectionStatus(await _connectivity.checkConnectivity());
    
    // Écouter les changements de connectivité
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    
    print('[CONNECTIVITY] Service initialisé - État initial: ${_isOnline ? "En ligne" : "Hors ligne"}');
  }

  /// Met à jour l'état de connectivité
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final bool wasOnline = _isOnline;
    
    // Considérer comme en ligne si au moins une connexion est disponible
    _isOnline = results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.ethernet
    );

    // Notifier les changements
    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
      print('[CONNECTIVITY] Changement d\'état: ${_isOnline ? "En ligne" : "Hors ligne"}');
    }
  }


  /// Vérifie manuellement la connectivité
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(results);
      return _isOnline;
    } catch (e) {
      print('[CONNECTIVITY] Erreur lors de la vérification: $e');
      return false;
    }
  }

  /// Obtient le type de connexion actuelle
  Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        return 'Mobile';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      }
      return 'Aucune';
    } catch (e) {
      return 'Erreur';
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _connectivitySubscription.cancel();
    _connectivityController.close();
  }
}