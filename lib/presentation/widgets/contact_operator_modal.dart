import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../core/services/comment_service.dart';
import '../../generated/l10n/app_localizations.dart';

/// Modal pour contacter un opérateur/administration
/// Les commentaires ne sont PAS affichés dans l'app mais envoyés aux opérateurs
class ContactOperatorModal extends StatefulWidget {
  final String resourceType;
  final int resourceId;
  final String? operatorName;

  const ContactOperatorModal({
    super.key,
    required this.resourceType,
    required this.resourceId,
    this.operatorName,
  });

  @override
  State<ContactOperatorModal> createState() => _ContactOperatorModalState();
}

class _ContactOperatorModalState extends State<ContactOperatorModal> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _commentService = CommentService();

  String _messageType = 'question'; // question, report, suggestion
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: Responsive.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: Responsive.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(
                    Icons.email,
                    color: Color(0xFF3860F8),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Contacter ${widget.operatorName ?? 'l\'opérateur'}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Type de message
            Text(
              'Type de message',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 12.h),
            _buildMessageTypeChips(),
            SizedBox(height: 24.h),

            // Message
            Text(
              'Votre message',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Écrivez votre message ici...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFF3860F8), width: 2.w),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez écrire un message';
                }
                if (value.trim().length < 3) {
                  return 'Le message doit contenir au moins 3 caractères';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: Responsive.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.commonCancel),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                      padding: Responsive.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Envoyer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTypeChips() {
    return Row(
      children: [
        Expanded(
          child: _buildChip('Question', 'question', Icons.help_outline),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildChip('Signalement', 'report', Icons.flag_outlined),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildChip('Suggestion', 'suggestion', Icons.lightbulb_outline),
        ),
      ],
    );
  }

  Widget _buildChip(String label, String value, IconData icon) {
    final isSelected = _messageType == value;
    return InkWell(
      onTap: () => setState(() => _messageType = value),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: Responsive.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3860F8) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF3860F8) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Préfixer le message avec le type
      final messagePrefix = {
        'question': '❓ Question: ',
        'report': '⚠️ Signalement: ',
        'suggestion': '💡 Suggestion: ',
      }[_messageType] ?? '';

      final fullMessage = '$messagePrefix${_messageController.text.trim()}';

      await _commentService.sendMessage(
        commentableType: widget.resourceType,
        commentableId: widget.resourceId,
        comment: fullMessage,
      );

      if (mounted) {
        // Fermer le modal en retournant true pour indiquer le succès
        Navigator.pop(context, true);

        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Message envoyé avec succès à ${widget.operatorName ?? 'l\'opérateur'}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.commonErrorSending(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
