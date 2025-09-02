import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

class SmartLoadingWidget extends StatefulWidget {
  final String message;
  final bool showProgress;
  final double? progress;
  final Widget? child;

  const SmartLoadingWidget({
    super.key,
    this.message = 'Chargement...',
    this.showProgress = false,
    this.progress,
    this.child,
  });

  @override
  State<SmartLoadingWidget> createState() => _SmartLoadingWidgetState();
}

class _SmartLoadingWidgetState extends State<SmartLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return widget.child!;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicateur de chargement avec animation personnalisée
            SizedBox(
              width: 60,
              height: 60,
              child: widget.showProgress && widget.progress != null
                  ? CircularProgressIndicator(
                      value: widget.progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3860F8),
                      ),
                    )
                  : CircularProgressIndicator(
                      strokeWidth: 3,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3860F8),
                      ),
                    ),
            ),
            
            SizedBox(height: ResponsiveConstants.largeSpace),
            
            // Message de chargement
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveConstants.body1,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            
            if (widget.showProgress && widget.progress != null) ...[
              SizedBox(height: ResponsiveConstants.smallSpace),
              Text(
                '${(widget.progress! * 100).toInt()}%',
                style: TextStyle(
                  fontSize: ResponsiveConstants.body2,
                  color: Colors.grey[500],
                ),
              ),
            ],
            
            SizedBox(height: ResponsiveConstants.mediumSpace),
            
            // Points d'animation pour indiquer le chargement
            AnimatedDots(),
          ],
        ),
      ),
    );
  }
}

class AnimatedDots extends StatefulWidget {
  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          _controllers[i].forward();
        }
      }
      await Future.delayed(const Duration(milliseconds: 200));
      for (final controller in _controllers) {
        if (mounted) {
          controller.reverse();
        }
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(0xFF3860F8).withOpacity(_animations[index].value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

// Widget pour un état de chargement de carte
class CardSkeletonLoader extends StatefulWidget {
  final int itemCount;
  
  const CardSkeletonLoader({super.key, this.itemCount = 3});

  @override
  State<CardSkeletonLoader> createState() => _CardSkeletonLoaderState();
}

class _CardSkeletonLoaderState extends State<CardSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: ResponsiveConstants.largeSpace),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
                ),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image skeleton
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300]!.withOpacity(_animation.value),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.mediumSpace),
                      // Title skeleton
                      Container(
                        height: 20,
                        width: double.infinity * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.grey[300]!.withOpacity(_animation.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.smallSpace),
                      // Subtitle skeleton
                      Container(
                        height: 16,
                        width: double.infinity * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.grey[300]!.withOpacity(_animation.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.smallSpace),
                      // Tags skeleton
                      Row(
                        children: [
                          Container(
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300]!.withOpacity(_animation.value),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(width: ResponsiveConstants.smallSpace),
                          Container(
                            height: 24,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300]!.withOpacity(_animation.value),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}