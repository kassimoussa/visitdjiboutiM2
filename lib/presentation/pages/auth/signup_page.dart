import 'package:flutter/material.dart';
import '../../../core/models/anonymous_user.dart';
import '../../../core/services/anonymous_auth_service.dart';
import '../../../generated/l10n/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  final bool fromConversion;
  final ConversionTrigger? conversionTrigger;

  const SignUpPage({
    super.key,
    this.fromConversion = false,
    this.conversionTrigger,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AnonymousAuthService _authService = AnonymousAuthService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fromConversion ? AppLocalizations.of(context)!.authRegister : AppLocalizations.of(context)!.authRegister),
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
                const SizedBox(height: 32),
                
                Text(
                  _authService.isAnonymousUser
                      ? AppLocalizations.of(context)!.authKeepDiscoveries
                      : AppLocalizations.of(context)!.authWelcomeToApp,
                  style:  TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2233),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _authService.isAnonymousUser
                      ? AppLocalizations.of(context)!.authCreateAccountDescription
                      : AppLocalizations.of(context)!.appDescription,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Formulaire
                _buildForm(),
                
                const SizedBox(height: 24),
                
                // Conditions d'utilisation
                _buildTermsCheckbox(),
                
                const SizedBox(height: 24),

                // Bouton d'inscription
                _buildSignUpButton(),

                const SizedBox(height: 24),
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
        // Nom complet
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.authName,
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le nom est requis';
            }
            if (value!.length < 2) {
              return 'Le nom doit contenir au moins 2 caractères';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
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
        
        const SizedBox(height: 16),
        
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
            if (value!.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Confirmation mot de passe
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.authConfirmPassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'La confirmation est requise';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) => setState(() => _acceptTerms = value ?? false),
          activeColor: const Color(0xFF3860F8),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '${AppLocalizations.of(context)!.authAcceptTerms} ',
              style: TextStyle(color: Colors.grey[700]),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/terms-conditions');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.authTermsAndConditions,
                      style: const TextStyle(
                        color: Color(0xFF3860F8),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: ' ${AppLocalizations.of(context)!.authAcceptTermsAnd} '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/privacy-policy');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.authPrivacyPolicy,
                      style: const TextStyle(
                        color: Color(0xFF3860F8),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _acceptTerms && !_isLoading ? _handleSignUp : null,
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
                AppLocalizations.of(context)!.authCreateAccount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }


  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Dans un onboarding frictionless, nous avons TOUJOURS un utilisateur anonyme
      // Donc nous faisons toujours une conversion, jamais une nouvelle inscription
      if (_authService.isAnonymousUser) {
        // Convertir l'utilisateur anonyme en compte complet
        final request = ConvertAnonymousRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          preserveData: true,
        );
        
        final response = await _authService.convertToFullUser(request);
        
        if (response.isSuccess) {
          _showSimpleSuccessDialog();
        } else {
          // Si la conversion échoue à cause d'une erreur serveur,
          // proposer une inscription normale comme fallback
          if (response.message?.contains('500') == true) {
            _showConversionErrorDialog(response.message ?? 'Erreur lors de la conversion');
          } else {
            _showErrorDialog(response.message ?? 'Erreur lors de la conversion');
          }
        }
      } else {
        // Cas exceptionnel : pas d'utilisateur anonyme, créer un nouvel utilisateur
        // (Normalement ne devrait pas arriver dans un frictionless onboarding)
        final response = await _authService.registerUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );
        
        if (response.isSuccess) {
          _showSimpleSuccessDialog();
        } else {
          _showErrorDialog(response.message ?? 'Erreur lors de l\'inscription');
        }
      }
    } catch (e) {
      _showErrorDialog('Une erreur inattendue s\'est produite: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSimpleSuccessDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compte créé avec succès ! Connexion automatique...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Naviguer vers l'écran d'accueil après un court délai pour montrer le snackbar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // L'utilisateur est déjà connecté automatiquement par le service
        // Naviguer vers l'écran d'accueil
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }
  
  void _showSuccessDialog({bool isConversion = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isConversion
              ? 'Compte créé avec succès ! Données préservées. Connexion automatique...'
              : 'Compte créé avec succès ! Connexion automatique...',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Naviguer vers l'écran d'accueil après un court délai
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // L'utilisateur est déjà connecté automatiquement par le service
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  void _showConversionErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.orange,
          size: 48,
        ),
        title: Text(AppLocalizations.of(context)!.authConversionProblemTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'Voulez-vous essayer une inscription normale ? Vous devrez rajouter vos favoris manuellement.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleNormalSignUp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.authRegister),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNormalSignUp() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _authService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
      
      if (response.isSuccess) {
        _showSuccessDialog(isConversion: false);
      } else {
        _showErrorDialog(response.message ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      _showErrorDialog('Une erreur inattendue s\'est produite: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}