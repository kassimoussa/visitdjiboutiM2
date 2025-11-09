import 'package:flutter/material.dart';
import '../../core/models/activity.dart';
import '../../core/models/tour_operator.dart';
import '../../core/services/activity_service.dart';
import '../widgets/activity_registration_form_widget.dart';
import 'activity_gallery_page.dart';

class ActivityDetailPage extends StatefulWidget {
  final int activityId;

  const ActivityDetailPage({super.key, required this.activityId});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final ActivityService _activityService = ActivityService();
  final ScrollController _scrollController = ScrollController();
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  Activity? _activity;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _loadActivityDetails();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const imageGalleryHeight = 350.0;
    final shouldShowTitle = _scrollController.offset > imageGalleryHeight;

    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });
    }
  }

  Future<void> _loadActivityDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activity = await _activityService.getActivityDetails(widget.activityId);
      setState(() {
        _activity = activity;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)))
          : _errorMessage != null
              ? _buildErrorState()
              : _buildActivityDetail(),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activité'),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadActivityDetails,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getImageUrls() {
    final List<String> urls = [];
    if (_activity?.featuredImage != null) {
      urls.add(_activity!.featuredImage!.url);
    }
    if (_activity?.gallery != null) {
      for (final media in _activity!.gallery!) {
        if (media.url != _activity!.featuredImage?.url) {
          urls.add(media.url);
        }
      }
    }
    return urls;
  }

  Widget _buildActivityDetail() {
    if (_activity == null) return const SizedBox.shrink();

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(),

                  // Card blanc arrondi qui chevauche l'image
                  Transform.translate(
                    offset: const Offset(0, -30), // Remonte de 30px sur l'image
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _activity!.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),

                          // Description
                          if ((_activity!.description != null && _activity!.description!.trim().isNotEmpty) ||
                              (_activity!.shortDescription != null && _activity!.shortDescription!.trim().isNotEmpty))
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3860F8).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: Color(0xFF3860F8),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _activity!.description?.trim().isNotEmpty == true
                                        ? _activity!.description!
                                        : _activity!.shortDescription!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Infos pratiques dans un conteneur blanc avec ombre
                          Container(
                            margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3860F8).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF3860F8),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Informations pratiques',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildDetailsSection(),
                                const SizedBox(height: 16),
                                _buildPracticalInfoGrid(),
                              ],
                            ),
                          ),

                          // Opérateur dans un conteneur séparé (comme poi_detail)
                          if (_activity!.tourOperator != null) ...[
                            const SizedBox(height: 16),
                            _buildOperatorCard(_activity!.tourOperator!),
                          ],

                          // Bouton d'inscription
                          const SizedBox(height: 24),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            child: ElevatedButton(
                              onPressed: _showRegistrationForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3860F8),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'S\'inscrire maintenant',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // AppBar animé qui apparaît au scroll
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _showTitle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _activity!.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Espace pour symétrie
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Boutons flottants quand l'AppBar n'est pas visible
        if (!_showTitle)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageGallery() {
    final imageUrls = _getImageUrls();
    final hasImages = imageUrls.isNotEmpty;

    if (!hasImages) {
      return Container(
        height: 350,
        color: const Color(0xFFE8D5A3),
        child: const Center(
          child: Icon(
            Icons.kayaking,
            size: 80,
            color: Color(0xFF3860F8),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityGalleryPage(
              activityName: _activity!.title,
              imageUrls: imageUrls,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 350,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              controller: _imagePageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE8D5A3),
                      child: const Center(
                        child: Icon(
                          Icons.kayaking,
                          size: 80,
                          color: Color(0xFF3860F8),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFE8D5A3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3860F8),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Indicateurs de page
            if (imageUrls.length > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageUrls.asMap().entries.map((entry) {
                    final isActive = entry.key == _currentImageIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentImageIndex = entry.key;
                        });
                      },
                      child: Container(
                        width: isActive ? 12 : 8,
                        height: isActive ? 12 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                          border: isActive ? Border.all(color: const Color(0xFF3860F8), width: 2) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildInclusions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ce qui est inclus',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._activity!.includes!.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF009639), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildWhatToBring() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À apporter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _activity!.whatToBring!,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildEquipment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_activity!.equipmentProvided != null && _activity!.equipmentProvided!.isNotEmpty) ...[
          const Text(
            'Fourni',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF009639)),
          ),
          const SizedBox(height: 8),
          ..._activity!.equipmentProvided!.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, color: Color(0xFF009639), size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 16))),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],
        if (_activity!.equipmentRequired != null && _activity!.equipmentRequired!.isNotEmpty) ...[
          const Text(
            'À apporter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          ..._activity!.equipmentRequired!.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.backpack, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 16))),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prérequis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_activity!.physicalRequirements != null && _activity!.physicalRequirements!.isNotEmpty) ...[
          const Text(
            'Condition physique',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._activity!.physicalRequirements!.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.fitness_center, size: 20, color: Color(0xFF3860F8)),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 16))),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],
        if (_activity!.certificationsRequired != null && _activity!.certificationsRequired!.isNotEmpty) ...[
          const Text(
            'Certifications requises',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._activity!.certificationsRequired!.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 16))),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildInfoContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Details (Prix, Durée, Difficulté)
          _buildDetailsSection(),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
          ),

          // Informations pratiques
          _buildPracticalInfoGrid(),

          if (_buildHasAdditionalSections()) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
            ),
            _buildAdditionalSections(),
          ],
        ],
      ),
    );
  }

  bool _buildHasAdditionalSections() {
    return (_activity!.ageRestrictions?.hasRestrictions ?? false) ||
        _activity!.weatherDependent ||
        (_activity!.meetingPointDescription != null && _activity!.meetingPointDescription!.trim().isNotEmpty) ||
        (_activity!.additionalInfo != null && _activity!.additionalInfo!.trim().isNotEmpty);
  }

  Widget _buildPracticalInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location
        if (_activity!.location != null &&
            _activity!.location!.address != null &&
            _activity!.location!.address!.trim().isNotEmpty)
          _buildLocationSection(),

        // Includes
        if (_activity!.includes != null && _activity!.includes!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildIncludesSection(),
        ],

        // What to Bring
        if (_activity!.whatToBring != null && _activity!.whatToBring!.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildWhatToBringSection(),
        ],

        // Equipment
        if ((_activity!.equipmentProvided != null && _activity!.equipmentProvided!.isNotEmpty) ||
            (_activity!.equipmentRequired != null && _activity!.equipmentRequired!.isNotEmpty)) ...[
          const SizedBox(height: 20),
          _buildEquipmentSection(),
        ],

        // Requirements
        if ((_activity!.physicalRequirements != null && _activity!.physicalRequirements!.isNotEmpty) ||
            (_activity!.certificationsRequired != null && _activity!.certificationsRequired!.isNotEmpty)) ...[
          const SizedBox(height: 20),
          _buildRequirementsSection(),
        ],
      ],
    );
  }

  Widget _buildAdditionalSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Age Restrictions
        if (_activity!.ageRestrictions?.hasRestrictions ?? false)
          _buildAgeRestrictionsSection(),

        // Weather Warning
        if (_activity!.weatherDependent) ...[
          if (_activity!.ageRestrictions?.hasRestrictions ?? false) const SizedBox(height: 16),
          _buildWeatherWarningSection(),
        ],

        // Meeting Point
        if (_activity!.meetingPointDescription != null && _activity!.meetingPointDescription!.trim().isNotEmpty) ...[
          if ((_activity!.ageRestrictions?.hasRestrictions ?? false) || _activity!.weatherDependent) const SizedBox(height: 16),
          _buildMeetingPointSection(),
        ],

        // Additional Info
        if (_activity!.additionalInfo != null && _activity!.additionalInfo!.trim().isNotEmpty) ...[
          if ((_activity!.ageRestrictions?.hasRestrictions ?? false) || _activity!.weatherDependent ||
              (_activity!.meetingPointDescription != null && _activity!.meetingPointDescription!.trim().isNotEmpty))
            const SizedBox(height: 16),
          _buildAdditionalInfoSection(),
        ],
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.attach_money,
          'Prix',
          _activity!.displayPrice,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.access_time,
          'Durée',
          _activity!.displayDuration,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.trending_up,
          'Difficulté',
          _activity!.displayDifficulty,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return _buildInfoRow(
      Icons.location_on,
      'Localisation',
      _activity!.location!.address!,
    );
  }

  Widget _buildIncludesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inclus',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ..._activity!.includes!.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF009639), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildWhatToBringSection() {
    return _buildInfoRow(
      Icons.backpack,
      'À apporter',
      _activity!.whatToBring!,
    );
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (_activity!.equipmentProvided != null && _activity!.equipmentProvided!.isNotEmpty) ...[
          Text('Fourni :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 6),
          ..._activity!.equipmentProvided!.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, color: Color(0xFF009639), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
              ],
            ),
          )),
          if (_activity!.equipmentRequired != null && _activity!.equipmentRequired!.isNotEmpty)
            const SizedBox(height: 10),
        ],
        if (_activity!.equipmentRequired != null && _activity!.equipmentRequired!.isNotEmpty) ...[
          Text('À apporter :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 6),
          ..._activity!.equipmentRequired!.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.backpack, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prérequis',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (_activity!.physicalRequirements != null && _activity!.physicalRequirements!.isNotEmpty) ...[
          Text('Condition physique :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 6),
          ..._activity!.physicalRequirements!.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.fitness_center, size: 16, color: Color(0xFF3860F8)),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
              ],
            ),
          )),
          if (_activity!.certificationsRequired != null && _activity!.certificationsRequired!.isNotEmpty)
            const SizedBox(height: 10),
        ],
        if (_activity!.certificationsRequired != null && _activity!.certificationsRequired!.isNotEmpty) ...[
          Text('Certifications :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 6),
          ..._activity!.certificationsRequired!.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildAgeRestrictionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue[100]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF3860F8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Restrictions d\'âge',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _activity!.ageRestrictions!.text,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherWarningSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.orange[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cette activité est dépendante des conditions météorologiques',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingPointSection() {
    return _buildInfoRow(
      Icons.place,
      'Point de rendez-vous',
      _activity!.meetingPointDescription!,
    );
  }

  Widget _buildAdditionalInfoSection() {
    return _buildInfoRow(
      Icons.info_outline,
      'Informations supplémentaires',
      _activity!.additionalInfo!,
    );
  }

  Widget _buildOperatorCard(TourOperator operator) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Organisé par',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Logo de l'opérateur
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: operator.logoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.network(
                            operator.logoUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: const Color(0xFF3860F8),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.business,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.business,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operator.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009639).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Opérateur agréé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF009639),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Politique d\'annulation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            _activity!.cancellationPolicy!,
            style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.language,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Links',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeetingPoint() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF3860F8)),
                SizedBox(width: 8),
                Text(
                  'Point de rendez-vous',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _activity!.meetingPointDescription!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations supplémentaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _activity!.additionalInfo!,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Politique d\'annulation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Text(
            _activity!.cancellationPolicy!,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeRestrictions(ActivityAgeRestrictions restrictions) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF3860F8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restrictions d\'âge',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(restrictions.text, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherWarning() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.wb_sunny, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cette activité est dépendante des conditions météorologiques',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorInfo(TourOperator operator) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Opérateur touristique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (operator.logoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      operator.logoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business, color: Colors.grey),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operator.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Opérateur touristique agréé',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _showRegistrationForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3860F8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'S\'inscrire à cette activité',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showRegistrationForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActivityRegistrationFormWidget(
        activity: _activity!,
        onRegistrationSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription enregistrée avec succès !'),
              backgroundColor: Color(0xFF009639),
            ),
          );
        },
      ),
    );
  }
}
