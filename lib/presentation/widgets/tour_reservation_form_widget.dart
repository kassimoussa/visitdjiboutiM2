import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/tour.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../generated/l10n/app_localizations.dart';

class TourReservationFormWidget extends StatefulWidget {
  final Tour tour;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const TourReservationFormWidget({
    super.key,
    required this.tour,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<TourReservationFormWidget> createState() => _TourReservationFormWidgetState();
}

class _TourReservationFormWidgetState extends State<TourReservationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _tourService = TourService();
  final _authService = AnonymousAuthService();

  final _peopleController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _peopleController.dispose();
    _notesController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _checkAuthStatus() {
    _isAuthenticated = _authService.isLoggedIn;
  }

  int get _numberOfPeople => int.tryParse(_peopleController.text) ?? 1;
  int get _maxParticipants => widget.tour.availableSpots;
  int get _totalAmount => widget.tour.price * _numberOfPeople;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 20),

          // Form
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTourPreview(),
                    const SizedBox(height: 24),
                    _buildPeopleField(),
                    const SizedBox(height: 16),
                    if (!_isAuthenticated) ...[
                      _buildContactFields(),
                      const SizedBox(height: 16),
                    ],
                    _buildNotesField(),
                    const SizedBox(height: 16),
                    _buildTotalSection(),
                    const SizedBox(height: 24),
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
          AppLocalizations.of(context)!.tourRegistrationTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildTourPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.tour.hasImages
                ? CachedNetworkImage(
                    imageUrl: widget.tour.firstImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tour.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (widget.tour.displayDateRange != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.tour.displayDateRange!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.tourRegistrationAvailableSpots(widget.tour.availableSpots.toString()),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.tour,
        color: Color(0xFF3860F8),
        size: 30,
      ),
    );
  }

  Widget _buildPeopleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.tourRegistrationNumberOfParticipants,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Bouton moins
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _numberOfPeople > 1
                    ? () {
                        setState(() {
                          _peopleController.text = (_numberOfPeople - 1).toString();
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove),
                color: _numberOfPeople > 1 ? const Color(0xFF3860F8) : Colors.grey,
              ),
            ),

            // Champ de texte
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _peopleController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    suffix: Text(
                      '(max: $_maxParticipants)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return AppLocalizations.of(context)!.commonFieldRequired;
                    }
                    final number = int.tryParse(value!);
                    if (number == null || number < 1) {
                      return AppLocalizations.of(context)!.tourRegistrationMinParticipants;
                    }
                    if (number > _maxParticipants) {
                      return AppLocalizations.of(context)!.tourRegistrationMaxParticipants(_maxParticipants.toString());
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {}); // Refresh pour recalculer le total
                  },
                ),
              ),
            ),

            // Bouton plus
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _numberOfPeople < _maxParticipants
                    ? () {
                        setState(() {
                          _peopleController.text = (_numberOfPeople + 1).toString();
                        });
                      }
                    : null,
                icon: const Icon(Icons.add),
                color: _numberOfPeople < _maxParticipants
                    ? const Color(0xFF3860F8)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.tourRegistrationContactInfo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.tourRegistrationFullName,
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.tourRegistrationNameRequired : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.tourRegistrationEmail,
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return AppLocalizations.of(context)!.tourRegistrationEmailRequired;
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return AppLocalizations.of(context)!.tourRegistrationInvalidEmail;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.tourRegistrationPhone,
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            ),
          validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.tourRegistrationPhoneRequired : null,
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.tourRegistrationNotes,
        hintText: AppLocalizations.of(context)!.tourRegistrationNotesHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3860F8).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.tourRegistrationTotalToPay,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$_numberOfPeople × ${widget.tour.displayPrice}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            '$_totalAmount ${widget.tour.currency}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3860F8),
            ),
          ),
        ],
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                    AppLocalizations.of(context)!.tourRegistrationConfirm,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
      print('[TOUR FORM] Submitting reservation...');
      final response = await _tourService.createReservation(
        tourId: widget.tour.id,
        numberOfPeople: _numberOfPeople,
        guestName: !_isAuthenticated ? _nameController.text : null,
        guestEmail: !_isAuthenticated ? _emailController.text : null,
        guestPhone: !_isAuthenticated ? _phoneController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      print('[TOUR FORM] Response received: ${response.success}');

      if (mounted) {
        if (response.success) {
          print('[TOUR FORM] Success! Showing snackbar and navigating to home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? AppLocalizations.of(context)!.tourRegistrationSuccessMessage),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Fermer le formulaire
          Navigator.of(context).pop();

          // Appeler le callback onSuccess si fourni
          if (widget.onSuccess != null) {
            print('[TOUR FORM] Calling onSuccess callback');
            widget.onSuccess!();
          }

          // Naviguer vers l'écran d'accueil après un court délai
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              print('[TOUR FORM] Navigating to home screen');
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
        } else {
          print('[TOUR FORM] Error: ${response.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? AppLocalizations.of(context)!.tourRegistrationErrorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('[TOUR FORM] Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.commonUnexpectedError}: ${e.toString()}'),
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
