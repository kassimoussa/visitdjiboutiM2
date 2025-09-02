import 'package:flutter/material.dart';
import '../../core/models/poi.dart';
import '../../core/models/event.dart';
import '../../core/models/reservation.dart';
import '../../core/models/api_response.dart';
import '../../core/services/reservation_service.dart';
import '../../core/services/anonymous_auth_service.dart';

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
  }) : assert(poi != null || event != null, 'Either poi or event must be provided');

  @override
  State<ReservationFormWidget> createState() => _ReservationFormWidgetState();
}

class _ReservationFormWidgetState extends State<ReservationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _reservationService = ReservationService();
  final _authService = AnonymousAuthService();

  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _peopleController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
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
  String get _location => _isPoi ? widget.poi!.displayAddress : widget.event!.displayLocation;
  String? get _imageUrl => _isPoi ? widget.poi!.imageUrl : widget.event!.imageUrl;

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
                    _buildItemPreview(),
                    const SizedBox(height: 24),
                    _buildDateTimeFields(),
                    const SizedBox(height: 16),
                    _buildPeopleField(),
                    const SizedBox(height: 16),
                    _buildContactFields(),
                    const SizedBox(height: 16),
                    _buildNotesField(),
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
          'Réserver ${_isPoi ? 'ce lieu' : 'cet événement'}',
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

  Widget _buildItemPreview() {
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
            child: _imageUrl?.isNotEmpty == true
                ? Image.network(
                    _imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
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
                  _title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _location,
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
                if (_isEvent && widget.event!.price > 0) ...[
                  const SizedBox(height: 4),
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
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _isPoi ? Icons.place : Icons.event,
        color: const Color(0xFF3860F8),
        size: 30,
      ),
    );
  }

  Widget _buildDateTimeFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: _selectDate,
            decoration: InputDecoration(
              labelText: 'Date *',
              hintText: 'Sélectionner une date',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty == true) {
                return 'Date requise';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _timeController,
            readOnly: true,
            onTap: _selectTime,
            decoration: InputDecoration(
              labelText: 'Heure',
              hintText: 'HH:MM',
              prefixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleField() {
    return TextFormField(
      controller: _peopleController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Nombre de personnes *',
        hintText: '1',
        prefixIcon: const Icon(Icons.people),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty == true) {
          return 'Nombre de personnes requis';
        }
        final number = int.tryParse(value!);
        if (number == null || number < 1) {
          return 'Minimum 1 personne';
        }
        if (_isEvent && widget.event!.maxParticipants != null) {
          final available = widget.event!.availableSpots ?? 0;
          if (number > available) {
            return 'Maximum $available places disponibles';
          }
        }
        return null;
      },
    );
  }

  Widget _buildContactFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations de contact (optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nom complet',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isNotEmpty == true && 
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Téléphone',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
        labelText: 'Notes ou demandes spéciales',
        hintText: 'Allergies alimentaires, besoins spéciaux...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
            child: const Text('Annuler'),
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
                : const Text(
                    'Confirmer la réservation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = '${pickedDate.day.toString().padLeft(2, '0')}/'
            '${pickedDate.month.toString().padLeft(2, '0')}/'
            '${pickedDate.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final numberOfPeople = int.parse(_peopleController.text);
      final reservationDate = '${_selectedDate!.year}-'
          '${_selectedDate!.month.toString().padLeft(2, '0')}-'
          '${_selectedDate!.day.toString().padLeft(2, '0')}';
      
      String? reservationTime;
      if (_selectedTime != null) {
        reservationTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
            '${_selectedTime!.minute.toString().padLeft(2, '0')}';
      }

      print('[FORM] Calling reservation service...');
      ApiResponse<Reservation> response;

      if (_isPoi) {
        print('[FORM] Making POI reservation for ${widget.poi!.name}');
        response = await _reservationService.reservePoi(
          widget.poi!,
          date: reservationDate,
          time: reservationTime,
          people: numberOfPeople,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          userName: _nameController.text.isNotEmpty ? _nameController.text : null,
          userEmail: _emailController.text.isNotEmpty ? _emailController.text : null,
          userPhone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        );
      } else {
        print('[FORM] Making Event reservation for ${widget.event!.title}');
        response = await _reservationService.reserveEvent(
          widget.event!,
          date: reservationDate,
          time: reservationTime,
          people: numberOfPeople,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          userName: _nameController.text.isNotEmpty ? _nameController.text : null,
          userEmail: _emailController.text.isNotEmpty ? _emailController.text : null,
          userPhone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        );
      }

      print('[FORM] Response received: success=${response.isSuccess}, message=${response.message}');
      
      if (mounted) {
        if (response.isSuccess) {
          print('[FORM] Success! Showing snackbar and closing form');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Réservation créée avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
          
          print('[FORM] Calling onSuccess callback or Navigator.pop()');
          if (widget.onSuccess != null) {
            print('[FORM] Calling onSuccess callback');
            widget.onSuccess!();
          } else {
            print('[FORM] Calling Navigator.pop()');
            Navigator.of(context).pop();
          }
        } else {
          print('[FORM] Error: ${response.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Erreur lors de la réservation'),
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
            content: Text('Erreur inattendue: $e'),
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