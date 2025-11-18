import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

/// Widget pour afficher un état d'erreur avec possibilité de réessayer
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final Color? iconColor;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryButtonText,
    this.iconColor,
  });

  /// Erreur de connexion
  factory ErrorStateWidget.connection({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return ErrorStateWidget(
      title: 'Erreur de connexion',
      message: customMessage ??
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      onRetry: onRetry,
    );
  }

  /// Erreur de chargement de données
  factory ErrorStateWidget.loading({
    required String resourceName,
    VoidCallback? onRetry,
    String? errorDetails,
  }) {
    return ErrorStateWidget(
      title: 'Erreur de chargement',
      message: errorDetails ??
          'Impossible de charger $resourceName. Veuillez réessayer.',
      icon: Icons.cloud_off,
      iconColor: Colors.red,
      onRetry: onRetry,
    );
  }

  /// Erreur générique
  factory ErrorStateWidget.generic({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      title: title ?? 'Une erreur est survenue',
      message: message ??
          'Une erreur inattendue s\'est produite. Veuillez réessayer.',
      icon: Icons.error_outline,
      iconColor: Colors.red,
      onRetry: onRetry,
    );
  }

  /// Erreur de permissions
  factory ErrorStateWidget.permission({
    required String permissionName,
    VoidCallback? onOpenSettings,
  }) {
    return ErrorStateWidget(
      title: 'Permission requise',
      message: 'L\'application a besoin de la permission $permissionName pour fonctionner.',
      icon: Icons.lock_outline,
      iconColor: Colors.orange,
      onRetry: onOpenSettings,
      retryButtonText: 'Ouvrir les paramètres',
    );
  }

  /// Erreur timeout
  factory ErrorStateWidget.timeout({
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      title: 'Délai d\'attente dépassé',
      message: 'La requête a pris trop de temps. Veuillez réessayer.',
      icon: Icons.timer_off,
      iconColor: Colors.orange,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icône d'erreur
            Icon(
              icon,
              size: 64,
              color: iconColor ?? Colors.red.shade300,
            ),
            SizedBox(height: 24.h),

            // Titre
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2233),
              ),
              textAlign: TextAlign.center,
            ),

            // Message
            if (message != null) ...[
              SizedBox(height: 12.h),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Bouton réessayer
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  retryButtonText != null ? Icons.settings : Icons.refresh,
                ),
                label: Text(retryButtonText ?? 'Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: Responsive.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher une erreur dans une SnackBar améliorée
class ErrorSnackBar {
  /// Affiche une snackbar d'erreur
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
            ],
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  /// Affiche une snackbar de succès
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  /// Affiche une snackbar d'avertissement
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  /// Affiche une snackbar d'information
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF3860F8),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

/// Dialog d'erreur amélioré
class ErrorDialog {
  /// Affiche un dialog d'erreur
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? retryButtonText,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 18.sp),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(retryButtonText ?? 'Réessayer'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
