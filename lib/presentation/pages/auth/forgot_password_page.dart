import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/password_reset_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/utils/responsive.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _getErrorMessage(BuildContext context, String error) {
    switch (error) {
      case 'authErrorEmailNotFound':
        return AppLocalizations.of(context)!.authErrorEmailNotFound;
      case 'authErrorOtpExpired':
        return AppLocalizations.of(context)!.authErrorOtpExpired;
      case 'authErrorInvalidOtp':
        return AppLocalizations.of(context)!.authErrorInvalidOtp;
      case 'authPasswordResetGenericSuccess':
        return AppLocalizations.of(context)!.authPasswordResetGenericSuccess;
      default:
        return error;
    }
  }

  Future<void> _requestOtp() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(passwordResetProvider.notifier)
          .requestOtp(_emailController.text.trim());

      final state = ref.read(passwordResetProvider);

      if (state.otpSent) {
        // Naviguer vers l'écran de saisie OTP
        Navigator.pushNamed(
          context,
          '/reset-password-otp',
          arguments: _emailController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authResetPasswordTitle),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: ResponsiveConstants.largeSpace),
                Icon(
                  Icons.lock_reset,
                  size: 80.w,
                  color: const Color(0xFF3860F8),
                ),
                SizedBox(height: ResponsiveConstants.largeSpace),
                Text(
                  AppLocalizations.of(context)!.authResetPassword,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.headline5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2233),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.smallSpace),
                Text(
                  AppLocalizations.of(context)!.authResetPasswordSubtitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.extraLargeSpace),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.authEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.commonFieldRequired;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(
                        context,
                      )!.eventDetailInvalidEmail;
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),
                if (state.error != null)
                  Container(
                    padding: Responsive.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _getErrorMessage(context, state.error!),
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                SizedBox(height: ResponsiveConstants.mediumSpace),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _requestOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                      padding: Responsive.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: state.isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.authSendResetLink,
                            style: TextStyle(
                              fontSize: ResponsiveConstants.body1,
                              fontWeight: FontWeight.bold,
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
}
