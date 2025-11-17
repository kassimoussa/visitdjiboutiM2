import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import '../../core/models/activity.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../generated/l10n/app_localizations.dart';

class ActivityRegistrationFormWidget extends StatefulWidget {
  final Activity activity;
  final VoidCallback onRegistrationSuccess;

  const ActivityRegistrationFormWidget({
    super.key,
    required this.activity,
    required this.onRegistrationSuccess,
  });

  @override
  State<ActivityRegistrationFormWidget> createState() =>
      _ActivityRegistrationFormWidgetState();
}

class _ActivityRegistrationFormWidgetState
    extends State<ActivityRegistrationFormWidget> {
  final ActivityService _activityService = ActivityService();
  final AnonymousAuthService _authService = AnonymousAuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialRequirementsController =
      TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();

  int _numberOfPeople = 1;
  DateTime? _preferredDate;
  bool _isSubmitting = false;
  bool _isGuestMode = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequirementsController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isGuestMode = !_authService.isLoggedIn;
    });
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _activityService.registerToActivity(
        activityId: widget.activity.id,
        numberOfPeople: _numberOfPeople,
        preferredDate:
            _preferredDate != null ? _preferredDate!.toIso8601String().split('T')[0] : null,
        specialRequirements: _specialRequirementsController.text.isEmpty
            ? null
            : _specialRequirementsController.text,
        medicalConditions: _medicalConditionsController.text.isEmpty
            ? null
            : _medicalConditionsController.text,
        guestName: _isGuestMode ? _nameController.text : null,
        guestEmail: _isGuestMode ? _emailController.text : null,
        guestPhone: _isGuestMode && _phoneController.text.isNotEmpty
            ? _phoneController.text
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onRegistrationSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.activityRegistrationError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        padding: Responsive.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: Responsive.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.activityRegistrationTitle,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.activity.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24.h),

                // Nombre de participants
                Text(
                  AppLocalizations.of(context)!.activityRegistrationNumberOfParticipants,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    IconButton(
                      onPressed: _numberOfPeople > 1
                          ? () => setState(() => _numberOfPeople--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: const Color(0xFF3860F8),
                    ),
                    Container(
                      width: 60.w,
                      padding: Responsive.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '$_numberOfPeople',
                        style: const TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _numberOfPeople++),
                      icon: const Icon(Icons.add_circle_outline),
                      color: const Color(0xFF3860F8),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.of(context)!.activityRegistrationTotal((_numberOfPeople * widget.activity.price).toString()),
                      style: const TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3860F8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Date préférée
                Text(
                  AppLocalizations.of(context)!.activityRegistrationPreferredDate,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: Responsive.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF3860F8)),
                        SizedBox(width: 12.w),
                        Text(
                          _preferredDate != null
                              ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
                              : AppLocalizations.of(context)!.activityRegistrationSelectDate,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _preferredDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Champs invité
                if (_isGuestMode) ...[
                  Text(
                    AppLocalizations.of(context)!.activityRegistrationYourInformation,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.activityRegistrationFullName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.activityRegistrationEnterYourName;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.activityRegistrationEmail,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.activityRegistrationEnterYourEmail;
                      }
                      if (!value.contains('@')) {
                        return AppLocalizations.of(context)!.activityRegistrationInvalidEmail;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.activityRegistrationPhoneOptional,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Exigences spéciales
                Text(
                  AppLocalizations.of(context)!.activityRegistrationSpecialRequirementsOptional,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _specialRequirementsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.activityRegistrationDietAllergiesEtc,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Conditions médicales
                Text(
                  AppLocalizations.of(context)!.activityRegistrationMedicalConditionsOptional,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _medicalConditionsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.activityRegistrationImportantSafetyInfo,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Bouton de soumission
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      padding: Responsive.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                          AppLocalizations.of(context)!.activityRegistrationConfirmRegistration,
                          style: TextStyle(color: Colors.white),
                  ),
                ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3860F8),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _preferredDate) {
      setState(() {
        _preferredDate = picked;
      });
    }
  }
}
