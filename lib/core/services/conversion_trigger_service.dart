import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anonymous_user.dart';
import '../../presentation/widgets/conversion_prompt.dart';
import 'anonymous_auth_service.dart';

class ConversionTriggerService {
  static final ConversionTriggerService _instance = ConversionTriggerService._internal();
  factory ConversionTriggerService() => _instance;
  ConversionTriggerService._internal();

  final AnonymousAuthService _authService = AnonymousAuthService();
  
  // Clés pour tracker les triggers déjà affichés
  static const String _dismissedTriggersKey = 'dismissed_triggers';
  static const String _lastTriggerCheckKey = 'last_trigger_check';
  static const String _conversionShownKey = 'conversion_shown_';

  /// Vérifie et affiche les triggers de conversion si nécessaire
  Future<void> checkAndShowConversionTrigger(BuildContext context) async {
    try {
      if (!_authService.isAnonymousUser) return;

      final trigger = await _authService.checkConversionTrigger();
      if (trigger == null) return;

      // Vérifier si ce trigger a déjà été affiché récemment
      if (await _wasTriggerRecentlyShown(trigger)) return;

      // Vérifier si ce trigger a été définitivement rejeté
      if (await _wasTriggerDismissed(trigger)) return;

      // Afficher le trigger avec un délai pour l'UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (context.mounted) {
        await _showTrigger(context, trigger);
      }
    } catch (e) {
      print('Erreur lors de la vérification des triggers: $e');
    }
  }

  /// Vérifie spécifiquement le trigger "avant réservation"
  Future<bool> checkBeforeReservationTrigger(BuildContext context) async {
    try {
      if (!_authService.isAnonymousUser) return true; // Autoriser si utilisateur connecté

      final trigger = ConversionTrigger.beforeReservation;
      
      // Toujours montrer ce trigger car c'est obligatoire pour la réservation
      if (context.mounted) {
        final result = await _showTrigger(context, trigger);
        return result ?? false; // false = annulation, true = création de compte
      }
      
      return false;
    } catch (e) {
      print('Erreur lors du trigger de réservation: $e');
      return false;
    }
  }

  /// Vérifie le trigger "avant export" d'itinéraire
  Future<bool> checkBeforeExportTrigger(BuildContext context) async {
    try {
      if (!_authService.isAnonymousUser) return true;

      final trigger = ConversionTrigger.beforeExport;
      
      if (context.mounted) {
        final result = await _showTrigger(context, trigger);
        return result ?? false;
      }
      
      return false;
    } catch (e) {
      print('Erreur lors du trigger d\'export: $e');
      return false;
    }
  }

  /// Affiche un trigger de conversion de manière contextuelle
  Future<bool?> _showTrigger(BuildContext context, ConversionTrigger trigger) async {
    await _markTriggerShown(trigger);

    return await ConversionPrompt.show(
      context,
      trigger,
      onConvert: () {
        _markTriggerConverted(trigger);
      },
      onDismiss: () {
        _markTriggerDismissed(trigger);
      },
    );
  }

  /// Affiche subtilement un banner de conversion (non-intrusif)
  Widget? buildConversionBanner(BuildContext context) {
    return FutureBuilder<ConversionTrigger?>(
      future: _getSubtleTrigger(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final trigger = snapshot.data!;
        return SubtleConversionBanner(
          trigger: trigger,
          onTap: () => _showTrigger(context, trigger),
          onDismiss: () => _markTriggerDismissed(trigger),
        );
      },
    );
  }

  /// Obtient un trigger pour affichage subtil (banner)
  Future<ConversionTrigger?> _getSubtleTrigger() async {
    try {
      if (!_authService.isAnonymousUser) return null;

      final trigger = await _authService.checkConversionTrigger();
      if (trigger == null) return null;

      // Seulement certains triggers sont affichés subtilement
      if (trigger == ConversionTrigger.afterFavorites || 
          trigger == ConversionTrigger.afterWeekUsage) {
        
        if (await _wasTriggerDismissed(trigger)) return null;
        if (await _wasTriggerRecentlyShown(trigger)) return null;
        
        return trigger;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si un trigger a été affiché récemment
  Future<bool> _wasTriggerRecentlyShown(ConversionTrigger trigger) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shownKey = '$_conversionShownKey${trigger.name}';
      final lastShown = prefs.getString(shownKey);
      
      if (lastShown == null) return false;
      
      final lastShownDate = DateTime.parse(lastShown);
      final cooldownHours = _getTriggerCooldown(trigger);
      
      return DateTime.now().difference(lastShownDate).inHours < cooldownHours;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si un trigger a été définitivement rejeté
  Future<bool> _wasTriggerDismissed(ConversionTrigger trigger) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedTriggers = prefs.getStringList(_dismissedTriggersKey) ?? [];
      return dismissedTriggers.contains(trigger.name);
    } catch (e) {
      return false;
    }
  }

  /// Marque un trigger comme affiché
  Future<void> _markTriggerShown(ConversionTrigger trigger) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shownKey = '$_conversionShownKey${trigger.name}';
      await prefs.setString(shownKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Erreur lors du marquage du trigger: $e');
    }
  }

  /// Marque un trigger comme rejeté
  Future<void> _markTriggerDismissed(ConversionTrigger trigger) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedTriggers = prefs.getStringList(_dismissedTriggersKey) ?? [];
      
      if (!dismissedTriggers.contains(trigger.name)) {
        dismissedTriggers.add(trigger.name);
        await prefs.setStringList(_dismissedTriggersKey, dismissedTriggers);
      }
    } catch (e) {
      print('Erreur lors du marquage de rejet: $e');
    }
  }

  /// Marque un trigger comme ayant mené à une conversion
  Future<void> _markTriggerConverted(ConversionTrigger trigger) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Supprimer de la liste des rejetés s'il y était
      final dismissedTriggers = prefs.getStringList(_dismissedTriggersKey) ?? [];
      dismissedTriggers.remove(trigger.name);
      await prefs.setStringList(_dismissedTriggersKey, dismissedTriggers);
      
      // Marquer comme converti (pour analytics futures)
      await prefs.setString('converted_trigger', trigger.name);
      await prefs.setString('conversion_date', DateTime.now().toIso8601String());
    } catch (e) {
      print('Erreur lors du marquage de conversion: $e');
    }
  }

  /// Obtient la période de cooldown pour un trigger (en heures)
  int _getTriggerCooldown(ConversionTrigger trigger) {
    switch (trigger) {
      case ConversionTrigger.afterFavorites:
        return 24; // 1 jour
      case ConversionTrigger.beforeReservation:
        return 0; // Pas de cooldown - toujours montrer
      case ConversionTrigger.beforeExport:
        return 0; // Pas de cooldown - toujours montrer
      case ConversionTrigger.afterWeekUsage:
        return 72; // 3 jours
      case ConversionTrigger.manual:
        return 0; // Pas de cooldown
    }
  }

  /// Remet à zéro tous les triggers (pour debug/reset)
  Future<void> resetAllTriggers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dismissedTriggersKey);
      await prefs.remove(_lastTriggerCheckKey);
      
      // Supprimer tous les triggers "shown"
      final keys = prefs.getKeys().where((key) => key.startsWith(_conversionShownKey));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Erreur lors du reset des triggers: $e');
    }
  }

  /// Obtient les statistiques des triggers pour analytics
  Future<Map<String, dynamic>> getTriggerStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'dismissed_triggers': prefs.getStringList(_dismissedTriggersKey) ?? [],
        'converted_trigger': prefs.getString('converted_trigger'),
        'conversion_date': prefs.getString('conversion_date'),
        'is_anonymous_user': _authService.isAnonymousUser,
        'favorites_count': prefs.getInt('favorites_count') ?? 0,
      };
    } catch (e) {
      return {};
    }
  }
}