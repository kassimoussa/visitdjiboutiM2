import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late Orientation orientation;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    // Référence basée sur iPhone 14 (390x844)
    // Prendre la plus petite dimension pour calculer le facteur d'échelle
    defaultSize = orientation == Orientation.portrait 
        ? screenWidth / 390 
        : screenHeight / 390;
  }

  // Largeur responsive
  static double w(double inputWidth) {
    return (inputWidth / 390) * screenWidth;
  }

  // Hauteur responsive  
  static double h(double inputHeight) {
    return (inputHeight / 844) * screenHeight;
  }

  // Taille de police responsive
  static double sp(double inputFontSize) {
    return inputFontSize * defaultSize;
  }

  // Radius responsive
  static double r(double inputRadius) {
    return inputRadius * defaultSize;
  }

  // Padding/Margin responsive
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: w(horizontal),
      vertical: h(vertical),
    );
  }

  static EdgeInsets all(double value) {
    return EdgeInsets.all(w(value));
  }

  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: w(left),
      top: h(top),
      right: w(right),
      bottom: h(bottom),
    );
  }

  // Vérifications de taille d'écran
  static bool get isTablet => screenWidth >= 768;
  static bool get isDesktop => screenWidth >= 1024;
  static bool get isMobile => screenWidth < 768;
  
  // Catégories de téléphones
  static bool get isSmallPhone => screenWidth <= 320; // iPhone SE, etc.
  static bool get isMediumPhone => screenWidth > 320 && screenWidth <= 375; // iPhone 12 mini, etc.
  static bool get isLargePhone => screenWidth > 375 && screenWidth <= 414; // iPhone 14 Pro Max, etc.
  static bool get isExtraLargePhone => screenWidth > 414; // Très grands téléphones

  // Breakpoints pour différents layouts
  static T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Breakpoints pour différentes tailles de téléphones
  static T phoneSize<T>({
    required T normal,
    T? small,
    T? large,
    T? extraLarge,
  }) {
    if (isExtraLargePhone && extraLarge != null) return extraLarge;
    if (isLargePhone && large != null) return large;
    if (isSmallPhone && small != null) return small;
    return normal;
  }

  // Helpers pour dimensions communes
  static double get statusBarHeight => _mediaQueryData.padding.top;
  static double get bottomBarHeight => _mediaQueryData.padding.bottom;
  static double get appBarHeight => kToolbarHeight;
  
  // Dimensions d'écran sécurisées (sans status bar, etc.)
  static double get safeAreaWidth => screenWidth;
  static double get safeAreaHeight => screenHeight - statusBarHeight - bottomBarHeight;

  // Ratios utiles
  static double get pixelRatio => _mediaQueryData.devicePixelRatio;
  static double get textScaleFactor => _mediaQueryData.textScaleFactor;
}

// Extension pour utiliser plus facilement dans les widgets
extension ResponsiveExtension on num {
  double get w => Responsive.w(toDouble());
  double get h => Responsive.h(toDouble());
  double get sp => Responsive.sp(toDouble());
  double get r => Responsive.r(toDouble());
}

// Widget responsive pour les tailles conditionnelles
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Responsive.responsive(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

// Constantes de design responsives
class ResponsiveConstants {
  // Espacements standards
  static double get tinySpace => 4.w;
  static double get smallSpace => 8.w;
  static double get mediumSpace => 16.w;
  static double get largeSpace => 24.w;
  static double get extraLargeSpace => 32.w;
  
  // Tailles d'icônes
  static double get smallIcon => 16.w;
  static double get mediumIcon => 24.w;
  static double get largeIcon => 32.w;
  static double get extraLargeIcon => 48.w;
  
  // Border radius standards
  static double get smallRadius => 8.r;
  static double get mediumRadius => 12.r;
  static double get largeRadius => 16.r;
  static double get extraLargeRadius => 24.r;
  
  // Tailles de police
  static double get caption => 12.sp;
  static double get body2 => 14.sp;
  static double get body1 => 16.sp;
  static double get subtitle2 => 18.sp;
  static double get subtitle1 => 20.sp;
  static double get headline6 => 24.sp;
  static double get headline5 => 28.sp;
  static double get headline4 => 32.sp;
  
  // Hauteurs de composants
  static double get buttonHeight => 48.h;
  static double get inputHeight => 56.h;
  static double get cardImageHeight => 160.h; // Pour remplacer height: 140
  static double get smallCardImageHeight => 120.h;
  static double get largeCardImageHeight => 200.h;
  
  // Largeurs de composants
  static double get maxContentWidth => 400.w;
  static double get fullWidth => double.infinity;
}