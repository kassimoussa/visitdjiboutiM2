import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/connectivity_service.dart';

class OfflineIndicator extends StatefulWidget {
  final Widget child;
  final bool showWhenOnline;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.showWhenOnline = false,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  
  late StreamSubscription<bool> _connectivitySubscription;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeServices();
  }

  void _initializeServices() async {
    // État initial
    _isOnline = _connectivityService.isOnline;
    
    // Écouter les changements de connectivité
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
        
        if (!isOnline) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }
    });


    // Animation initiale si hors ligne
    if (!_isOnline) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_shouldShowIndicator)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildIndicatorBar(),
            ),
          ),
      ],
    );
  }

  bool get _shouldShowIndicator {
    return !_isOnline;
  }

  Widget _buildIndicatorBar() {
    return _buildOfflineBar();
  }

  Widget _buildOfflineBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Mode hors ligne - Données en cache disponibles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: _checkConnection,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _checkConnection() async {
    final isOnline = await _connectivityService.checkConnectivity();
    if (isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connexion rétablie !'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Widget compact pour afficher le statut de connectivité dans l'AppBar
class ConnectivityIcon extends StatefulWidget {
  const ConnectivityIcon({super.key});

  @override
  State<ConnectivityIcon> createState() => _ConnectivityIconState();
}

class _ConnectivityIconState extends State<ConnectivityIcon> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _connectivitySubscription;
  
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline) {
      return const SizedBox.shrink(); // Masquer quand en ligne
    }

    return IconButton(
      icon: Icon(
        Icons.wifi_off,
        color: Colors.orange.shade600,
      ),
      onPressed: () {
        _showOfflineDialog(context);
      },
      tooltip: 'Mode hors ligne',
    );
  }

  void _showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.wifi_off,
          color: Colors.orange.shade600,
          size: 48,
        ),
        title: const Text('Mode hors ligne'),
        content: const Text(
          'Vous êtes actuellement hors ligne. '
          'Les données mises en cache sont disponibles, '
          'mais certaines fonctionnalités peuvent être limitées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final isOnline = await _connectivityService.checkConnectivity();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isOnline 
                        ? 'Connexion rétablie !' 
                        : 'Toujours hors ligne',
                    ),
                    backgroundColor: isOnline ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}