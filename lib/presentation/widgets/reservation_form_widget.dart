import 'package:flutter/material.dart';
import 'package:vd_gem/core/utils/responsive.dart';
import '../../core/models/poi.dart';
import '../../core/models/event.dart';
import '../../core/models/reservation.dart';
import '../../core/models/api_response.dart';
import '../../core/services/reservation_service.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../generated/l10n/app_localizations.dart';

class ReservationFormWidget extends StatefulWidget {
  final Poi? poi;
  final Event? event;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const ReservationFormWidget({
    super.key,
    this.poi,
    this.event,
    this.onSuccess,
    this.onCancel,
  }) : assert(
         poi != null || event != null,
         'Either poi or event must be provided',
       );

  @override
  State<ReservationFormWidget> createState() => _ReservationFormWidgetState();
}

class _ReservationFormWidgetState extends State<ReservationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _reservationService = ReservationService();
  final _authService = AnonymousAuthService();

  final _peopleController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _peopleController.dispose();
    _notesController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isPoi => widget.poi != null;
  bool get _isEvent => widget.event != null;

  String get _title => _isPoi ? widget.poi!.name : widget.event!.title;
  String get _location =>
      _isPoi ? widget.poi!.displayAddress : widget.event!.displayLocation;
  String? get _imageUrl =>
      _isPoi ? widget.poi!.imageUrl : widget.event!.imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          SizedBox(height: 20.h),

          // Form
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildItemPreview(),
                    SizedBox(height: 24.h),
                    _buildPeopleField(),
                    SizedBox(height: 16.h),
                    _buildContactFields(),
                    SizedBox(height: 16.h),
                    _buildNotesField(),
                    SizedBox(height: 24.h),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.reservationFormTitle(
            _isPoi
                ? AppLocalizations.of(context)!.reservationFormTitlePoi
                : AppLocalizations.of(context)!.reservationFormTitleEvent,
          ),
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildItemPreview() {
    return Container(
      padding: Responsive.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _imageUrl?.isNotEmpty == true
                ? Image.network(
                    _imageUrl!,
                    width: 60.w,
                    height: 60.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        _location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_isEvent && widget.event!.price > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    widget.event!.priceText,
                    style: const TextStyle(
                      color: Color(0xFF3860F8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        _isPoi ? Icons.place : Icons.event,
        color: const Color(0xFF3860F8),
        size: 30,
      ),
    );
  }

  Widget _buildPeopleField() {
    return TextFormField(
      controller: _peopleController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.reservationFormNumberOfPeople,
        hintText: AppLocalizations.of(
          context,
        )!.reservationFormNumberOfPeopleHint,
        prefixIcon: const Icon(Icons.people),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      validator: (value) {
        if (value?.isEmpty == true) {
          return AppLocalizations.of(context)!.reservationFormNumberRequired;
        }
        final number = int.tryParse(value!);
        if (number == null || number < 1) {
          return AppLocalizations.of(context)!.reservationFormMinOnePerson;
        }
        // Valider seulement si maxParticipants ET availableSpots sont définis (pas null)
        // Si null, cela signifie qu'il n'y a pas de limite
        if (_isEvent &&
            widget.event!.maxParticipants != null &&
            widget.event!.availableSpots != null &&
            widget.event!.availableSpots! > 0) {
          final available = widget.event!.availableSpots!;
          if (number > available) {
            return AppLocalizations.of(
              context,
            )!.reservationFormMaxPeople(available.toString());
          }
        }
        return null;
      },
    );
  }

  Widget _buildContactFields() {
    // Ne pas afficher les champs de contact si l'utilisateur est connecté
    if (_authService.isLoggedIn) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.reservationFormContactInfo,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.reservationFormFullName,
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.commonEmail,
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value?.isNotEmpty == true &&
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return AppLocalizations.of(context)!.reservationFormEmailInvalid;
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.reservationFormPhone,
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.reservationFormNotes,
        hintText: AppLocalizations.of(context)!.reservationFormNotesHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: Responsive.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
              padding: Responsive.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.reservationFormConfirm,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final numberOfPeople = int.parse(_peopleController.text);

      print('[FORM] Calling reservation service...');
      ApiResponse<Reservation> response;

      if (_isPoi) {
        print('[FORM] Making POI reservation for ${widget.poi!.name}');
        response = await _reservationService.reservePoi(
          widget.poi!,
          people: numberOfPeople,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          userName: _nameController.text.isNotEmpty
              ? _nameController.text
              : null,
          userEmail: _emailController.text.isNotEmpty
              ? _emailController.text
              : null,
          userPhone: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : null,
        );
      } else {
        print('[FORM] Making Event reservation for ${widget.event!.title}');
        response = await _reservationService.reserveEvent(
          widget.event!,
          people: numberOfPeople,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          userName: _nameController.text.isNotEmpty
              ? _nameController.text
              : null,
          userEmail: _emailController.text.isNotEmpty
              ? _emailController.text
              : null,
          userPhone: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : null,
        );
      }

      print(
        '[FORM] Response received: success=${response.isSuccess}, message=${response.message}',
      );

      if (mounted) {
        if (response.isSuccess) {
          print('[FORM] Success! Showing snackbar and navigating to home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ??
                    AppLocalizations.of(context)!.reservationFormSuccess,
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Fermer le formulaire
          Navigator.of(context).pop();

          // Appeler le callback onSuccess si fourni
          if (widget.onSuccess != null) {
            print('[FORM] Calling onSuccess callback');
            widget.onSuccess!();
          }

          // Naviguer vers l'écran d'accueil après un court délai
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              print('[FORM] Navigating to home screen');
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
        } else {
          print('[FORM] Error: ${response.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ??
                    AppLocalizations.of(context)!.reservationFormError,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('[FORM] Widget not mounted, skipping UI updates');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.reservationsError(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
