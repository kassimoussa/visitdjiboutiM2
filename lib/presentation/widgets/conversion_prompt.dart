import 'package:flutter/material.dart';
import '../../core/models/anonymous_user.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../pages/auth/signup_page.dart';

class ConversionPrompt extends StatelessWidget {
  final ConversionTrigger trigger;
  final VoidCallback? onDismiss;
  final VoidCallback? onConvert;
  final bool showAsDialog;

  const ConversionPrompt({
    super.key,
    required this.trigger,
    this.onDismiss,
    this.onConvert,
    this.showAsDialog = true,
  });

  static Future<bool?> show(
    BuildContext context,
    ConversionTrigger trigger, {
    VoidCallback? onDismiss,
    VoidCallback? onConvert,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConversionPrompt(
        trigger: trigger,
        onDismiss: onDismiss,
        onConvert: onConvert,
      ),
    );
  }

  static Widget buildBottomSheet(
    BuildContext context,
    ConversionTrigger trigger, {
    VoidCallback? onDismiss,
    VoidCallback? onConvert,
  }) {
    return ConversionPrompt(
      trigger: trigger,
      onDismiss: onDismiss,
      onConvert: onConvert,
      showAsDialog: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showAsDialog) {
      return _buildDialog(context);
    } else {
      return _buildBottomSheet(context);
    }
  }

  Widget _buildDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon et titre
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTriggerIcon(),
              size: 40,
              color: const Color(0xFF3860F8),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            trigger.message,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2233),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            trigger.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Avantages de la création de compte
          _buildBenefitsList(),
          
          const SizedBox(height: 24),
          
          // Boutons d'action
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleCreateAccount(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3860F8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    trigger.buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () => _handleDismiss(context),
                child: Text(
                  _getDismissText(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = _getBenefits();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avec un compte, vous pourrez :',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2233),
            ),
          ),
          const SizedBox(height: 12),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: const Color(0xFF009639),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getBenefits() {
    switch (trigger) {
      case ConversionTrigger.afterFavorites:
        return [
          'Synchroniser vos favoris sur tous vos appareils',
          'Recevoir des notifications pour vos lieux préférés',
          'Créer des itinéraires personnalisés',
        ];
      case ConversionTrigger.beforeReservation:
        return [
          'Gérer toutes vos réservations en un endroit',
          'Recevoir des rappels pour vos événements',
          'Accéder à votre historique de réservations',
        ];
      case ConversionTrigger.beforeExport:
        return [
          'Recevoir vos itinéraires par email',
          'Partager vos découvertes avec vos amis',
          'Sauvegarder vos voyages préférés',
        ];
      case ConversionTrigger.afterWeekUsage:
        return [
          'Obtenir des recommandations personnalisées',
          'Accéder à des offres exclusives',
          'Participer à la communauté de voyageurs',
        ];
      case ConversionTrigger.manual:
        return [
          'Profiter de toutes les fonctionnalités',
          'Synchroniser vos données sur tous vos appareils',
          'Recevoir des recommandations personnalisées',
        ];
    }
  }

  IconData _getTriggerIcon() {
    switch (trigger) {
      case ConversionTrigger.afterFavorites:
        return Icons.favorite;
      case ConversionTrigger.beforeReservation:
        return Icons.event_seat;
      case ConversionTrigger.beforeExport:
        return Icons.share;
      case ConversionTrigger.afterWeekUsage:
        return Icons.person;
      case ConversionTrigger.manual:
        return Icons.account_circle;
    }
  }

  String _getDismissText() {
    switch (trigger) {
      case ConversionTrigger.afterFavorites:
        return 'Plus tard';
      case ConversionTrigger.beforeReservation:
        return 'Continuer sans compte';
      case ConversionTrigger.beforeExport:
        return 'Pas maintenant';
      case ConversionTrigger.afterWeekUsage:
        return 'Peut-être plus tard';
      case ConversionTrigger.manual:
        return 'Annuler';
    }
  }

  void _handleCreateAccount(BuildContext context) {
    Navigator.of(context).pop(true);
    
    // Naviguer vers la page de création de compte
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignUpPage(
          fromConversion: true,
          conversionTrigger: trigger,
        ),
      ),
    );
    
    onConvert?.call();
  }

  void _handleDismiss(BuildContext context) {
    Navigator.of(context).pop(false);
    onDismiss?.call();
    
    // Pour certains triggers, marquer comme reporté
    if (trigger == ConversionTrigger.afterFavorites || 
        trigger == ConversionTrigger.afterWeekUsage) {
      _markTriggerDismissed();
    }
  }

  void _markTriggerDismissed() {
    // Marquer ce trigger comme rejeté pour éviter de le montrer à nouveau
    // Cette logique sera implémentée dans AnonymousAuthService
  }
}

/// Widget pour afficher subtilement l'invitation à créer un compte
class SubtleConversionBanner extends StatelessWidget {
  final ConversionTrigger trigger;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const SubtleConversionBanner({
    super.key,
    required this.trigger,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3860F8).withValues(alpha: 0.1),
            const Color(0xFF009639).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3860F8).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              trigger == ConversionTrigger.afterFavorites 
                  ? Icons.favorite 
                  : Icons.account_circle,
              color: const Color(0xFF3860F8),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trigger.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2233),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Créez votre compte en 2 minutes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Bouton d'action
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Créer',
              style: TextStyle(fontSize: 12),
            ),
          ),
          
          // Bouton de fermeture
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                size: 16,
                color: Colors.grey[600],
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}