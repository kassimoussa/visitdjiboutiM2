import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? period;
  final ShimmerDirection direction;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period,
    this.direction = ShimmerDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      period: period ?? const Duration(milliseconds: 1500),
      direction: direction,
      child: child,
    );
  }
}

/// Predefined shimmer loading widgets for common use cases
class ShimmerLoadingCard extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const ShimmerLoadingCard({
    super.key,
    this.height = 200,
    this.width,
    this.margin,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin ?? Responsive.symmetric(vertical: 8, horizontal: 16),
      child: ShimmerLoading(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          ),
          child: Container(
            padding: padding ?? Responsive.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 14.h,
                  width: double.infinity * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 14.h,
                  width: double.infinity * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading for list tiles
class ShimmerLoadingListTile extends StatelessWidget {
  final bool hasSubtitle;
  final bool hasTrailing;
  final EdgeInsetsGeometry? padding;

  const ShimmerLoadingListTile({
    super.key,
    this.hasSubtitle = true,
    this.hasTrailing = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? Responsive.symmetric(horizontal: 16, vertical: 8),
      child: ShimmerLoading(
        child: Row(
          children: [
            // Leading avatar/icon
            Container(
              width: 48.w,
              height: 48.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 16.w),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  if (hasSubtitle) ...[
                    SizedBox(height: 8.h),
                    Container(
                      height: 14.h,
                      width: double.infinity * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing
            if (hasTrailing) ...[
              SizedBox(width: 16.w),
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for text lines
class ShimmerLoadingText extends StatelessWidget {
  final int lines;
  final double height;
  final EdgeInsetsGeometry? padding;

  const ShimmerLoadingText({
    super.key,
    this.lines = 3,
    this.height = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(lines, (index) {
            return Container(
              margin: EdgeInsets.only(bottom: index < lines - 1 ? 8 : 0),
              height: height,
              width: index == lines - 1
                ? double.infinity * 0.7
                : double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Shimmer loading for grid items
class ShimmerLoadingGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double aspectRatio;
  final EdgeInsetsGeometry? padding;

  const ShimmerLoadingGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.aspectRatio = 1.2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? Responsive.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerLoadingCard(
        height: double.infinity,
        margin: EdgeInsets.zero,
      ),
    );
  }
}