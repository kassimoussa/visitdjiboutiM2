# 📱 Guide d'Intégration API Mobile - Visit Djibouti

> **Version:** 1.0
> **Date:** 6 Janvier 2025
> **Base URL:** `https://your-domain.com/api`

---

## 📋 Table des Matières

1. [Authentification](#authentification)
2. [Points d'Intérêt (POIs)](#points-dintérêt-pois)
3. [Événements](#événements)
4. [Tours](#tours)
5. [Réservations](#réservations)
6. [Favoris](#favoris)
7. [Opérateurs de Tour](#opérateurs-de-tour)
8. [Informations Générales](#informations-générales)
9. [Codes d'Erreur](#codes-derreur)

---

## 🔐 Authentification

### Types d'utilisateurs supportés

1. **Utilisateurs anonymes** - Accès limité sans inscription
2. **Utilisateurs enregistrés** - Compte avec email/mot de passe
3. **OAuth** - Connexion via Google ou Facebook

### 1. Créer un utilisateur anonyme

**Endpoint:** `POST /auth/anonymous`

**Aucun header requis**

**Réponse:**
```json
{
  "success": true,
  "message": "Anonymous user created successfully",
  "data": {
    "user": {
      "id": 123,
      "anonymous_id": "anon_1234567890abcdef",
      "is_anonymous": true,
      "language_preference": "fr"
    },
    "token": "1|laravel_sanctum_token_here"
  }
}
```

**💡 Important:** Stocker `anonymous_id` et `token` localement pour les requêtes futures.

---

### 2. Inscription utilisateur

**Endpoint:** `POST /auth/register`

**Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "language_preference": "fr"
}
```

**Réponse:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 124,
      "name": "John Doe",
      "email": "john@example.com",
      "is_anonymous": false,
      "language_preference": "fr"
    },
    "token": "2|laravel_sanctum_token_here"
  }
}
```

---

### 3. Connexion

**Endpoint:** `POST /auth/login`

**Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

---

### 4. Connexion OAuth (Google/Facebook)

#### Étape 1: Obtenir le token du provider (côté mobile)

Utilisez les SDKs officiels:
- **Google:** `@react-native-google-signin/google-signin`
- **Facebook:** `react-native-fbsdk-next`

#### Étape 2: Authentifier avec le backend

**Endpoint:** `POST /auth/{provider}/token`

**Body:**
```json
{
  "access_token": "oauth_access_token_from_provider",
  "provider_user_id": "123456789"
}
```

**Réponse:**
```json
{
  "success": true,
  "message": "User authenticated successfully",
  "data": {
    "user": {
      "id": 125,
      "name": "Jane Smith",
      "email": "jane@gmail.com",
      "oauth_provider": "google"
    },
    "token": "3|laravel_sanctum_token_here"
  }
}
```

---

### 5. Convertir utilisateur anonyme en compte complet

**Endpoint:** `POST /auth/convert-anonymous`

**Headers:**
```
Authorization: Bearer {anonymous_token}
Accept-Language: fr
```

**Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**💡 Important:** Toutes les données de l'utilisateur anonyme (favoris, réservations) sont conservées!

---

## 🏛️ Points d'Intérêt (POIs)

### 1. Liste des POIs

**Endpoint:** `GET /pois`

**Headers:**
```
Accept-Language: fr
```

**Query Parameters:**
```
?search=lac
&category_id=5
&region=Djibouti
&is_featured=1
&latitude=11.5721
&longitude=43.1456
&radius=50
&sort_by=created_at
&sort_order=desc
&per_page=15
&page=1
```

**Réponse:**
```json
{
  "success": true,
  "data": {
    "pois": [
      {
        "id": 1,
        "slug": "lac-assal",
        "title": "Lac Assal",
        "short_description": "Le lac le plus salé du monde",
        "region": "Djibouti",
        "latitude": 11.6562,
        "longitude": 42.4069,
        "is_featured": true,
        "allow_reservations": true,
        "featured_image": {
          "id": 10,
          "url": "https://domain.com/storage/media/lac-assal.jpg",
          "alt": "Vue du Lac Assal"
        },
        "categories": [
          {
            "id": 5,
            "name": "Nature",
            "icon": "fa-mountain"
          }
        ],
        "distance_km": 15.2,
        "is_favorited": false,
        "favorites_count": 42
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 5,
      "per_page": 15,
      "total": 67
    }
  }
}
```

---

### 2. Détails d'un POI

**Endpoint:** `GET /pois/{id}` ou `GET /pois/{slug}`

**Headers:**
```
Authorization: Bearer {token}
Accept-Language: fr
```

**Réponse:**
```json
{
  "success": true,
  "data": {
    "poi": {
      "id": 1,
      "slug": "lac-assal",
      "title": "Lac Assal",
      "description": "Description complète du POI...",
      "short_description": "Le lac le plus salé du monde",
      "region": "Djibouti",
      "address": "Région de Tadjourah, Djibouti",
      "latitude": 11.6562,
      "longitude": 42.4069,
      "opening_hours": "Ouvert 24h/24",
      "entry_fee": 0,
      "is_free": true,
      "is_featured": true,
      "allow_reservations": true,
      "contact_phone": "+253 21 35 00 00",
      "contact_email": "info@lacassal.dj",
      "website_url": "https://lacassal.dj",
      "featured_image": {...},
      "media": [
        {
          "id": 10,
          "url": "https://domain.com/storage/media/image1.jpg",
          "alt": "Photo 1",
          "order": 0
        },
        {
          "id": 11,
          "url": "https://domain.com/storage/media/image2.jpg",
          "alt": "Photo 2",
          "order": 1
        }
      ],
      "categories": [...],
      "is_favorited": true,
      "favorites_count": 42,
      "views_count": 1523,
      "accessibility": {
        "wheelchair_accessible": true,
        "parking_available": true,
        "public_transport_nearby": false
      },
      "best_time_to_visit": "Octobre à Mars",
      "average_visit_duration": "2-3 heures"
    }
  }
}
```

---

### 3. POIs à proximité

**Endpoint:** `GET /pois/nearby`

**Query Parameters:**
```
?latitude=11.5721
&longitude=43.1456
&radius=50
&limit=10
```

---

## 🎉 Événements

### 1. Liste des événements

**Endpoint:** `GET /events`

**Headers:**
```
Accept-Language: fr
```

**Query Parameters:**
```
?search=festival
&category_id=3
&start_date=2025-01-01
&end_date=2025-12-31
&is_featured=1
&has_spots_available=1
&latitude=11.5721
&longitude=43.1456
&radius=50
&per_page=15
```

**Réponse:**
```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": 1,
        "slug": "festival-mer-rouge",
        "title": "Festival de la Mer Rouge",
        "short_description": "Un festival culturel unique",
        "location": "Djibouti Ville",
        "full_location": "Palais du Peuple, Djibouti Ville",
        "start_date": "2025-03-15T00:00:00.000000Z",
        "end_date": "2025-03-17T00:00:00.000000Z",
        "start_time": "18:00",
        "end_time": "23:00",
        "formatted_date_range": "15-17 Mars 2025",
        "price": 5000,
        "is_free": false,
        "is_featured": true,
        "allow_reservations": true,
        "max_participants": 500,
        "current_participants": 327,
        "available_spots": 173,
        "is_sold_out": false,
        "is_active": true,
        "is_ongoing": false,
        "has_ended": false,
        "organizer": "Ministère de la Culture",
        "manager_type": "government",
        "tour_operator": null,
        "featured_image": {...},
        "categories": [...],
        "is_favorited": false,
        "favorites_count": 89
      }
    ],
    "pagination": {...}
  }
}
```

---

### 2. Détails d'un événement

**Endpoint:** `GET /events/{id}` ou `GET /events/{slug}`

**Réponse inclut en plus:**
```json
{
  "data": {
    "event": {
      "description": "Description complète de l'événement...",
      "location_details": "Détails du lieu...",
      "requirements": "Prérequis pour participer...",
      "program": "Programme détaillé...",
      "additional_info": "Informations supplémentaires...",
      "contact_email": "contact@festival.dj",
      "contact_phone": "+253 21 XX XX XX",
      "website_url": "https://festival.dj",
      "ticket_url": "https://tickets.festival.dj",
      "media": [...]
    }
  }
}
```

---

## 🚌 Tours

### 1. Liste des tours

**Endpoint:** `GET /tours`

**Query Parameters:**
```
?search=cultural
&operator_id=5
&type=cultural
&difficulty=easy
&min_price=1000
&max_price=50000
&max_duration_hours=8
&date_from=2025-01-01
&featured=1
&latitude=11.5721
&longitude=43.1456
&radius=50
```

**Types disponibles:**
- `poi` - Visite de site
- `event` - Accompagnement événement
- `mixed` - Circuit mixte
- `cultural` - Culturel
- `adventure` - Aventure
- `nature` - Nature
- `gastronomic` - Gastronomique

**Niveaux de difficulté:**
- `easy` - Facile
- `moderate` - Modéré
- `difficult` - Difficile
- `expert` - Expert

---

### 2. Réserver un tour

**Endpoint:** `POST /tours/schedules/{schedule_id}/book`

**Headers:**
```
Authorization: Bearer {token}
Accept-Language: fr
```

**Body (utilisateur authentifié):**
```json
{
  "participants_count": 2,
  "special_requirements": "Régime végétarien"
}
```

**Body (utilisateur non authentifié):**
```json
{
  "participants_count": 2,
  "user_name": "John Doe",
  "user_email": "john@example.com",
  "user_phone": "+253 77 XX XX XX",
  "special_requirements": "Régime végétarien"
}
```

**Réponse:**
```json
{
  "success": true,
  "message": "Tour booking successful",
  "data": {
    "reservation": {
      "id": 456,
      "confirmation_number": "TOUR-2025-456",
      "number_of_people": 2,
      "status": "pending",
      "payment_status": "pending",
      "payment_amount": 20000
    },
    "payment_required": true,
    "total_amount": 20000
  }
}
```

---

## 📅 Réservations

### 1. Réserver un événement

**Endpoint:** `POST /events/{event}/register`

#### Pour utilisateurs anonymes/non authentifiés:

**Headers:**
```
Accept-Language: fr
```

**Body:**
```json
{
  "number_of_people": 2,
  "guest_name": "John Doe",
  "guest_email": "john@example.com",
  "guest_phone": "+253 77 XX XX XX",
  "special_requirements": "Accès PMR requis"
}
```

#### Pour utilisateurs authentifiés:

**Headers:**
```
Authorization: Bearer {token}
Accept-Language: fr
```

**Body:**
```json
{
  "number_of_people": 2,
  "special_requirements": "Accès PMR requis"
}
```

**Réponse:**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "registration": {
      "id": 789,
      "confirmation_number": "EVT-2025-789",
      "number_of_people": 2,
      "status": "confirmed",
      "payment_status": "not_required",
      "event": {
        "id": 1,
        "title": "Festival de la Mer Rouge"
      }
    }
  }
}
```

---

### 2. Mes réservations (événements)

**Endpoint:** `GET /my-registrations`

**Headers:**
```
Authorization: Bearer {token}
```

---

### 3. Mes réservations (tours)

**Endpoint:** `GET /tours/my-bookings`

---

### 4. Annuler une réservation

**Événement:** `DELETE /events/{event}/registration`
**Tour:** `DELETE /tours/bookings/{reservation_id}`

---

## ⭐ Favoris

### 1. Ajouter/Retirer un POI des favoris

**Endpoint:** `POST /favorites/pois/{poi}`

**Headers:**
```
Authorization: Bearer {token}
```

**Réponse:**
```json
{
  "success": true,
  "message": "POI added to favorites",
  "data": {
    "is_favorited": true,
    "favorites_count": 43
  }
}
```

---

### 2. Ajouter/Retirer un événement des favoris

**Endpoint:** `POST /favorites/events/{event}`

---

### 3. Liste de tous mes favoris

**Endpoint:** `GET /favorites`

**Réponse:**
```json
{
  "success": true,
  "data": {
    "favorites": [
      {
        "id": 1,
        "favoritable_type": "poi",
        "favoritable": {
          "id": 5,
          "title": "Lac Assal",
          "slug": "lac-assal",
          "featured_image": {...}
        },
        "created_at": "2025-01-05T10:30:00.000000Z"
      },
      {
        "id": 2,
        "favoritable_type": "event",
        "favoritable": {
          "id": 3,
          "title": "Festival de la Mer Rouge",
          "slug": "festival-mer-rouge",
          "start_date": "2025-03-15T00:00:00.000000Z"
        },
        "created_at": "2025-01-04T15:20:00.000000Z"
      }
    ],
    "stats": {
      "total": 2,
      "pois": 1,
      "events": 1
    }
  }
}
```

---

### 4. Mes favoris POIs uniquement

**Endpoint:** `GET /favorites/pois`

---

### 5. Mes favoris événements uniquement

**Endpoint:** `GET /favorites/events`

---

## 🚐 Opérateurs de Tour

### 1. Liste des opérateurs

**Endpoint:** `GET /tour-operators`

**Query Parameters:**
```
?search=safari
&service_type=guided_tours
&certification=national
&min_price=1000
&max_price=100000
&latitude=11.5721
&longitude=43.1456
&radius=50
```

**Services disponibles:**
- `guided_tours` - Visites guidées
- `transportation` - Transport
- `accommodation` - Hébergement
- `restaurant` - Restaurant
- `cultural_tours` - Tours culturels
- `adventure_tours` - Tours aventure
- `wildlife_safari` - Safari
- `diving_snorkeling` - Plongée
- `hiking_trekking` - Randonnée
- `photography_tours` - Tours photo
- `custom_packages` - Forfaits personnalisés

**Niveaux de certification:**
- `local` - Local
- `national` - National
- `international` - International

---

### 2. Détails d'un opérateur

**Endpoint:** `GET /tour-operators/{id}` ou `GET /tour-operators/{slug}`

**Réponse:**
```json
{
  "success": true,
  "data": {
    "tour_operator": {
      "id": 5,
      "slug": "djibouti-safari-adventures",
      "name": "Djibouti Safari Adventures",
      "description": "Expert en safaris et aventures...",
      "email": "contact@safari-dj.com",
      "phone": "+253 21 XX XX XX",
      "website": "https://safari-dj.com",
      "address": "Djibouti Ville",
      "latitude": 11.5721,
      "longitude": 43.1456,
      "certification_type": "national",
      "certification_label": "National",
      "languages_spoken": ["Français", "English", "العربية"],
      "years_experience": 15,
      "is_active": true,
      "is_featured": true,
      "price_range": "mid-range",
      "min_price": 5000,
      "max_price": 150000,
      "currency": "DJF",
      "services": [
        {
          "service_type": "guided_tours",
          "label": "Visites guidées"
        },
        {
          "service_type": "transportation",
          "label": "Transport"
        }
      ],
      "logo": {
        "id": 25,
        "url": "https://domain.com/storage/media/logo.png"
      },
      "tours": [...],
      "events": [...]
    }
  }
}
```

---

## 📚 Informations Générales

### 1. Informations organisation touristique

**Endpoint:** `GET /organization`

**Réponse:**
```json
{
  "success": true,
  "data": {
    "organization": {
      "id": 1,
      "name": "Office National du Tourisme de Djibouti",
      "description": "Promotion du tourisme...",
      "phone": "+253 21 35 28 00",
      "email": "info@visitdjibouti.dj",
      "website": "https://visitdjibouti.dj",
      "address": "Djibouti Ville",
      "opening_hours": "Lun-Ven: 08:00-16:00",
      "social_media": {
        "facebook": "https://facebook.com/visitdjibouti",
        "instagram": "https://instagram.com/visitdjibouti",
        "twitter": "https://twitter.com/visitdjibouti"
      }
    }
  }
}
```

---

### 2. Liens externes utiles

**Endpoint:** `GET /external-links`

**Réponse:**
```json
{
  "success": true,
  "data": {
    "links": [
      {
        "id": 1,
        "title": "Ambassade de France",
        "url": "https://dj.ambafrance.org",
        "category": "embassy",
        "icon": "fa-landmark",
        "is_featured": true
      }
    ]
  }
}
```

---

### 3. Ambassades

**Endpoint:** `GET /embassies`

**Query Parameters:**
```
?type=foreign_in_djibouti
&country=France
&city=Djibouti
```

**Types:**
- `foreign_in_djibouti` - Ambassades étrangères à Djibouti
- `djibouti_abroad` - Ambassades djiboutiennes à l'étranger

---

### 4. Paramètres de l'application

**Endpoint:** `GET /app-settings`

**Réponse:**
```json
{
  "success": true,
  "data": {
    "splash_screen": {
      "logo_url": "https://domain.com/storage/logo.png",
      "background_color": "#1E3A8A",
      "duration_seconds": 3
    },
    "onboarding": {
      "enabled": true,
      "slides": [
        {
          "title": "Découvrez Djibouti",
          "description": "Explorez les merveilles...",
          "image_url": "https://domain.com/storage/onboarding1.jpg"
        }
      ]
    },
    "app_info": {
      "version": "1.0.0",
      "force_update": false,
      "maintenance_mode": false
    }
  }
}
```

---

## ⚠️ Codes d'Erreur

### Codes HTTP

| Code | Signification |
|------|---------------|
| 200 | Succès |
| 201 | Ressource créée |
| 400 | Requête invalide |
| 401 | Non authentifié |
| 403 | Non autorisé |
| 404 | Ressource non trouvée |
| 422 | Erreur de validation |
| 500 | Erreur serveur |

### Format de réponse d'erreur

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": [
      "The email field is required."
    ],
    "password": [
      "The password must be at least 8 characters."
    ]
  }
}
```

---

## 🌍 Multilinguisme

Toutes les API supportent 3 langues:
- **Français** (fr) - Par défaut
- **English** (en)
- **العربية** (ar)

**Header requis:**
```
Accept-Language: fr
```

---

## 🔒 Notes de Sécurité

1. **HTTPS uniquement** - Toutes les requêtes doivent utiliser HTTPS en production
2. **Tokens** - Stocker les tokens de manière sécurisée (Keychain iOS, Keystore Android)
3. **Expiration** - Les tokens Sanctum n'expirent pas par défaut, mais peuvent être révoqués
4. **Rate Limiting** - Limite de 60 requêtes par minute par IP

---

## 🚀 Recommandations d'Implémentation

### 1. Flux d'authentification recommandé

```
1. Au premier lancement:
   - Créer un utilisateur anonyme
   - Stocker anonymous_id et token

2. L'utilisateur peut:
   - Explorer l'app (POIs, Events, Tours)
   - Ajouter des favoris (stockés avec compte anonyme)
   - Faire des réservations (avec email/téléphone)

3. Quand l'utilisateur veut s'inscrire:
   - Appeler /auth/convert-anonymous
   - Toutes les données sont conservées!

4. Ou connexion OAuth:
   - Récupérer token Google/Facebook
   - Appeler /auth/{provider}/token
```

### 2. Gestion des favoris hors ligne

```javascript
// Synchroniser favoris au démarrage
async function syncFavorites() {
  const localFavorites = await getLocalFavorites();
  const remoteFavorites = await api.get('/favorites');

  // Merge et résolution de conflits
  // Envoyer favoris locaux au serveur
  // Mettre à jour DB locale
}
```

### 3. Optimisation images

- Utiliser les URLs `thumbnail_url` quand disponibles
- Implémenter cache d'images (ex: React Native Fast Image)
- Lazy loading pour les listes

---

## 📞 Support

Pour toute question sur l'intégration:
- **Email:** dev@visitdjibouti.dj
- **Documentation complète:** Voir `API_DOCUMENTATION.md`

---

**Dernière mise à jour:** 6 Janvier 2025
**Version API:** 1.0
