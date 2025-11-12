import 'package:flutter/material.dart';
import '../../core/models/review.dart';
import '../../core/services/review_service.dart';
import '../../core/services/anonymous_auth_service.dart';
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
          const SnackBar(
            content: Text('Merci pour votre vote !'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
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
        title: const Text('Supprimer l\'avis'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet avis ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
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
          const SnackBar(content: Text('Avis supprimé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec bouton "Écrire un avis"
          _buildHeader(),
          const SizedBox(height: 20),

          // Statistiques
          if (_statistics != null) ...[
            _buildStatistics(),
            const SizedBox(height: 20),
          ],

          // Filtres par note
          _buildRatingFilter(),
          const SizedBox(height: 20),

          // Liste des avis
          if (_isLoading && _reviews.isEmpty)
            const Center(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.star_outline,
                color: Color(0xFF3860F8),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Avis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (_authService.isLoggedIn)
          Flexible(
            child: ElevatedButton.icon(
              onPressed: () => _showReviewForm(),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Écrire un avis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3860F8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatistics() {
    if (_statistics == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                      style: const TextStyle(
                        fontSize: 48,
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
                          color: const Color(0xFFFFB800),
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_statistics!.totalReviews} avis',
                      style: TextStyle(
                        fontSize: 14,
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
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 12, color: Color(0xFFFFB800)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3860F8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            child: Text(
                              '$count',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          _buildFilterChip('Tous', _filterRating == null, () => _filterByRating(null)),
          const SizedBox(width: 8),
          ...List.generate(5, (index) {
            final rating = 5 - index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3860F8) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextButton(
              onPressed: () => _loadReviews(loadMore: true),
              child: const Text('Voir plus d\'avis'),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec auteur et actions
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF3860F8).withValues(alpha: 0.1),
                child: Text(
                  review.author.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF3860F8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.author.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        if (review.author.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
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
                            color: const Color(0xFFFFB800),
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Titre et commentaire
          if (review.hasTitle) ...[
            const SizedBox(height: 12),
            Text(
              review.title!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
          if (review.hasComment) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],

          // Réponse de l'opérateur
          if (review.hasOperatorResponse) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3860F8).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.store,
                        size: 16,
                        color: Color(0xFF3860F8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Réponse de l\'établissement',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(review.operatorResponse!.date),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.operatorResponse!.text,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          // Bouton "Utile"
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: review.isHelpful ? null : () => _voteHelpful(review),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: review.isHelpful
                        ? const Color(0xFF3860F8).withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: review.isHelpful
                          ? const Color(0xFF3860F8)
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
                            ? const Color(0xFF3860F8)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Utile (${review.helpfulCount})',
                        style: TextStyle(
                          fontSize: 12,
                          color: review.isHelpful
                              ? const Color(0xFF3860F8)
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun avis pour le moment',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (_authService.isLoggedIn) ...[
              const SizedBox(height: 8),
              Text(
                'Soyez le premier à donner votre avis !',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReviews,
              child: const Text('Réessayer'),
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
