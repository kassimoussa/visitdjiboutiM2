import 'package:flutter/material.dart';
import '../../core/models/review.dart';
import '../../core/services/review_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget compact pour afficher le résumé des évaluations
class RatingsSummaryWidget extends StatefulWidget {
  final int poiId;
  final VoidCallback onTap;

  const RatingsSummaryWidget({
    super.key,
    required this.poiId,
    required this.onTap,
  });

  @override
  State<RatingsSummaryWidget> createState() => _RatingsSummaryWidgetState();
}

class _RatingsSummaryWidgetState extends State<RatingsSummaryWidget> {
  final ReviewService _reviewService = ReviewService();
  ReviewStatistics? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final response = await _reviewService.getPoiReviews(
        poiId: widget.poiId,
        page: 1,
        perPage: 1, // On charge juste 1 avis pour obtenir les statistiques
      );

      if (!mounted) return;

      setState(() {
        _statistics = response.statistics;
        _isLoading = false;
      });
    } catch (e) {
      print('[RATINGS SUMMARY] Erreur chargement statistiques: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF3860F8),
        ),
      );
    }

    final hasReviews = _statistics != null && _statistics!.totalReviews > 0;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB800).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFFFB800).withOpacity(0.3),
          ),
        ),
        child: hasReviews ? _buildRatingsSummary(context) : _buildBeFirstInvitation(context),
      ),
    );
  }

  Widget _buildRatingsSummary(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Note moyenne avec étoile
        const Icon(
          Icons.star,
          color: Color(0xFFFFB800),
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          _statistics!.displayAverageRating,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2233),
          ),
        ),
        const SizedBox(width: 8),

        // Séparateur
        Container(
          width: 1,
          height: 16,
          color: Colors.grey[300],
        ),
        const SizedBox(width: 8),

        // Nombre d'avis
        Text(
          '${_statistics!.totalReviews} avis',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildBeFirstInvitation(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Étoile vide
        const Icon(
          Icons.star_outline,
          color: Color(0xFFFFB800),
          size: 20,
        ),
        const SizedBox(width: 8),
        // Message d'invitation
        Text(
          AppLocalizations.of(context)!.reviewsBeFirst,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: Colors.grey[600],
        ),
      ],
    );
  }
}
