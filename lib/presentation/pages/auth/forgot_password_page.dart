import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authResetPassword),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveConstants.extraLargeSpace),

                // Logo
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo_visitdjibouti.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.lock_reset,
                          color: Color(0xFF3860F8),
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveConstants.extraLargeSpace),

                Text(
                  AppLocalizations.of(context)!.authResetPasswordTitle,
                  style: const TextStyle(
                    fontSize: ResponsiveConstants.headline5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2233),
                  ),
                ),

                SizedBox(height: ResponsiveConstants.smallSpace),

                Text(
                  AppLocalizations.of(context)!.authResetPasswordSubtitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: ResponsiveConstants.extraLargeSpace),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.authEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'L\'email est requis';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return AppLocalizations.of(context)!.eventDetailInvalidEmail;
                    }
                    return null;
                  },
                ),

                SizedBox(height: ResponsiveConstants.extraLargeSpace),

                // Send reset link button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !_isLoading ? _handleResetPassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.authSendResetLink,
                            style: const TextStyle(
                              fontSize: ResponsiveConstants.body1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: ResponsiveConstants.largeSpace),

                // Back to login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.authBackToLogin,
                      style: const TextStyle(
                        color: Color(0xFF3860F8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implémenter l'appel API pour la réinitialisation du mot de passe
      // await _authService.resetPassword(email: _emailController.text.trim());

      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Une erreur inattendue s\'est produite: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.mark_email_read,
          color: Color(0xFF009639),
          size: 48,
        ),
        title: Text(AppLocalizations.of(context)!.authResetEmailSent),
        content: Text(
          AppLocalizations.of(context)!.authResetEmailSentMessage,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.commonOk),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.authErrorTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.commonOk),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
