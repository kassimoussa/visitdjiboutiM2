import 'package:flutter/material.dart';
import 'package:vd_gem/core/utils/responsive.dart';
import '../../core/models/review.dart';
import '../../core/services/review_service.dart';
import '../../core/services/anonymous_auth_service.dart';
import '../../generated/l10n/app_localizations.dart';
import 'review_form_widget.dart';

/// Widget d'affichage de la section avis (statistiques + liste)
class ReviewsSection extends StatefulWidget {
  final int poiId;
  final String poiName;

   const ReviewsSection({
    super.key,
    required this.poiId,
    required this.poiName,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final ReviewService _reviewService = ReviewService();
  final AnonymousAuthService _authService = AnonymousAuthService();

  List<Review> _reviews = [];
  ReviewStatistics? _statistics;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMorePages = false;
  int? _filterRating;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({bool loadMore = false}) async {
    if (loadMore && !_hasMorePages) return;

    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    try {
      final response = await _reviewService.getPoiReviews(
        poiId: widget.poiId,
        page: loadMore ? _currentPage + 1 : 1,
        rating: _filterRating,
      );

      if (!mounted) return;

      setState(() {
        if (loadMore) {
          _reviews.addAll(response.data);
          _currentPage++;
        } else {
          _reviews = response.data;
          _statistics = response.statistics;
        }
        _hasMorePages = response.meta?.hasMorePages ?? false;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print('[REVIEWS SECTION] Erreur chargement avis: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterByRating(int? rating) {
    setState(() {
      _filterRating = rating;
    });
    _loadReviews();
  }

  void _showReviewForm({Review? existingReview}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewFormWidget(
        poiId: widget.poiId,
        poiName: widget.poiName,
        existingReview: existingReview,
        onReviewSubmitted: () {
          _loadReviews(); // Recharger les avis après création/modification
        },
      ),
    );
  }

  Future<void> _voteHelpful(Review review) async {
    try {
      await _reviewService.voteHelpful(
        poiId: widget.poiId,
        reviewId: review.id,
      );
      _loadReviews(); // Recharger pour mettre à jour le compteur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context)!.reviewsVotedHelpful),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reviewsVoteError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(AppLocalizations.of(context)!.reviewsDeleteTitle),
        content:  Text(AppLocalizations.of(context)!.reviewsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:  Text(AppLocalizations.of(context)!.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child:  Text(AppLocalizations.of(context)!.reviewsDelete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _reviewService.deleteReview(
        poiId: widget.poiId,
        reviewId: review.id,
      );
      _loadReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.reviewsDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reviewsVoteError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Responsive.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec bouton "Écrire un avis"
          _buildHeader(),
          SizedBox(height: 20.h),

          // Statistiques
          if (_statistics != null) ...[
            _buildStatistics(),
            SizedBox(height: 20.h),
          ],

          // Filtres par note
          _buildRatingFilter(),
          SizedBox(height: 20.h),

          // Liste des avis
          if (_isLoading && _reviews.isEmpty)
             Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Color(0xFF3860F8)),
              ),
            )
          else if (_hasError)
            _buildError()
          else if (_reviews.isEmpty)
            _buildEmptyState()
          else
            _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: Responsive.all(8),
              decoration: BoxDecoration(
                color:  Color(0xFF3860F8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child:  Icon(
                Icons.star_outline,
                color: Color(0xFF3860F8),
                size: 20,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              AppLocalizations.of(context)!.reviewsSectionTitle,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (_authService.isLoggedIn)
          IconButton.filled(
            onPressed: () => _showReviewForm(),
            icon: const Icon(Icons.edit, size: 20),
            tooltip: AppLocalizations.of(context)!.reviewsWriteReview,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildStatistics() {
    if (_statistics == null) return  SizedBox.shrink();

    return Container(
      padding: Responsive.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:  Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Note moyenne
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      _statistics!.displayAverageRating,
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3860F8),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _statistics!.averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color:  Color(0xFFFFB800),
                          size: 20,
                        );
                      }),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppLocalizations.of(context)!.reviewsCount(_statistics!.totalReviews),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Distribution des notes
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(5, (index) {
                    final rating = 5 - index;
                    final count = _statistics!.getCountForRating(rating);
                    final percentage = _statistics!.getPercentageForRating(rating);

                    return Padding(
                      padding: Responsive.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          SizedBox(width: 4.w),
                           Icon(Icons.star, size: 12, color: Color(0xFFFFB800)),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor:  AlwaysStoppedAnimation<Color>(
                                Color(0xFF3860F8),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 30.w,
                            child: Text(
                              '$count',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(AppLocalizations.of(context)!.reviewsAll, _filterRating == null, () => _filterByRating(null)),
          SizedBox(width: 8.w),
          ...List.generate(5, (index) {
            final rating = 5 - index;
            return Padding(
              padding: Responsive.only(right: 8),
              child: _buildFilterChip(
                '$rating ⭐',
                _filterRating == rating,
                () => _filterByRating(rating),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Responsive.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ?  Color(0xFF3860F8) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      children: [
        ..._reviews.map((review) => _buildReviewCard(review)),
        if (_hasMorePages)
          Padding(
            padding: Responsive.symmetric(vertical: 16),
            child: TextButton(
              onPressed: () => _loadReviews(loadMore: true),
              child:  Text(AppLocalizations.of(context)!.reviewsLoadMore),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: Responsive.only(bottom: 16),
      padding: Responsive.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec auteur et actions
          Row(
            children: [
              CircleAvatar(
                backgroundColor:  Color(0xFF3860F8).withValues(alpha: 0.1),
                child: Text(
                  review.author.name[0].toUpperCase(),
                  style:  TextStyle(
                    color: Color(0xFF3860F8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.author.name,
                          style:  TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        if (review.author.isVerified) ...[
                          SizedBox(width: 4.w),
                           Icon(
                            Icons.verified,
                            size: 16,
                            color: Color(0xFF3860F8),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color:  Color(0xFFFFB800),
                            size: 16,
                          );
                        }),
                        SizedBox(width: 8.w),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (review.author.isMe)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showReviewForm(existingReview: review);
                    } else if (value == 'delete') {
                      _deleteReview(review);
                    }
                  },
                  itemBuilder: (context) => [
                     PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8.w),
                          Text(AppLocalizations.of(context)!.commonEdit),
                        ],
                      ),
                    ),
                     PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8.w),
                          Text(AppLocalizations.of(context)!.reviewsDelete, style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Titre et commentaire
          if (review.hasTitle) ...[
            SizedBox(height: 12.h),
            Text(
              review.title!,
              style:  TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ],
          if (review.hasComment) ...[
            SizedBox(height: 8.h),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],

          // Réponse de l'opérateur
          if (review.hasOperatorResponse) ...[
            SizedBox(height: 12.h),
            Container(
              padding: Responsive.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color:  Color(0xFF3860F8).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                       Icon(
                        Icons.store,
                        size: 16,
                        color: Color(0xFF3860F8),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Réponse de l\'établissement',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                       Spacer(),
                      Text(
                        _formatDate(review.operatorResponse!.date),
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    review.operatorResponse!.text,
                    style:  TextStyle(fontSize: 13.sp, height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          // Bouton "Utile"
          SizedBox(height: 12.h),
          Row(
            children: [
              InkWell(
                onTap: review.isHelpful ? null : () => _voteHelpful(review),
                child: Container(
                  padding: Responsive.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: review.isHelpful
                        ?  Color(0xFF3860F8).withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: review.isHelpful
                          ?  Color(0xFF3860F8)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        review.isHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 14,
                        color: review.isHelpful
                            ?  Color(0xFF3860F8)
                            : Colors.grey[600],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Utile${(review.helpfulCount ?? 0) > 0 ? ' (${review.helpfulCount})' : ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: review.isHelpful ? FontWeight.w600 : FontWeight.normal,
                          color: review.isHelpful
                              ?  Color(0xFF3860F8)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:  EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'Aucun avis pour le moment',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            if (_authService.isLoggedIn) ...[
              SizedBox(height: 8.h),
              Text(
                'Soyez le premier à donner votre avis !',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:  EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadReviews,
              child:  Text(AppLocalizations.of(context)!.commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Aujourd\'hui';
      } else if (diff.inDays == 1) {
        return 'Hier';
      } else if (diff.inDays < 7) {
        return 'Il y a ${diff.inDays} jours';
      } else if (diff.inDays < 30) {
        final weeks = (diff.inDays / 7).floor();
        return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
      } else if (diff.inDays < 365) {
        final months = (diff.inDays / 30).floor();
        return 'Il y a $months mois';
      } else {
        final years = (diff.inDays / 365).floor();
        return 'Il y a $years an${years > 1 ? 's' : ''}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
