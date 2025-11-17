import 'package:flutter/material.dart';
import '../../../core/services/anonymous_auth_service.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AnonymousAuthService _authService = AnonymousAuthService();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authLogin),
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
                SizedBox(height: ResponsiveConstants.largeSpace),

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
                          Icons.travel_explore,
                          color: Color(0xFF3860F8),
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveConstants.extraLargeSpace),

                Text(
                  AppLocalizations.of(context)!.authWelcomeBack,
                  style: const TextStyle(
                    fontSize: ResponsiveConstants.headline5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2233),
                  ),
                ),

                SizedBox(height: ResponsiveConstants.smallSpace),

                Text(
                  AppLocalizations.of(context)!.authSignInSubtitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: ResponsiveConstants.extraLargeSpace),
                
                // Formulaire
                _buildForm(),
                
                SizedBox(height: ResponsiveConstants.mediumSpace),
                
                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.authForgotPassword,
                      style: const TextStyle(
                        color: Color(0xFF3860F8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveConstants.largeSpace),
                
                // Bouton de connexion
                _buildLoginButton(),

                SizedBox(height: ResponsiveConstants.largeSpace),

                // Lien vers inscription
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Email
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
        
        SizedBox(height: ResponsiveConstants.mediumSpace),
        
        // Mot de passe
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.authPassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le mot de passe est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !_isLoading ? _handleLogin : null,
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
                AppLocalizations.of(context)!.authSignIn,
                style: const TextStyle(
                  fontSize: ResponsiveConstants.body1,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/signup');
        },
        child: Text.rich(
          TextSpan(
            text: '${AppLocalizations.of(context)!.authNoAccount} ',
            style: TextStyle(color: Colors.grey[600]),
            children: [
              TextSpan(
                text: AppLocalizations.of(context)!.authRegister,
                style: const TextStyle(
                  color: Color(0xFF3860F8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (response.isSuccess) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(response.message ?? 'Erreur lors de la connexion');
      }
    } catch (e) {
      _showErrorDialog('Une erreur inattendue s\'est produite: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF009639),
          size: 48,
        ),
        title: Text(AppLocalizations.of(context)!.authSuccessTitle),
        content: Text(
          AppLocalizations.of(context)!.authWelcomeBack,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/main',
                (route) => false,
              );
            },
            child: Text(AppLocalizations.of(context)!.commonNext),
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
    _passwordController.dispose();
    super.dispose();
  }
}