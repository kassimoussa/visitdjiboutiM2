# 📚 Documentation des Nouveaux Endpoints - Visit Djibouti API

Ce document présente les nouveaux endpoints ajoutés à l'API Visit Djibouti.

---

## 📋 Table des matières

1. [Endpoints de Contenu Global](#1-endpoints-de-contenu-global)
   - [GET /api/content/all](#get-apicontentall)
   - [GET /api/content/geolocated](#get-apicontentgeolocated)
2. [Endpoints de Récupération de Mot de Passe](#2-endpoints-de-récupération-de-mot-de-passe)
   - [POST /api/auth/forgot-password](#post-apiauthforgot-password)
   - [POST /api/auth/reset-password](#post-apiauthreset-password)

---

## 1. Endpoints de Contenu Global

### GET /api/content/all

Récupère **tout le contenu** de l'application : POIs, Events, Tours et Activities en une seule requête.

#### 📍 Endpoint
```
GET /api/content/all
```

#### 🔑 Authentification
Non requis (Public)

#### 📥 Paramètres de requête (Query Parameters)

| Paramètre | Type | Requis | Défaut | Description |
|-----------|------|--------|--------|-------------|
| `featured` | boolean | Non | - | Filtrer par contenu en vedette (`true`/`false`) |
| `region` | string | Non | - | Filtrer par région (Djibouti, Ali Sabieh, Dikhil, Tadjourah, Obock, Arta) |
| `search` | string | Non | - | Rechercher dans les noms et descriptions |

#### 📨 Headers

| Header | Valeur | Description |
|--------|--------|-------------|
| `Accept` | `application/json` | Format de réponse |
| `Accept-Language` | `fr`, `en`, `ar` | Langue des traductions (défaut: `fr`) |

#### ✅ Réponse réussie (200 OK)

```json
{
  "success": true,
  "data": {
    "content": [
      {
        "type": "poi",
        "id": 1,
        "slug": "lac-assal",
        "name": "Lac Assal",
        "description": "Le lac le plus salé du monde...",
        "short_description": "Lac salé exceptionnel",
        "latitude": 11.6583,
        "longitude": 42.4083,
        "region": "Tadjourah",
        "is_featured": true,
        "featured_image": {
          "id": 5,
          "url": "/storage/media/images/lac-assal.jpg",
          "thumbnail_url": "/storage/media/images/thumbnails/lac-assal.jpg"
        },
        "categories": [
          {
            "id": 3,
            "name": "Nature",
            "slug": "nature"
          }
        ],
        "created_at": "2025-01-15T10:30:00.000000Z",
        "updated_at": "2025-01-20T14:20:00.000000Z"
      },
      {
        "type": "event",
        "id": 5,
        "slug": "festival-nomade",
        "name": "Festival Nomade",
        "description": "Festival culturel...",
        "short_description": "Célébration de la culture nomade",
        "latitude": 11.5886,
        "longitude": 43.1456,
        "location": "Place Menelik",
        "region": "Djibouti",
        "start_date": "2025-12-01",
        "end_date": "2025-12-03",
        "start_time": "18:00:00",
        "end_time": "23:00:00",
        "is_featured": true,
        "featured_image": {...},
        "categories": [...],
        "created_at": "2025-02-10T08:15:00.000000Z",
        "updated_at": "2025-02-12T09:30:00.000000Z"
      },
      {
        "type": "tour",
        "id": 3,
        "slug": "desert-safari",
        "name": "Safari dans le désert",
        "description": "Excursion guidée...",
        "short_description": "Aventure dans le désert",
        "meeting_point_latitude": 11.5950,
        "meeting_point_longitude": 43.1480,
        "meeting_point_address": "Hôtel Sheraton, Djibouti",
        "price": 5000.00,
        "currency": "DJF",
        "duration_hours": 6,
        "start_date": "2025-03-01",
        "end_date": "2025-03-15",
        "is_featured": false,
        "featured_image": {...},
        "tour_operator": {
          "id": 2,
          "name": "Desert Tours Djibouti"
        },
        "created_at": "2025-02-20T11:00:00.000000Z",
        "updated_at": "2025-02-22T15:45:00.000000Z"
      },
      {
        "type": "activity",
        "id": 2,
        "slug": "plongee-sous-marine",
        "name": "Plongée sous-marine",
        "description": "Exploration des fonds marins...",
        "short_description": "Plongée guidée",
        "latitude": 11.5920,
        "longitude": 43.1470,
        "location_address": "Plage de Doralé",
        "region": "Djibouti",
        "price": 3500.00,
        "currency": "DJF",
        "duration_hours": 3,
        "duration_minutes": 30,
        "difficulty_level": "intermediate",
        "is_featured": true,
        "featured_image": {...},
        "tour_operator": {
          "id": 4,
          "name": "Ocean Adventures"
        },
        "created_at": "2025-01-25T09:20:00.000000Z",
        "updated_at": "2025-02-01T13:10:00.000000Z"
      }
    ],
    "total": 4,
    "counts": {
      "pois": 1,
      "events": 1,
      "tours": 1,
      "activities": 1
    }
  }
}
```

#### 🎯 Cas d'usage

- Page d'accueil avec contenu mixte
- Recherche globale dans toute l'application
- Feed d'actualités touristiques
- Suggestions de contenu "Découvrir Djibouti"

#### 📝 Exemples de requêtes

**1. Récupérer tout le contenu**
```bash
curl -X GET "http://djvi.test:8080/api/content/all" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

**2. Récupérer uniquement le contenu en vedette**
```bash
curl -X GET "http://djvi.test:8080/api/content/all?featured=true" \
  -H "Accept: application/json" \
  -H "Accept-Language: en"
```

**3. Filtrer par région**
```bash
curl -X GET "http://djvi.test:8080/api/content/all?region=Djibouti" \
  -H "Accept: application/json" \
  -H "Accept-Language: ar"
```

**4. Recherche textuelle**
```bash
curl -X GET "http://djvi.test:8080/api/content/all?search=plage" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

**5. Combinaison de filtres**
```bash
curl -X GET "http://djvi.test:8080/api/content/all?featured=true&region=Tadjourah&search=lac" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

---

### GET /api/content/geolocated

Récupère **uniquement le contenu avec coordonnées GPS** : POIs, Events et Activities. Supporte la recherche à proximité.

#### 📍 Endpoint
```
GET /api/content/geolocated
```

#### 🔑 Authentification
Non requis (Public)

#### 📥 Paramètres de requête (Query Parameters)

| Paramètre | Type | Requis | Défaut | Description |
|-----------|------|--------|--------|-------------|
| `featured` | boolean | Non | - | Filtrer par contenu en vedette |
| `region` | string | Non | - | Filtrer par région |
| `search` | string | Non | - | Rechercher dans les noms et descriptions |
| `latitude` | float | Non | - | Latitude de l'utilisateur pour recherche à proximité |
| `longitude` | float | Non | - | Longitude de l'utilisateur pour recherche à proximité |
| `radius` | integer | Non | 50 | Rayon de recherche en kilomètres (utilisé avec latitude/longitude) |

#### 📨 Headers

| Header | Valeur | Description |
|--------|--------|-------------|
| `Accept` | `application/json` | Format de réponse |
| `Accept-Language` | `fr`, `en`, `ar` | Langue des traductions |

#### ✅ Réponse réussie (200 OK)

**Sans coordonnées GPS :**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "type": "poi",
        "id": 1,
        "slug": "lac-assal",
        "name": "Lac Assal",
        "latitude": 11.6583,
        "longitude": 42.4083,
        "region": "Tadjourah",
        "is_featured": true,
        ...
      }
    ],
    "total": 3,
    "counts": {
      "pois": 1,
      "events": 1,
      "activities": 1
    },
    "search_center": null
  }
}
```

**Avec coordonnées GPS (recherche à proximité) :**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "type": "activity",
        "id": 2,
        "name": "Plongée sous-marine",
        "latitude": 11.5920,
        "longitude": 43.1470,
        "distance_km": 0.85,
        ...
      },
      {
        "type": "poi",
        "id": 1,
        "name": "Lac Assal",
        "latitude": 11.6583,
        "longitude": 42.4083,
        "distance_km": 12.45,
        ...
      },
      {
        "type": "event",
        "id": 5,
        "name": "Festival Nomade",
        "latitude": 11.5886,
        "longitude": 43.1456,
        "distance_km": 24.30,
        ...
      }
    ],
    "total": 3,
    "counts": {
      "pois": 1,
      "events": 1,
      "activities": 1
    },
    "search_center": {
      "latitude": 11.5886,
      "longitude": 43.1456,
      "radius_km": 50
    }
  }
}
```

#### 🎯 Cas d'usage

- Carte interactive avec markers
- Fonction "Près de moi"
- Itinéraires touristiques
- Exploration géographique
- Affichage de contenu sur une carte

#### 📝 Exemples de requêtes

**1. Récupérer tout le contenu géolocalisé**
```bash
curl -X GET "http://djvi.test:8080/api/content/geolocated" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

**2. Recherche à proximité (rayon par défaut : 50km)**
```bash
curl -X GET "http://djvi.test:8080/api/content/geolocated?latitude=11.5886&longitude=43.1456" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

**3. Recherche à proximité avec rayon personnalisé (25km)**
```bash
curl -X GET "http://djvi.test:8080/api/content/geolocated?latitude=11.5886&longitude=43.1456&radius=25" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

**4. Contenu géolocalisé en vedette uniquement**
```bash
curl -X GET "http://djvi.test:8080/api/content/geolocated?featured=true" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

**5. Combinaison : proximité + région + recherche**
```bash
curl -X GET "http://djvi.test:8080/api/content/geolocated?latitude=11.5886&longitude=43.1456&radius=30&region=Djibouti&search=plage" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

#### 🗺️ Calcul de distance

La distance est calculée avec la **formule de Haversine** qui prend en compte la courbure de la Terre :

- Unité : kilomètres (km)
- Précision : 2 décimales (ex: 12.45 km)
- Rayon terrestre : 6371 km

---

## 2. Endpoints de Récupération de Mot de Passe

### POST /api/auth/forgot-password

Envoie un email de réinitialisation de mot de passe à l'utilisateur.

#### 📍 Endpoint
```
POST /api/auth/forgot-password
```

#### 🔑 Authentification
Non requis (Public)

#### 📥 Corps de la requête (JSON)

```json
{
  "email": "user@example.com"
}
```

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| `email` | string | Oui | Email de l'utilisateur (doit exister dans `app_users`) |

#### 📨 Headers

| Header | Valeur | Description |
|--------|--------|-------------|
| `Content-Type` | `application/json` | Format du corps |
| `Accept` | `application/json` | Format de réponse |

#### ✅ Réponse réussie (200 OK)

```json
{
  "success": true,
  "message": "Password reset link sent to your email"
}
```

#### ❌ Erreurs possibles

**1. Validation échouée (422 Unprocessable Entity)**
```json
{
  "success": false,
  "message": "Validation errors",
  "errors": {
    "email": [
      "validation.required",
      "validation.email",
      "validation.exists"
    ]
  }
}
```

**2. Utilisateur non trouvé (404 Not Found)**
```json
{
  "success": false,
  "message": "User not found"
}
```

**3. Compte désactivé (403 Forbidden)**
```json
{
  "success": false,
  "message": "Account is deactivated"
}
```

**4. Erreur serveur (500 Internal Server Error)**
```json
{
  "success": false,
  "message": "Failed to send password reset email",
  "error": "Detailed error message"
}
```

#### 🎯 Fonctionnalités

- ✅ Génération d'un token unique de 64 caractères
- ✅ Token hashé dans la base de données (sécurité)
- ✅ Suppression des anciens tokens (un seul token actif par email)
- ✅ Expiration du token : **60 minutes**
- ✅ Envoi d'email avec lien de réinitialisation
- ✅ Email design professionnel aux couleurs Visit Djibouti

#### 📧 Email envoyé

L'utilisateur reçoit un email contenant :
- Message de bienvenue personnalisé avec son nom
- Bouton "Réinitialiser mon mot de passe"
- Lien de réinitialisation (valable 60 minutes)
- Token visible en cas de problème avec le bouton
- Conseils de sécurité
- Design responsive et professionnel

#### 📝 Exemple de requête

```bash
curl -X POST "http://djvi.test:8080/api/auth/forgot-password" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "user@visitdjibouti.dj"
  }'
```

---

### POST /api/auth/reset-password

Réinitialise le mot de passe de l'utilisateur avec le token reçu par email.

#### 📍 Endpoint
```
POST /api/auth/reset-password
```

#### 🔑 Authentification
Non requis (Public)

#### 📥 Corps de la requête (JSON)

```json
{
  "email": "user@example.com",
  "token": "xYz123AbC...64caracteres",
  "password": "NewPassword123!",
  "password_confirmation": "NewPassword123!"
}
```

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| `email` | string | Oui | Email de l'utilisateur |
| `token` | string | Oui | Token reçu par email (64 caractères) |
| `password` | string | Oui | Nouveau mot de passe (min 8 caractères) |
| `password_confirmation` | string | Oui | Confirmation du mot de passe (doit correspondre) |

#### 📨 Headers

| Header | Valeur | Description |
|--------|--------|-------------|
| `Content-Type` | `application/json` | Format du corps |
| `Accept` | `application/json` | Format de réponse |

#### ✅ Réponse réussie (200 OK)

```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

#### ❌ Erreurs possibles

**1. Validation échouée (422 Unprocessable Entity)**
```json
{
  "success": false,
  "message": "Validation errors",
  "errors": {
    "email": ["validation.required", "validation.email", "validation.exists"],
    "token": ["validation.required"],
    "password": [
      "validation.required",
      "validation.min.string",
      "validation.confirmed"
    ]
  }
}
```

**2. Token invalide ou expiré (400 Bad Request)**
```json
{
  "success": false,
  "message": "Invalid or expired reset token"
}
```

**3. Token expiré (400 Bad Request)**
```json
{
  "success": false,
  "message": "Reset token has expired"
}
```

**4. Token incorrect (400 Bad Request)**
```json
{
  "success": false,
  "message": "Invalid reset token"
}
```

**5. Erreur serveur (500 Internal Server Error)**
```json
{
  "success": false,
  "message": "Password reset failed",
  "error": "Detailed error message"
}
```

#### 🎯 Fonctionnalités

- ✅ Vérification de l'existence du token
- ✅ Vérification de l'expiration (60 minutes)
- ✅ Vérification du hash du token (sécurité)
- ✅ Mise à jour du mot de passe (hashé avec bcrypt)
- ✅ Suppression du token utilisé
- ✅ **Révocation de tous les tokens API Sanctum** (sécurité maximale)
- ✅ Validation du mot de passe (min 8 caractères, confirmation)

#### 🔒 Sécurité

Après réinitialisation réussie :
1. Le token est supprimé de la base de données
2. **Tous les tokens API de l'utilisateur sont révoqués**
3. L'utilisateur doit se reconnecter sur tous ses appareils
4. Cela empêche l'accès non autorisé si le compte était compromis

#### 📝 Exemple de requête

```bash
curl -X POST "http://djvi.test:8080/api/auth/reset-password" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "user@visitdjibouti.dj",
    "token": "xYz123AbC...64caracteres",
    "password": "NewSecurePassword123!",
    "password_confirmation": "NewSecurePassword123!"
  }'
```

---

## 📊 Résumé des Nouveaux Endpoints

| Endpoint | Méthode | Auth | Description |
|----------|---------|------|-------------|
| `/api/content/all` | GET | Non | Tout le contenu (POIs, Events, Tours, Activities) |
| `/api/content/geolocated` | GET | Non | Contenu avec coordonnées GPS + recherche à proximité |
| `/api/auth/forgot-password` | POST | Non | Demande de réinitialisation de mot de passe |
| `/api/auth/reset-password` | POST | Non | Réinitialisation du mot de passe avec token |

---

## 🔧 Configuration Email

Pour que les emails de récupération de mot de passe fonctionnent en production, configurez votre `.env` :

### Option recommandée : Brevo (ex-Sendinblue)

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp-relay.brevo.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@visitdjibouti.dj
MAIL_PASSWORD=votre-api-key-brevo
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@visitdjibouti.dj
MAIL_FROM_NAME="Visit Djibouti"
```

### Mode développement : Log (actuel)

```env
MAIL_MAILER=log
```

Les emails sont écrits dans `storage/logs/laravel.log`

---

## 📱 Exemples d'intégration Mobile

### Flutter/Dart

**Récupérer tout le contenu :**
```dart
Future<Map<String, dynamic>> getAllContent({
  bool? featured,
  String? region,
  String? search,
  String locale = 'fr',
}) async {
  final queryParams = <String, String>{};
  if (featured != null) queryParams['featured'] = featured.toString();
  if (region != null) queryParams['region'] = region;
  if (search != null) queryParams['search'] = search;

  final uri = Uri.parse('http://djvi.test:8080/api/content/all')
      .replace(queryParameters: queryParams);

  final response = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Accept-Language': locale,
    },
  );

  return json.decode(response.body);
}
```

**Recherche géolocalisée :**
```dart
Future<Map<String, dynamic>> getNearbyContent({
  required double latitude,
  required double longitude,
  int radius = 50,
  String locale = 'fr',
}) async {
  final uri = Uri.parse('http://djvi.test:8080/api/content/geolocated')
      .replace(queryParameters: {
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'radius': radius.toString(),
  });

  final response = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Accept-Language': locale,
    },
  );

  return json.decode(response.body);
}
```

**Mot de passe oublié :**
```dart
Future<bool> forgotPassword(String email) async {
  final response = await http.post(
    Uri.parse('http://djvi.test:8080/api/auth/forgot-password'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: json.encode({'email': email}),
  );

  final data = json.decode(response.body);
  return data['success'] ?? false;
}
```

**Réinitialiser mot de passe :**
```dart
Future<bool> resetPassword({
  required String email,
  required String token,
  required String password,
  required String passwordConfirmation,
}) async {
  final response = await http.post(
    Uri.parse('http://djvi.test:8080/api/auth/reset-password'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: json.encode({
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    }),
  );

  final data = json.decode(response.body);
  return data['success'] ?? false;
}
```

---

## 🧪 Tests

### Test du contenu global

```bash
# Test basique
curl "http://djvi.test:8080/api/content/all" -H "Accept-Language: fr"

# Avec filtres
curl "http://djvi.test:8080/api/content/all?featured=true&region=Djibouti"
```

### Test du contenu géolocalisé

```bash
# Sans GPS
curl "http://djvi.test:8080/api/content/geolocated"

# Avec GPS (position à Djibouti centre-ville)
curl "http://djvi.test:8080/api/content/geolocated?latitude=11.5886&longitude=43.1456&radius=25"
```

### Test de récupération de mot de passe

```bash
# 1. Demande de réinitialisation
curl -X POST "http://djvi.test:8080/api/auth/forgot-password" \
  -H "Content-Type: application/json" \
  -d '{"email":"user@visitdjibouti.dj"}'

# 2. Vérifier l'email dans storage/logs/laravel.log
# 3. Copier le token de l'email
# 4. Réinitialiser le mot de passe
curl -X POST "http://djvi.test:8080/api/auth/reset-password" \
  -H "Content-Type: application/json" \
  -d '{
    "email":"user@visitdjibouti.dj",
    "token":"TOKEN_FROM_EMAIL",
    "password":"NewPassword123!",
    "password_confirmation":"NewPassword123!"
  }'
```

---

## 📝 Notes importantes

### Endpoints de contenu

1. **Tri des résultats** :
   - Sans GPS : Tri par `is_featured` (desc) puis `created_at` (desc)
   - Avec GPS : Tri par `distance_km` (asc) - du plus proche au plus loin

2. **Champ `type`** :
   - Permet d'identifier facilement le type de contenu : `poi`, `event`, `tour`, `activity`
   - Utile pour affichage conditionnel dans l'app mobile

3. **Tours non inclus dans `/geolocated`** :
   - Les Tours utilisent `meeting_point_latitude/longitude` au lieu de `latitude/longitude`
   - Pas de filtrage géographique possible pour les Tours actuellement

### Récupération de mot de passe

1. **Sécurité** :
   - Token hashé en base de données
   - Expiration de 60 minutes
   - Un seul token actif par email
   - Révocation de tous les tokens API après reset

2. **Email** :
   - Template responsive et professionnel
   - Bouton cliquable + lien manuel
   - Conseils de sécurité inclus
   - Design aux couleurs Visit Djibouti

3. **Production** :
   - Configurer un service email (Brevo recommandé)
   - Ne pas utiliser Gmail
   - Tester l'envoi avant déploiement

---

## 🚀 Prochaines étapes recommandées

1. ✅ Configurer Brevo pour l'envoi d'emails en production
2. ✅ Créer des templates email multilingues (EN, AR)
3. ✅ Ajouter rate limiting sur forgot-password (protection anti-spam)
4. ✅ Implémenter la vérification d'email à l'inscription
5. ✅ Ajouter des tests automatisés pour ces endpoints

---

**Documentation générée le 16 novembre 2025**
**Version de l'API : 1.0**
**Visit Djibouti - Promotion du Tourisme à Djibouti**
