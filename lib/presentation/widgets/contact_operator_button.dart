import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
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
}
