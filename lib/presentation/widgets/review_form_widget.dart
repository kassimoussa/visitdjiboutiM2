import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import '../../core/models/review.dart';
import '../../core/services/review_service.dart';

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
        const SnackBar(
          content: Text('Veuillez sélectionner une note'),
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
            content: Text(_isEditing ? 'Avis modifié avec succès' : 'Avis publié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: Responsive.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: Responsive.all(24),
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
                            _isEditing ? 'Modifier votre avis' : 'Écrire un avis',
                            style: const TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.poiName,
                            style: TextStyle(
                              fontSize: 14.sp,
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
                SizedBox(height: 24.h),

                // Sélection de la note
                const Text(
                  'Votre note *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
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
                        padding: Responsive.symmetric(horizontal: 4),
                        child: Icon(
                          _rating >= starRating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFB800),
                          size: 48,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24.h),

                // Titre (optionnel)
                const Text(
                  'Titre (optionnel)',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Résumez votre expérience',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF3860F8),
                        width: 2.w,
                      ),
                    ),
                  ),
                  maxLength: 100,
                ),
                SizedBox(height: 16.h),

                // Commentaire (optionnel)
                const Text(
                  'Votre avis (optionnel)',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Partagez votre expérience en détail...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF3860F8),
                        width: 2.w,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  maxLength: 1000,
                ),
                SizedBox(height: 24.h),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: Responsive.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF3860F8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            color: Color(0xFF3860F8),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3860F8),
                          foregroundColor: Colors.white,
                          padding: Responsive.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditing ? 'Modifier' : 'Publier',
                                style: const TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
