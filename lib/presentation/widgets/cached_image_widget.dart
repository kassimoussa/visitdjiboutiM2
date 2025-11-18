import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/responsive.dart';

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Duration fadeInDuration;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  /// Convertit une valeur double en int de manière sécurisée
  int? _getSafeIntValue(double? value) {
    if (value == null || value.isInfinite || value.isNaN) {
      return null;
    }
    return value.toInt();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      memCacheWidth: _getSafeIntValue(width),
      memCacheHeight: _getSafeIntValue(height),
      maxWidthDiskCache: 800, // Limite la taille des images en cache
      maxHeightDiskCache: 600,
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF3860F8),
            ),
            SizedBox(height: 4.h),
            Text(
              'Chargement...',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: Colors.grey,
            ),
            SizedBox(height: 4.h),
            Text(
              'Image non disponible',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget d'image spécialement optimisé pour les POIs
class PoiImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PoiImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(12.r),
      placeholder: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE8D5A3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(
          child: Icon(
            Icons.place,
            size: 40,
            color: Color(0xFF3860F8),
          ),
        ),
      ),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE8D5A3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(
          child: Icon(
            Icons.place,
            size: 40,
            color: Color(0xFF3860F8),
          ),
        ),
      ),
    );
  }
}

// Widget d'image spécialement optimisé pour les événements
class EventImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const EventImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(8.r),
      placeholder: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF3860F8),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Center(
          child: Icon(
            Icons.event,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF3860F8),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Center(
          child: Icon(
            Icons.event,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}