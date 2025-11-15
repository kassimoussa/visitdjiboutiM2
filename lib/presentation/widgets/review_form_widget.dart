import 'package:flutter/material.dart';
import '../../core/models/review.dart';
import '../../core/services/review_service.dart';
import '../../generated/l10n/app_localizations.dart';

/// Widget de formulaire pour créer ou modifier un avis
class ReviewFormWidget extends StatefulWidget {
  final int poiId;
  final String poiName;
  final Review? existingReview;
  final VoidCallback onReviewSubmitted;

  const ReviewFormWidget({
    super.key,
    required this.poiId,
    required this.poiName,
    this.existingReview,
    required this.onReviewSubmitted,
  });

  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends State<ReviewFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ReviewService _reviewService = ReviewService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _titleController.text = widget.existingReview!.title ?? '';
      _commentController.text = widget.existingReview!.comment ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingReview != null;

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.reviewFormPleaseRate),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditing) {
        // Modification
        await _reviewService.updateReview(
          poiId: widget.poiId,
          reviewId: widget.existingReview!.id,
          rating: _rating,
          title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        );
      } else {
        // Création
        await _reviewService.createReview(
          poiId: widget.poiId,
          rating: _rating,
          title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onReviewSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? AppLocalizations.of(context)!.reviewFormUpdated : AppLocalizations.of(context)!.reviewFormPublished),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        // Extraire le message d'erreur propre
        String errorMessage = e.toString();
        if (e is Exception) {
          // Enlever le préfixe "Exception: " si présent
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? AppLocalizations.of(context)!.reviewFormEditTitle : AppLocalizations.of(context)!.reviewsWriteReview,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.poiName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sélection de la note
                Text(
                  AppLocalizations.of(context)!.reviewFormYourRating,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starRating = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = starRating;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          _rating >= starRating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFB800),
                          size: 48,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Titre (optionnel)
                Text(
                  AppLocalizations.of(context)!.reviewFormTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.reviewFormTitleHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF3860F8),
                        width: 2,
                      ),
                    ),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),

                // Commentaire (optionnel)
                Text(
                  AppLocalizations.of(context)!.reviewFormComment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.reviewFormCommentHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF3860F8),
                        width: 2,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  maxLength: 1000,
                ),
                const SizedBox(height: 24),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF3860F8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.commonCancel,
                          style: const TextStyle(
                            color: Color(0xFF3860F8),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3860F8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditing ? AppLocalizations.of(context)!.reviewFormUpdate : AppLocalizations.of(context)!.reviewFormPublish,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
