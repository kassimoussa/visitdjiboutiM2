# Guide d'Error Handling et Retry Logic

Ce document explique comment utiliser les nouveaux outils d'error handling et de retry logic dans l'application Visit Djibouti.

## 📦 Nouveaux Composants

### 1. `ErrorStateWidget` - Widget d'erreur réutilisable

Widget pour afficher des états d'erreur avec possibilité de réessayer.

#### Constructeurs Factory

```dart
// Erreur de connexion
ErrorStateWidget.connection(
  onRetry: () => _loadData(),
  customMessage: "Message personnalisé",
);

// Erreur de chargement
ErrorStateWidget.loading(
  resourceName: "points d'intérêt",
  onRetry: () => _loadPois(),
  errorDetails: "Détails de l'erreur",
);

// Erreur générique
ErrorStateWidget.generic(
  title: "Titre personnalisé",
  message: "Message personnalisé",
  onRetry: () => _retry(),
);

// Erreur de permissions
ErrorStateWidget.permission(
  permissionName: "localisation",
  onOpenSettings: () => openAppSettings(),
);

// Erreur timeout
ErrorStateWidget.timeout(
  onRetry: () => _retry(),
);
```

#### Exemple d'utilisation dans une page

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  List<Poi> _pois = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final response = await _poiService.getPois();
      if (response.success && response.data != null) {
        setState(() {
          _pois = response.data!.pois;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = RetryHelper.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return ErrorStateWidget.loading(
        resourceName: "points d'intérêt",
        errorDetails: _errorMessage,
        onRetry: _loadData, // Bouton réessayer
      );
    }

    // Afficher les données...
    return ListView.builder(...);
  }
}
```

### 2. `ErrorSnackBar` - SnackBars améliorées

Classe statique pour afficher des snackbars avec différents niveaux de sévérité.

```dart
// Erreur
ErrorSnackBar.show(
  context,
  message: "Impossible de charger les données",
  title: "Erreur", // optionnel
  onRetry: () => _loadData(),
);

// Succès
ErrorSnackBar.showSuccess(
  context,
  message: "Données chargées avec succès",
);

// Avertissement
ErrorSnackBar.showWarning(
  context,
  message: "Connexion instable détectée",
  onAction: () => _checkConnection(),
  actionLabel: "Vérifier",
);

// Information
ErrorSnackBar.showInfo(
  context,
  message: "Mise à jour disponible",
);
```

### 3. `ErrorDialog` - Dialogs d'erreur

```dart
await ErrorDialog.show(
  context,
  title: "Erreur de chargement",
  message: "Impossible de charger les données. Veuillez réessayer.",
  onRetry: () => _loadData(),
  retryButtonText: "Réessayer maintenant",
  barrierDismissible: true,
);
```

### 4. `RetryHelper` - Retry Logic avec Exponential Backoff

Classe helper pour gérer les retries automatiques.

#### Utilisation basique

```dart
try {
  final result = await RetryHelper.execute(
    operation: () => _apiCall(),
    maxAttempts: 3,
    initialDelay: 1000, // 1 seconde
    maxDelay: 10000, // 10 secondes max
    backoffMultiplier: 2.0,
  );

  // Utiliser le résultat...
} catch (e) {
  // Toutes les tentatives ont échoué
  print('Échec après retry: $e');
}
```

#### Utilisation pour API calls

```dart
try {
  final result = await RetryHelper.apiCall(
    apiRequest: () => _poiService.getPois(),
    maxAttempts: 3,
    operationName: "Chargement POIs", // Pour les logs
  );

  // Traiter le résultat...
} catch (e) {
  // Gérer l'erreur finale
}
```

#### Utilisation avec extension

```dart
// Au lieu de:
final result = await _poiService.getPois();

// Utiliser:
final result = await (() => _poiService.getPois()).withApiRetry(
  maxAttempts: 3,
  operationName: "Chargement POIs",
);
```

#### Retry avec callback de progression

```dart
await RetryHelper.executeWithProgress(
  operation: () => _apiCall(),
  maxAttempts: 3,
  onRetry: (attempt, maxAttempts) {
    print('Tentative $attempt/$maxAttempts');
    // Mettre à jour l'UI si nécessaire
  },
);
```

### 5. Utilitaires `RetryHelper`

```dart
// Obtenir un message d'erreur lisible
final message = RetryHelper.getErrorMessage(error);
ErrorSnackBar.show(context, message: message);

// Vérifier le type d'erreur
if (RetryHelper.isNetworkError(error)) {
  // Gérer l'erreur réseau
} else if (RetryHelper.isServerError(error)) {
  // Gérer l'erreur serveur
}
```

## 📝 Exemples Complets

### Exemple 1: Page avec retry automatique

```dart
class DiscoverPage extends StatefulWidget {
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final PoiService _poiService = PoiService();

  bool _isLoading = true;
  bool _hasError = false;
  List<Poi> _pois = [];

  @override
  void initState() {
    super.initState();
    _loadPois();
  }

  Future<void> _loadPois() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Utiliser retry automatique
      final response = await RetryHelper.apiCall(
        apiRequest: () => _poiService.getPois(),
        maxAttempts: 3,
        operationName: "Chargement POIs",
      );

