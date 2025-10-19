import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/tour_operator.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/tour_operator_service.dart';
import '../../core/models/tour.dart';
import '../../generated/l10n/app_localizations.dart';
import 'tour_detail_page.dart';
import 'tours_page.dart';

class TourOperatorDetailPage extends StatefulWidget {
  final TourOperator operator;

  const TourOperatorDetailPage({super.key, required this.operator});

  @override
  State<TourOperatorDetailPage> createState() => _TourOperatorDetailPageState();
}

class _TourOperatorDetailPageState extends State<TourOperatorDetailPage> {
  final TourService _tourService = TourService();
  final TourOperatorService _operatorService = TourOperatorService();
  TourOperator? _operatorWithTours;
  List<Tour> _operatorTours = [];
  bool _isLoadingTours = true;

  @override
  void initState() {
    super.initState();
    _loadOperatorTours();
  }

  Future<void> _loadOperatorTours() async {
    print('[OPERATOR DETAIL] Chargement détails opérateur: ${widget.operator.id}');

    try {
      // Charger les détails complets de l'opérateur (incluant les tours)
      final response = await _operatorService.getTourOperatorById(widget.operator.id);

      if (response.success && response.data != null) {
        _operatorWithTours = response.data!;
        final tours = _operatorWithTours!.tours ?? [];

        print('[OPERATOR DETAIL] Tours disponibles: ${tours.length}');
        for (var tour in tours) {
          print('[OPERATOR DETAIL] Tour: ${tour.title} (ID: ${tour.id})');
        }

        setState(() {
          _operatorTours = tours;
          _isLoadingTours = false;
        });
      } else {
        print('[OPERATOR DETAIL] Erreur: ${response.message}');
        setState(() {
          _isLoadingTours = false;
        });
      }
    } catch (e) {
      print('[OPERATOR DETAIL] Erreur chargement détails: $e');
      setState(() {
        _isLoadingTours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(),
                if (widget.operator.description != null && widget.operator.description!.isNotEmpty)
                  _buildDescriptionSection(),
                _buildContactSection(),
                _buildToursSection(),
                _buildActionButtons(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF3860F8),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.operator.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3860F8),
                Color(0xFF5B7BFF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Icon(
                  Icons.business_center,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              if (widget.operator.featured == true)
                Positioned(
                  top: 60,
                  right: 16,
                  child: Chip(
                    label: Text(
                      AppLocalizations.of(context)!.operatorFeatured,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Color(0xFF009639),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tour,
                  color: Color(0xFF3860F8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.operator.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2233),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.operatorLabel,
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
          if (widget.operator.address != null && widget.operator.address!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, AppLocalizations.of(context)!.operatorAddress, widget.operator.address!),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              const Icon(
                Icons.info_outline,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.operatorDescription,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.operator.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              const Icon(
                Icons.contact_phone,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.operatorContact,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.operator.hasPhone)
            _buildInfoRow(Icons.phone, AppLocalizations.of(context)!.operatorPhone, widget.operator.displayPhone),
          if (widget.operator.hasEmail) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, AppLocalizations.of(context)!.operatorEmail, widget.operator.displayEmail),
          ],
          if (widget.operator.hasWebsite) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.language, AppLocalizations.of(context)!.operatorWebsite, widget.operator.displayWebsite, isLink: true),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          if (widget.operator.hasPhone) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(widget.operator.displayPhone),
                icon: const Icon(Icons.phone, size: 18),
                label: Text(AppLocalizations.of(context)!.operatorCall),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (widget.operator.hasEmail || widget.operator.hasWebsite) const SizedBox(width: 12),
          ],
          if (widget.operator.hasEmail) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _sendEmail(widget.operator.displayEmail),
                icon: const Icon(Icons.email, size: 18),
                label: Text(AppLocalizations.of(context)!.operatorEmail),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3860F8),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (widget.operator.hasWebsite) const SizedBox(width: 12),
          ],
          if (widget.operator.hasWebsite)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openWebsite(widget.operator.displayWebsite),
                icon: const Icon(Icons.language, size: 18),
                label: Text(AppLocalizations.of(context)!.operatorWebsite),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF009639),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
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
                  color: isLink ? const Color(0xFF3860F8) : Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  void _openWebsite(String website) async {
    final uri = Uri.parse(website);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  Widget _buildToursSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              const Icon(
                Icons.tour,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.operatorTours,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
              const Spacer(),
              if (!_isLoadingTours && _operatorTours.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ToursPage(operatorId: widget.operator.id),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.operatorSeeAll,
                    style: TextStyle(
                      color: Color(0xFF3860F8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingTours)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  color: Color(0xFF3860F8),
                ),
              ),
            )
          else if (_operatorTours.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.explore_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.operatorNoTours,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.operatorNoToursMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _operatorTours.length,
                itemBuilder: (context, index) {
                  final tour = _operatorTours[index];
                  return Container(
                    width: 250,
                    margin: EdgeInsets.only(
                      right: index < _operatorTours.length - 1 ? 16 : 0,
                    ),
                    child: _buildTourCard(tour),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTourCard(Tour tour) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailPage(tour: tour),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du tour
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[200],
              ),
              child: tour.hasImages
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        tour.firstImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.tour,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3860F8).withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.tour,
                          size: 40,
                          color: Color(0xFF3860F8),
                        ),
                      ),
                    ),
            ),

            // Contenu du tour
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      tour.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2233),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Type et difficulté
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3860F8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tour.type.label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF3860F8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tour.difficulty.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Prix et durée
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.displayDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.euro,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.displayPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009639),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Nombre de vues
                    if (tour.viewsCount > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${tour.viewsCount} vues',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}