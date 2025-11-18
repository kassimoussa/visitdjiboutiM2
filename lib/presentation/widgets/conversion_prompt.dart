import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../core/models/anonymous_user.dart';
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
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: Responsive.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon et titre
          Container(
            width: 80.w,
            height: 80.h,
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
          
          SizedBox(height: 20.h),
          
          Text(
            trigger.message,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2233),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 12.h),
          
          Text(
            trigger.description,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 24.h),
          
          // Avantages de la création de compte
          _buildBenefitsList(),
          
          SizedBox(height: 24.h),
          
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
                    padding: Responsive.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    trigger.buttonText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              TextButton(
                onPressed: () => _handleDismiss(context),
                child: Text(
                  _getDismissText(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
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
      padding: Responsive.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avec un compte, vous pourrez :',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2233),
            ),
          ),
          SizedBox(height: 12.h),
          ...benefits.map((benefit) => Padding(
            padding: Responsive.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: const Color(0xFF009639),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 13.sp,
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
      margin: Responsive.all(16),
      padding: Responsive.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3860F8).withValues(alpha: 0.1),
            const Color(0xFF009639).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF3860F8).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
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
          
          SizedBox(width: 12.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trigger.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2233),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Créez votre compte en 2 minutes',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 8.w),
          
          // Bouton d'action
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
              padding: Responsive.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Créer',
              style: TextStyle(fontSize: 12.sp),
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