      if (response.success && response.data != null) {
        setState(() {
          _pois = response.data!.pois;
          _isLoading = false;
        });

        // Afficher un message de succès
        ErrorSnackBar.showSuccess(
          context,
          message: "${_pois.length} lieux chargés",
        );
      } else {
        throw Exception(response.message ?? "Erreur inconnue");
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });

      // Afficher une erreur avec bouton retry
      if (mounted) {
        ErrorSnackBar.show(
          context,
          title: "Erreur de chargement",
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadPois,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Chargement..."),
          ],
        ),
      );
    }

    if (_hasError) {
      return ErrorStateWidget.loading(
        resourceName: "points d'intérêt",
        onRetry: _loadPois,
      );
    }

    if (_pois.isEmpty) {
      return ErrorStateWidget.generic(
        title: "Aucun résultat",
        message: "Aucun point d'intérêt disponible pour le moment.",
        onRetry: _loadPois,
      );
    }

    return ListView.builder(
      itemCount: _pois.length,
      itemBuilder: (context, index) {
        return PoiCard(poi: _pois[index]);
      },
    );
  }
}
```

### Exemple 2: Améliorer un service existant

```dart
// Avant:
class PoiService {
  Future<ApiResponse<PoiListData>> getPois() async {
    try {
      final response = await _apiClient.get('/pois');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

// Après:
import '../utils/retry_helper.dart';

class PoiService {
  Future<ApiResponse<PoiListData>> getPois() async {
    try {
      // Ajouter retry logic
      final response = await RetryHelper.apiCall(
        apiRequest: () => _apiClient.get('/pois'),
        maxAttempts: 3,
        operationName: "GET /pois",
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: RetryHelper.getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
```

### Exemple 3: Pull-to-refresh avec retry

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Poi> _pois = [];

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await RetryHelper.apiCall(
        apiRequest: () => _poiService.getPois(),
        maxAttempts: 3,
      );

      if (response.success && response.data != null) {
        setState(() {
          _pois = response.data!.pois;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });

      if (mounted) {
        ErrorSnackBar.show(
          context,
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadData,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData, // Pull-to-refresh
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return ErrorStateWidget.loading(
        resourceName: "données",
        onRetry: _loadData,
      );
    }

    return ListView.builder(
      itemCount: _pois.length,
      itemBuilder: (context, index) {
        return PoiCard(poi: _pois[index]);
      },
    );
  }
}
```

## 🎯 Bonnes Pratiques

### 1. Choisir le bon nombre de retries

- **Opérations critiques** : 3-5 tentatives
- **Opérations secondaires** : 1-3 tentatives
- **Opérations temps réel** : 1-2 tentatives

### 2. Configurer les délais appropriés

```dart
// Pour API rapide
RetryHelper.execute(
  operation: () => _apiCall(),
  initialDelay: 500,   // 0.5 seconde
  maxDelay: 3000,      // 3 secondes max
);

// Pour API lente
RetryHelper.execute(
  operation: () => _apiCall(),
  initialDelay: 2000,  // 2 secondes
  maxDelay: 10000,     // 10 secondes max
);
```

### 3. Gérer les erreurs spécifiques

```dart
try {
  final result = await RetryHelper.apiCall(...);
} on DioException catch (e) {
  if (RetryHelper.isNetworkError(e)) {
    // Afficher message réseau
    ErrorSnackBar.show(
      context,
      title: "Pas de connexion",
      message: "Vérifiez votre connexion internet",
      onRetry: _retry,
    );
  } else if (RetryHelper.isServerError(e)) {
    // Afficher message serveur
    ErrorSnackBar.show(
      context,
      title: "Erreur serveur",
      message: "Le serveur rencontre des difficultés",
    );
  }
}
```

### 4. Logs et debugging

```dart
// RetryHelper log automatiquement:
// [RETRY] Tentative 1/3
// [RETRY] Erreur: DioException. Nouvelle tentative dans 1000ms...
// [RETRY] Tentative 2/3
// [RETRY] Échec après 3 tentative(s): DioException

// Pour vos propres logs:
try {
  final result = await RetryHelper.apiCall(
    apiRequest: () => _apiCall(),
    operationName: "Mon opération", // Apparaît dans les logs
  );
} catch (e) {
  print('[MA_PAGE] Échec: ${RetryHelper.getErrorMessage(e)}');
}
```

## 🚀 Migration du Code Existant

### Étape 1: Importer les nouveaux outils

```dart
import '../widgets/error_state_widget.dart';
import '../utils/retry_helper.dart';
```

### Étape 2: Remplacer les try-catch simples

```dart
// Avant:
try {
  final response = await _service.getData();
  // ...
} catch (e) {
  print('Erreur: $e');
}

// Après:
try {
  final response = await RetryHelper.apiCall(
    apiRequest: () => _service.getData(),
    maxAttempts: 3,
  );
  // ...
} catch (e) {
  ErrorSnackBar.show(
    context,
    message: RetryHelper.getErrorMessage(e),
    onRetry: _loadData,
  );
}
```

### Étape 3: Remplacer les widgets d'erreur

```dart
// Avant:
if (_hasError) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.error),
        Text('Erreur'),
        TextButton(
          onPressed: _retry,
          child: Text('Réessayer'),
        ),
      ],
    ),
  );
}

// Après:
if (_hasError) {
  return ErrorStateWidget.loading(
    resourceName: "données",
    onRetry: _retry,
  );
}
```

## ✅ Checklist d'Implémentation

- [ ] Importer les nouveaux composants
- [ ] Ajouter retry logic aux appels API critiques
- [ ] Remplacer les widgets d'erreur par `ErrorStateWidget`
- [ ] Utiliser `ErrorSnackBar` pour les notifications
- [ ] Ajouter des boutons "Réessayer" sur les pages
- [ ] Configurer les délais de retry appropriés
- [ ] Tester avec connexion instable
- [ ] Tester avec serveur indisponible
- [ ] Vérifier les logs de retry

## 📚 Références

- `lib/presentation/widgets/error_state_widget.dart` - Widgets d'erreur
- `lib/core/utils/retry_helper.dart` - Retry logic
- `ERROR_HANDLING_GUIDE.md` - Ce document
