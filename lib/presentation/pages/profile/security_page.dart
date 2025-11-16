import 'package:flutter/material.dart';
import '../../../core/services/anonymous_auth_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../generated/l10n/app_localizations.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final AnonymousAuthService _authService = AnonymousAuthService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileSecurity),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
        child: _buildPasswordSection(),
      ),
    );
  }


  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.securityChangePassword,
          style: TextStyle(
            fontSize: ResponsiveConstants.subtitle1,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2233),
          ),
        ),
        
        SizedBox(height: ResponsiveConstants.mediumSpace),
        
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                label: AppLocalizations.of(context)!.securityCurrentPassword,
                controller: _currentPasswordController,
                isVisible: _showCurrentPassword,
                onToggleVisibility: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.securityCurrentPasswordRequired;
                  }
                  return null;
                },
              ),
              
              SizedBox(height: ResponsiveConstants.mediumSpace),
              
              _buildPasswordField(
                label: AppLocalizations.of(context)!.securityNewPassword,
                controller: _newPasswordController,
                isVisible: _showNewPassword,
                onToggleVisibility: () => setState(() => _showNewPassword = !_showNewPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.securityNewPasswordRequired;
                  }
                  if (value.length < 8) {
                    return AppLocalizations.of(context)!.securityPasswordMinLength;
                  }
                  return null;
                },
              ),
              
              SizedBox(height: ResponsiveConstants.mediumSpace),
              
              _buildPasswordField(
                label: AppLocalizations.of(context)!.securityConfirmPassword,
                controller: _confirmPasswordController,
                isVisible: _showConfirmPassword,
                onToggleVisibility: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.securityConfirmPasswordRequired;
                  }
                  if (value != _newPasswordController.text) {
                    return AppLocalizations.of(context)!.securityPasswordMismatch;
                  }
                  return null;
                },
              ),
              
              SizedBox(height: ResponsiveConstants.largeSpace),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePasswordChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3860F8),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mediumSpace),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: ResponsiveConstants.mediumIcon,
                          width: ResponsiveConstants.mediumIcon,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.securityChangePassword,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveConstants.body1,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D2233),
          ),
        ),
        
        SizedBox(height: ResponsiveConstants.smallSpace),
        
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3860F8)),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              borderSide: const BorderSide(color: Color(0xFF3860F8), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mediumSpace,
              vertical: ResponsiveConstants.mediumSpace,
            ),
          ),
        ),
      ],
    );
  }




  Future<void> _handlePasswordChange() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Appeler l'API pour changer le mot de passe
      final response = await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (response.isSuccess) {
        // Effacer les champs
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.securityPasswordChanged),
              backgroundColor: const Color(0xFF009639),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message?.toString() ?? AppLocalizations.of(context)!.securityPasswordChangeError),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.securityError(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

}