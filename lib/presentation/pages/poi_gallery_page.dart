import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'fullscreen_image_viewer.dart';

class PoiGalleryPage extends StatelessWidget {
  final String poiName;
  final List<String> imageUrls;

  const PoiGalleryPage({
    super.key,
    required this.poiName,
    required this.imageUrls,
  });

  void _openFullscreenViewer(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(poiName),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: Responsive.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: imageUrls.isEmpty
          ?  Center(
              child: Text(
                'Aucune image disponible',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: Responsive.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                children: [
                  // Layout adaptatif selon le nombre d'images
                  if (imageUrls.length == 1)
                    _buildSingleImage(context, 0)
                  else if (imageUrls.length == 2)
                    _buildTwoImages(context)
                  else if (imageUrls.length == 3)
                    _buildThreeImages(context)
                  else
                    _buildMultipleImages(context),
                ],
              ),
            ),
    );
  }

  // Une seule image - pleine largeur
  Widget _buildSingleImage(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _openFullscreenViewer(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: CachedNetworkImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
          height: 400.h,
          width: double.infinity,
          placeholder: (context, url) => Container(
            height: 400.h,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3860F8),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 400.h,
            color: Colors.grey[200],
            child: const Icon(Icons.error_outline, size: 48),
          ),
        ),
      ),
    );
  }

  // Deux images - côte à côte
  Widget _buildTwoImages(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildImageTile(context, 0, height: 250.h),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildImageTile(context, 1, height: 250.h),
        ),
      ],
    );
  }

  // Trois images - 1 grande + 2 petites
  Widget _buildThreeImages(BuildContext context) {
    return Column(
      children: [
        _buildImageTile(context, 0, height: 300.h),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildImageTile(context, 1, height: 180.h),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildImageTile(context, 2, height: 180.h),
            ),
          ],
        ),
      ],
    );
  }

  // Plusieurs images - style grille comme capture1
  Widget _buildMultipleImages(BuildContext context) {
    return Column(
      children: [
        // Première grande image
        _buildImageTile(context, 0, height: 300.h),
        SizedBox(height: 8.h),

        // Deux images moyennes si disponibles
        if (imageUrls.length >= 3)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildImageTile(context, 1, height: 200.h),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildImageTile(context, 2, height: 200.h),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),

        // Grande image si 4+ images
        if (imageUrls.length >= 4)
          Column(
            children: [
              _buildImageTile(context, 3, height: 300.h),
              SizedBox(height: 8.h),
            ],
          ),

        // Grille pour le reste des images
        if (imageUrls.length > 4)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: imageUrls.length - 4,
            itemBuilder: (context, index) {
              return _buildImageTile(context, index + 4);
            },
          ),
      ],
    );
  }

  Widget _buildImageTile(BuildContext context, int index, {double? height}) {
    return GestureDetector(
      onTap: () => _openFullscreenViewer(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: CachedNetworkImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
          height: height,
          width: double.infinity,
          placeholder: (context, url) => Container(
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF3860F8),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: height,
            color: Colors.grey[200],
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
