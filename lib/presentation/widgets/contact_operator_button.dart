import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../core/services/anonymous_auth_service.dart';
import 'contact_operator_modal.dart';

/// Bouton pour contacter un opérateur/administration
/// À placer dans l'AppBar à côté du bouton favoris
class ContactOperatorButton extends StatelessWidget {
  final String resourceType;
  final int resourceId;
  final String? operatorName;
  final Color? iconColor;
  final VoidCallback? onMessageSent;

  const ContactOperatorButton({
    super.key,
    required this.resourceType,
    required this.resourceId,
    this.operatorName,
    this.iconColor,
    this.onMessageSent,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.message_outlined,
        color: iconColor ?? Colors.white,
      ),
      tooltip: 'Contacter ${operatorName ?? 'l\'opérateur'}',
      onPressed: () => _showContactModal(context),
    );
  }

  void _showContactModal(BuildContext context) async {
    final authService = AnonymousAuthService();

    // Vérifier si l'utilisateur est connecté AVANT d'ouvrir le modal
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog(context);
      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: Responsive.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ContactOperatorModal(
          resourceType: resourceType,
          resourceId: resourceId,
          operatorName: operatorName,
        ),
      ),
    );

    // Si le message a été envoyé avec succès, appeler le callback
    if (result == true && onMessageSent != null) {
      onMessageSent!();
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: Color(0xFF3860F8),
              size: 28,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Connexion requise',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pour laisser un commentaire, vous devez être connecté.',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: Responsive.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF3860F8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF3860F8),
                    size: 20,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Créez un compte ou connectez-vous pour contacter l\'opérateur.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF3860F8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Naviguer vers la page de connexion/inscription
              // Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3860F8),
              foregroundColor: Colors.white,
              padding: Responsive.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Se connecter',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
