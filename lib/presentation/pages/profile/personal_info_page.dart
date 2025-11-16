import 'package:flutter/material.dart';
import '../../../core/services/anonymous_auth_service.dart';
import '../../../core/models/anonymous_user.dart';
import '../../../core/utils/responsive.dart';
import '../../../generated/l10n/app_localizations.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final AnonymousAuthService _authService = AnonymousAuthService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isEditing = false;
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _nameController = TextEditingController(text: _user?.name ?? '');
    _emailController = TextEditingController(text: _user?.email ?? '');
    _phoneController = TextEditingController(text: _user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profilePersonalInfo),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              tooltip: AppLocalizations.of(context)!.profileEditTooltip,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    
                    SizedBox(height: ResponsiveConstants.largeSpace),
                    
                    _buildInfoSection(),
                    
                    if (_isEditing) ...[
                      SizedBox(height: ResponsiveConstants.extraLargeSpace),
                      _buildActionButtons(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: ResponsiveConstants.extraLargeIcon + 16.w,
            backgroundColor: const Color(0xFF3860F8).withOpacity(0.1),
            child: Text(
              _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : '👤',
              style: TextStyle(
                fontSize: ResponsiveConstants.headline5,
                color: const Color(0xFF3860F8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.mediumSpace),
          
          Text(
            _user?.name ?? AppLocalizations.of(context)!.personalInfoUser,
            style: TextStyle(
              fontSize: ResponsiveConstants.headline6,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2233),
            ),
          ),
          
          Text(
            _user?.email ?? '',
            style: TextStyle(
              fontSize: ResponsiveConstants.body1,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.smallSpace),
          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.smallSpace * 1.5,
              vertical: ResponsiveConstants.tinySpace,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF009639).withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Text(
              AppLocalizations.of(context)!.personalInfoVerifiedAccount,
              style: TextStyle(
                fontSize: ResponsiveConstants.caption,
                color: const Color(0xFF009639),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.personalInfoBasicInfo,
          style: TextStyle(
            fontSize: ResponsiveConstants.subtitle1,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2233),
          ),
        ),
        
        SizedBox(height: ResponsiveConstants.mediumSpace),
        
        _buildInfoField(
          label: AppLocalizations.of(context)!.personalInfoFullName,
          controller: _nameController,
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context)!.personalInfoNameRequired;
            }
            if (value.trim().length < 2) {
              return AppLocalizations.of(context)!.personalInfoNameMinLength;
            }
            return null;
          },
        ),
        
        SizedBox(height: ResponsiveConstants.mediumSpace),
        
        _buildInfoField(
          label: AppLocalizations.of(context)!.personalInfoEmail,
          controller: _emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context)!.personalInfoEmailRequired;
            }
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
            if (!emailRegex.hasMatch(value.trim())) {
              return AppLocalizations.of(context)!.personalInfoEmailInvalid;
            }
            return null;
          },
        ),
        
        SizedBox(height: ResponsiveConstants.mediumSpace),
        
        _buildInfoField(
          label: AppLocalizations.of(context)!.personalInfoPhoneOptional,
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
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
          enabled: _isEditing,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF3860F8)),
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey[50],
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              borderSide: BorderSide(color: Colors.grey[200]!),
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


  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleCancel,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mediumSpace),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            child: Text(
              AppLocalizations.of(context)!.commonCancel,
              style: TextStyle(
                fontSize: ResponsiveConstants.body1,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        
        SizedBox(width: ResponsiveConstants.mediumSpace),
        
        Expanded(
          child: ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mediumSpace),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.commonSave,
              style: TextStyle(
                fontSize: ResponsiveConstants.body1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _handleCancel() {
    setState(() {
      _isEditing = false;
      // Restaurer les valeurs originales
      _nameController.text = _user?.name ?? '';
      _emailController.text = _user?.email ?? '';
      _phoneController.text = _user?.phone ?? '';
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Créer un objet avec les nouvelles données
      final updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      // Appeler l'API pour mettre à jour le profil
      final response = await _authService.updateProfile(updatedData);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _user = response.data;
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.personalInfoProfileUpdated),
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
              content: Text(response.message?.toString() ?? AppLocalizations.of(context)!.personalInfoUpdateError),
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
            content: Text(AppLocalizations.of(context)!.personalInfoError(e.toString())),
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