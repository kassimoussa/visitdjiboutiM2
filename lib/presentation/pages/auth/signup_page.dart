import 'dart:async';
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
                
                // Séparateur
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppLocalizations.of(context)!.authOr,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // OAuth buttons
                _buildOAuthButtons(),
                
                const SizedBox(height: 24),
                
                // Lien vers connexion
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversionHeader() {
    final trigger = widget.conversionTrigger!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3860F8).withValues(alpha: 0.1),
            const Color(0xFF009639).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              trigger == ConversionTrigger.afterFavorites 
                  ? Icons.favorite 
                  : Icons.account_circle,
              color: const Color(0xFF3860F8),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trigger.message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2233),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.authDataPreserved,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionBenefits() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.authKeepingDataInfo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2233),
            ),
          ),
          const SizedBox(height: 12),
          
          // Afficher les bénéfices basés sur l'état réel de l'utilisateur anonyme
          _buildBenefitItem(Icons.favorite, AppLocalizations.of(context)!.authCurrentFavorites),
          
          _buildBenefitItem(Icons.settings, AppLocalizations.of(context)!.authPreferences),
          _buildBenefitItem(Icons.history, AppLocalizations.of(context)!.authBrowsingHistory),
          _buildBenefitItem(Icons.location_on, AppLocalizations.of(context)!.authDiscoveredPlaces),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF009639),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAPIStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'La conversion peut échouer temporairement. Une inscription normale sera proposée en cas d\'erreur.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
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
            labelText: 'Nom complet',
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
            labelText: 'Email',
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
              return 'Email invalide';
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
            labelText: 'Mot de passe',
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
            labelText: 'Confirmer le mot de passe',
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
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: Text.rich(
              TextSpan(
                text: 'J\'accepte les ',
                style: TextStyle(color: Colors.grey[700]),
                children: [
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: TextStyle(
                      color: const Color(0xFF3860F8),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' et la '),
                  TextSpan(
                    text: 'politique de confidentialité',
                    style: TextStyle(
                      color: const Color(0xFF3860F8),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
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
                _authService.isAnonymousUser ? 'Sauvegarder mes découvertes' : 'Créer mon compte',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildOAuthButtons() {
    return Column(
      children: [
        // Google Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleSignUp,
            icon: Image.asset(
              'assets/images/google_logo.png',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
            ),
            label: const Text('Continuer avec Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Facebook Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleFacebookSignUp,
            icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
            label: const Text('Continuer avec Facebook'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Naviguer vers la page de connexion
          Navigator.of(context).pushReplacementNamed('/login');
        },
        child: Text.rich(
          TextSpan(
            text: 'Vous avez déjà un compte ? ',
            style: TextStyle(color: Colors.grey[600]),
            children: [
              TextSpan(
                text: 'Se connecter',
                style: TextStyle(
                  color: const Color(0xFF3860F8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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

  Future<void> _handleGoogleSignUp() async {
    // À implémenter avec Google Sign In
    _showErrorDialog('Connexion Google pas encore implémentée');
  }

  Future<void> _handleFacebookSignUp() async {
    // À implémenter avec Facebook Login
    _showErrorDialog('Connexion Facebook pas encore implémentée');
  }

  void _showSimpleSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF009639),
          size: 48,
        ),
        title: Text(AppLocalizations.of(context)!.authSignUpSuccessTitle),
        content: const Text(
          'Votre compte a été créé avec succès !',
        ),
      ),
    );
    
    // Fermer automatiquement après 5 secondes et retourner à l'écran principal
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialogue
        Navigator.of(context).pushReplacementNamed('/main'); // Retourner à l'écran principal
      }
    });
  }
  
  void _showSuccessDialog({bool isConversion = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF009639),
          size: 48,
        ),
        title: Text(isConversion ? 'Conversion réussie !' : 'Compte créé !'),
        content: Text(
          isConversion 
              ? 'Votre compte a été créé avec succès. Toutes vos données ont été préservées.'
              : 'Bienvenue sur Visit Djibouti ! Votre compte a été créé avec succès.',
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
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
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
            child: const Text('Annuler'),
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
            child: const Text('Inscription normale'),
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