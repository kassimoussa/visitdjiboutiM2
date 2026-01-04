import 'package:flutter/material.dart';
import 'package:vd_gem/core/utils/responsive.dart';
import '../../core/models/review.dart';
import '../../core/services/review_service.dart';
import '../../generated/l10n/app_localizations.dart';

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
      return SizedBox(
        height: 24.h,
        width: 24.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF3860F8),
        ),
      );
    }

    final hasReviews = _statistics != null && _statistics!.totalReviews > 0;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: Responsive.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB800).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: const Color(0xFFFFB800).withValues(alpha: 0.3),
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
        Icon(
          Icons.star,
          color: const Color(0xFFFFB800),
          size: 20.sp,
        ),
        SizedBox(width: 4.w),
        Text(
          _statistics!.displayAverageRating,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2233),
          ),
        ),
        SizedBox(width: 8.w),

        // Séparateur
        Container(
          width: 1.w,
          height: 16.h,
          color: Colors.grey[300],
        ),
        SizedBox(width: 8.w),

        // Nombre d'avis
        Text(
          '${_statistics!.totalReviews} avis',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(
          Icons.chevron_right,
          size: 16.sp,
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
        Icon(
          Icons.star_outline,
          color: const Color(0xFFFFB800),
          size: 20.sp,
        ),
        SizedBox(width: 8.w),
        // Message d'invitation
        Text(
          AppLocalizations.of(context)!.reviewsBeFirst,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(
          Icons.chevron_right,
          size: 16.sp,
          color: Colors.grey[600],
        ),
      ],
    );
  }
}
