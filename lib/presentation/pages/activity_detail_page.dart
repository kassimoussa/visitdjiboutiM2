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
    // L'AppBar apparaît quand le titre atteint le haut de l'écran
    // 50% de l'écran (galerie) - 30 (translate) + 32 (padding vertical) + ~40 (début titre)
    final screenHeight = MediaQuery.of(context).size.height;
    final titleThreshold = (screenHeight * 0.5) - 30 + 32 + 40; // Image - overlap + padding top + espace pour titre
    final shouldShowTitle = _scrollController.offset > titleThreshold;

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
      bottomNavigationBar: !_isLoading && _errorMessage == null && _activity != null
          ? _buildRegistrationButton()
          : null,
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
                  // Image gallery plus grande (70% de l'écran)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _buildImageGallery(),
                  ),

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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            Text(
                              _activity!.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Ligne horizontale
                            Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                            const SizedBox(height: 20),

                            // Description
                            if ((_activity!.description != null && _activity!.description!.trim().isNotEmpty) ||
                                (_activity!.shortDescription != null && _activity!.shortDescription!.trim().isNotEmpty))
                              Text(
                                _activity!.description?.trim().isNotEmpty == true
                                    ? _activity!.description!
                                    : _activity!.shortDescription!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.6,
                                ),
                              ),
                            const SizedBox(height: 24),

                // Conteneur d'informations principales (style c3.png)
                _buildInfoContainer(),
                const SizedBox(height: 24),

                if (_activity!.includes != null && _activity!.includes!.isNotEmpty) ...[
                  _buildInclusions(),
                  const SizedBox(height: 24),
                ],
                if (_activity!.whatToBring != null && _activity!.whatToBring!.trim().isNotEmpty) ...[
                  _buildWhatToBring(),
                  const SizedBox(height: 24),
                ],
                if ((_activity!.equipmentProvided != null && _activity!.equipmentProvided!.isNotEmpty) ||
                    (_activity!.equipmentRequired != null && _activity!.equipmentRequired!.isNotEmpty)) ...[
                  _buildEquipment(),
                  const SizedBox(height: 24),
                ],
                if ((_activity!.physicalRequirements != null && _activity!.physicalRequirements!.isNotEmpty) ||
                    (_activity!.certificationsRequired != null && _activity!.certificationsRequired!.isNotEmpty)) ...[
                  _buildRequirements(),
                  const SizedBox(height: 24),
                ],
                if (_activity!.ageRestrictions?.hasRestrictions ?? false) ...[
                  _buildAgeRestrictions(_activity!.ageRestrictions!),
                  const SizedBox(height: 24),
                ],
                if (_activity!.weatherDependent) ...[
                  _buildWeatherWarning(),
                  const SizedBox(height: 24),
                ],
                if (_activity!.meetingPointDescription != null && _activity!.meetingPointDescription!.trim().isNotEmpty) ...[
                  _buildMeetingPoint(),
                  const SizedBox(height: 24),
                ],
                if (_activity!.additionalInfo != null && _activity!.additionalInfo!.trim().isNotEmpty) ...[
                  _buildAdditionalInfo(),
                  const SizedBox(height: 24),
                ],
                if (_activity!.tourOperator != null) ...[
                  _buildOperatorInfo(_activity!.tourOperator!),
                  const SizedBox(height: 24),
                ],
                if (_activity!.cancellationPolicy != null && _activity!.cancellationPolicy!.trim().isNotEmpty) ...[
                  _buildCancellationPolicy(),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 100), // Espace pour le bottom bar
                          ],
                        ),
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
        height: double.infinity,
        color: Colors.grey[300],
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
        height: double.infinity,
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
                      color: Colors.grey[300],
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
                      color: Colors.grey[300],
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
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageUrls.asMap().entries.map((entry) {
                    final isActive = entry.key == _currentImageIndex;
                    return Container(
                      width: isActive ? 12 : 8,
                      height: isActive ? 12 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                        border: isActive ? Border.all(color: const Color(0xFF3860F8), width: 2) : null,
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
        color: const Color(0xFF2C5F7C), // Bleu foncé comme c3.png
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prix et durée
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Total Price
          Text(
            'Total Price',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _activity!.displayPrice,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // Duration
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                _activity!.displayDuration,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Difficulty
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                _activity!.displayDifficulty,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Location si disponible
          if (_activity!.location != null &&
              _activity!.location!.address != null &&
              _activity!.location!.address!.trim().isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _activity!.location!.address!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Ouvrir navigation
                },
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text(
                  'Getting there',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],

          // Section Links si website disponible
          if (_activity!.tourOperator?.website != null &&
              _activity!.tourOperator!.website!.trim().isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
            const SizedBox(height: 16),
            // Website
            GestureDetector(
              onTap: () {
                // Ouvrir le website
              },
              child: const Row(
                children: [
                  Icon(Icons.public, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Visit the website',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contact
            if (_activity!.tourOperator!.firstPhone != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // Appeler
                },
                child: const Row(
                  children: [
                    Icon(Icons.phone, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Call',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
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
