import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../../providers/password_reset_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/utils/responsive.dart';

class ResetPasswordOtpPage extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordOtpPage({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<ResetPasswordOtpPage> createState() =>
      _ResetPasswordOtpPageState();
}

class _ResetPasswordOtpPageState extends ConsumerState<ResetPasswordOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      case 'authErrorPasswordMismatch':
        return AppLocalizations.of(context)!.authErrorPasswordMismatch;
      default:
        return error;
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(passwordResetProvider.notifier)
          .resetPassword(
            email: widget.email,
            otp: _otpController.text,
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
          );

      if (success && mounted) {
        // Mot de passe réinitialisé avec succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.authSuccessTitle),
            backgroundColor: Colors.green,
          ),
        );

        // Naviguer vers l'écran principal (l'utilisateur est déjà connecté)
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    Responsive.init(context);

    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1D2233),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authResetPassword),
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
                SizedBox(height: ResponsiveConstants.mediumSpace),
                Icon(
                  Icons.verified_user,
                  size: 80.w,
                  color: const Color(0xFF3860F8),
                ),
                SizedBox(height: ResponsiveConstants.largeSpace),
                Text(
                  AppLocalizations.of(context)!.authPasswordResetGenericSuccess,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.extraLargeSpace),
                Text(
                  AppLocalizations.of(context)!.authCodeSent,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.smallSpace),
                Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF3860F8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.commonFieldRequired;
                    }
                    if (value.length != 6) {
                      return AppLocalizations.of(
                        context,
                      )!.authErrorInvalidCodeLength;
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),
                if (state.remainingAttempts != null)
                  Container(
                    padding: Responsive.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade900),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.authRemainingAttempts(state.remainingAttempts!),
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: ResponsiveConstants.largeSpace),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.authPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.commonFieldRequired;
                    }
                    if (value.length < 8) {
                      return AppLocalizations.of(
                        context,
                      )!.authErrorPasswordTooShort;
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.authConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.commonFieldRequired;
                    }
                    if (value != _passwordController.text) {
                      return AppLocalizations.of(
                        context,
                      )!.authErrorPasswordMismatch;
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),
                if (state.error != null)
                  Container(
                    padding: Responsive.all(12),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _getErrorMessage(context, state.error!),
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _resetPassword,
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
                          AppLocalizations.of(context)!.authResetPassword,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(passwordResetProvider.notifier)
                        .requestOtp(widget.email);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.authResetEmailSent,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.authResendCode,
                    style: const TextStyle(
                      color: Color(0xFF3860F8),
                      fontWeight: FontWeight.w600,
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
