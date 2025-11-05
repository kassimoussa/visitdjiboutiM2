# Guide d'Implémentation Mobile - Activités, Avis & Commentaires

## Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Régions](#régions)
3. [Activités](#activités)
4. [Avis (Reviews)](#avis-reviews)
5. [Commentaires](#commentaires)
6. [Modèles de Données](#modèles-de-données)
7. [Cas d'Usage UI/UX](#cas-dusage-uiux)
8. [Gestion des Erreurs](#gestion-des-erreurs)

---

## Vue d'ensemble

### Architecture Backend
- **Base URL API**: `https://yourdomain.com/api`
- **Authentification**: Laravel Sanctum (Bearer Token)
- **Support Invités**: Header `X-Guest-ID` pour tracking
- **Langues supportées**: `fr`, `en`, `ar` (via header `Accept-Language`)

### Principes Clés
- ✅ Support utilisateurs authentifiés + invités
- ✅ Modération automatique activée
- ✅ Système de votes/likes avec protection double vote
- ✅ Commentaires imbriqués (réponses)
- ✅ Pagination standard (15-50 items)

---

## Régions

### 📋 Concept
Les régions permettent de filtrer et d'explorer tout le contenu touristique (POIs, Events, Activities) par zone géographique de Djibouti. Le système supporte 6 régions officielles.

### 🔗 Endpoints API

#### 1. Liste des Régions avec Compteurs
```http
GET /api/regions
```

**Description:** Retourne la liste de toutes les régions avec le nombre de POIs, événements et activités par région.

**Headers:**
- `Accept-Language: fr` (optionnel, défaut: fr)

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/regions" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      "name": "Djibouti",
      "pois_count": 25,
      "events_count": 12,
      "activities_count": 8,
      "total_count": 45
    },
    {
      "name": "Ali Sabieh",
      "pois_count": 8,
      "events_count": 3,
      "activities_count": 2,
      "total_count": 13
    },
    {
      "name": "Dikhil",
      "pois_count": 10,
      "events_count": 5,
      "activities_count": 4,
      "total_count": 19
    },
    {
      "name": "Tadjourah",
      "pois_count": 15,
      "events_count": 7,
      "activities_count": 6,
      "total_count": 28
    },
    {
      "name": "Obock",
      "pois_count": 6,
      "events_count": 2,
      "activities_count": 3,
      "total_count": 11
    },
    {
      "name": "Arta",
      "pois_count": 4,
      "events_count": 1,
      "activities_count": 2,
      "total_count": 7
    }
  ]
}
```

**Cas d'usage:**
- Page de sélection de région
- Menu de filtrage par région
- Carte interactive avec compteurs

---

#### 2. Contenu d'une Région Spécifique
```http
GET /api/regions/{region}
```

**Description:** Retourne tous les POIs, événements et activités publiés pour une région donnée avec leurs traductions.

**Paramètres URL:**
| Paramètre | Type | Requis | Valeurs Possibles |
|-----------|------|--------|-------------------|
| `region` | string | ✅ | `Djibouti`, `Ali Sabieh`, `Dikhil`, `Tadjourah`, `Obock`, `Arta` |

**Headers:**
- `Accept-Language: fr` (optionnel, défaut: fr)

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/regions/Djibouti" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": {
    "region": "Djibouti",
    "summary": {
      "pois_count": 25,
      "events_count": 12,
      "activities_count": 8,
      "total_count": 45
    },
    "pois": [
      {
        "id": 1,
        "slug": "lac-assal",
        "name": "Lac Assal",
        "short_description": "Le point le plus bas d'Afrique...",
        "description": "Description complète...",
        "address": "Route de Tadjourah",
        "region": "Djibouti",
        "latitude": 11.6586,
        "longitude": 42.4086,
        "is_featured": true,
        "featured_image": {
          "id": 10,
          "url": "https://api.example.com/storage/media/images/lac-assal.jpg"
        },
        "categories": [
          {
            "id": 1,
            "name": "Nature"
          },
          {
            "id": 5,
            "name": "Sites Naturels"
          }
        ]
      }
      // ... autres POIs
    ],
    "events": [
      {
        "id": 5,
        "slug": "festival-des-nomades",
        "title": "Festival des Nomades",
        "short_description": "Célébration de la culture nomade...",
        "description": "Description complète...",
        "location": "Place Mahmoud Harbi",
        "region": "Djibouti",
        "latitude": 11.5889,
        "longitude": 43.1456,
        "start_date": "2025-03-15",
        "end_date": "2025-03-17",
        "start_time": "09:00",
        "end_time": "22:00",
        "price": 0,
        "is_featured": true,
        "featured_image": {
          "id": 25,
          "url": "https://api.example.com/storage/media/images/festival.jpg"
        },
        "categories": [
          {
            "id": 8,
            "name": "Culture"
          }
        ]
      }
      // ... autres Events
    ],
    "activities": [
      {
        "id": 3,
        "slug": "plongee-day-forest",
        "title": "Plongée à Day Forest",
        "short_description": "Découvrez les fonds marins exceptionnels...",
        "description": "Description complète...",
        "location_address": "Port de Djibouti",
        "region": "Djibouti",
        "latitude": 11.5889,
        "longitude": 43.1456,
        "price": 15000.00,
        "currency": "DJF",
        "difficulty_level": "moderate",
        "duration_hours": 3,
        "duration_minutes": 30,
        "is_featured": true,
        "featured_image": {
          "id": 42,
          "url": "https://api.example.com/storage/media/images/plongee.jpg"
        },
        "tour_operator": {
          "id": 1,
          "name": "Djibouti Adventures"
        }
      }
      // ... autres Activities
    ]
  }
}
```

**Erreur - Région Invalide (400):**
```json
{
  "success": false,
  "message": "Invalid region. Valid regions are: Djibouti, Ali Sabieh, Dikhil, Tadjourah, Obock, Arta"
}
```

**Cas d'usage:**
- Page de découverte par région
- Exploration géographique
- Planification d'itinéraire par zone

---

#### 3. Statistiques par Région
```http
GET /api/regions/statistics
```

**Description:** Retourne les statistiques de toutes les régions triées par contenu total décroissant. Utile pour dashboards et analytics.

**Headers:**
- `Accept-Language: fr` (optionnel)

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/regions/statistics" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      "region": "Djibouti",
      "pois_count": 25,
      "events_count": 12,
      "activities_count": 8,
      "total_count": 45
    },
    {
      "region": "Tadjourah",
      "pois_count": 15,
      "events_count": 7,
      "activities_count": 6,
      "total_count": 28
    },
    {
      "region": "Dikhil",
      "pois_count": 10,
      "events_count": 5,
      "activities_count": 4,
      "total_count": 19
    },
    {
      "region": "Ali Sabieh",
      "pois_count": 8,
      "events_count": 3,
      "activities_count": 2,
      "total_count": 13
    },
    {
      "region": "Obock",
      "pois_count": 6,
      "events_count": 2,
      "activities_count": 3,
      "total_count": 11
    },
    {
      "region": "Arta",
      "pois_count": 4,
      "events_count": 1,
      "activities_count": 2,
      "total_count": 7
    }
  ]
}
```

**Cas d'usage:**
- Écran d'accueil: "Top 3 régions à explorer"
- Dashboard analytics
- Graphiques de distribution du contenu
- Recommandations de régions populaires

---

## Activités

### 📋 Concept
Les activités sont des expériences ponctuelles proposées par les opérateurs touristiques (plongée, yoga, randonnée, etc.). Contrairement aux tours qui sont des circuits guidés, les activités se déroulent à un endroit fixe.

### 🔗 Endpoints API

#### 1. Liste des Activités
```http
GET /api/activities
```

**Query Parameters:**
| Paramètre | Type | Description | Exemple |
|-----------|------|-------------|---------|
| `search` | string | Recherche dans titre/description | `plongee` |
| `region` | string | Filtrer par région | `Djibouti`, `Tadjourah` |
| `difficulty` | string | Niveau de difficulté | `easy`, `moderate`, `difficult`, `expert` |
| `min_price` | number | Prix minimum (DJF) | `5000` |
| `max_price` | number | Prix maximum (DJF) | `50000` |
| `has_spots` | boolean | Seulement activités avec places | `1` |
| `sort_by` | string | Tri | `created_at`, `price`, `popularity` |
| `sort_order` | string | Ordre | `asc`, `desc` |
| `per_page` | number | Items par page (max 50) | `15` |

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/activities?region=Djibouti&difficulty=easy&per_page=10" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "slug": "plongee-day-forest",
      "title": "Plongée à Day Forest",
      "short_description": "Découvrez les fonds marins exceptionnels...",
      "price": 15000.00,
      "currency": "DJF",
      "difficulty_level": "moderate",
      "difficulty_label": "Modéré",
      "duration": {
        "hours": 3,
        "minutes": 30,
        "formatted": "3h30"
      },
      "region": "Djibouti",
      "location": {
        "address": "Port de Djibouti",
        "latitude": 11.5889,
        "longitude": 43.1456
      },
      "participants": {
        "min": 2,
        "max": 8,
        "current": 5,
        "available_spots": 3
      },
      "age_restrictions": {
        "has_restrictions": true,
        "min_age": 16,
        "max_age": null,
        "text": "16 ans minimum"
      },
      "featured_image": {
        "id": 42,
        "url": "https://api.example.com/storage/media/images/plongee.jpg",
        "thumbnail_url": "https://api.example.com/storage/media/images/thumbs/plongee.jpg"
      },
      "gallery": [
        {
          "id": 43,
          "url": "https://api.example.com/storage/media/images/gallery1.jpg",
          "thumbnail_url": "https://api.example.com/storage/media/images/thumbs/gallery1.jpg"
        }
      ],
      "tour_operator": {
        "id": 1,
        "name": "Djibouti Adventures",
        "email": "contact@djibouti-adventures.dj",
        "phone": "+253 21 35 00 00"
      },
      "is_featured": true,
      "weather_dependent": true,
      "views_count": 234,
      "registrations_count": 45
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 67
  }
}
```

#### 2. Détails d'une Activité
```http
GET /api/activities/{id_or_slug}
```

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/activities/plongee-day-forest" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "slug": "plongee-day-forest",
    "title": "Plongée à Day Forest",
    "short_description": "Découvrez les fonds marins...",
    "description": "Description complète et détaillée de l'activité...",
    "what_to_bring": "Maillot de bain, serviette, crème solaire...",
    "meeting_point_description": "Rendez-vous au port de Djibouti, quai n°3",
    "additional_info": "Petit déjeuner inclus avant la plongée",
    "price": 15000.00,
    "currency": "DJF",
    "difficulty_level": "moderate",
    "difficulty_label": "Modéré",
    "duration": {
      "hours": 3,
      "minutes": 30,
      "formatted": "3h30"
    },
    "region": "Djibouti",
    "location": {
      "address": "Port de Djibouti",
      "latitude": 11.5889,
      "longitude": 43.1456
    },
    "participants": {
      "min": 2,
      "max": 8,
      "current": 5,
      "available_spots": 3
    },
    "age_restrictions": {
      "has_restrictions": true,
      "min_age": 16,
      "max_age": null,
      "text": "16 ans minimum"
    },
    "physical_requirements": [
      "Savoir nager",
      "Bonne condition physique",
      "Pas de problèmes cardiaques"
    ],
    "certifications_required": [
      "Certificat médical de moins de 3 mois"
    ],
    "equipment_provided": [
      "Combinaison de plongée",
      "Bouteille d'oxygène",
      "Masque et tuba",
      "Palmes"
    ],
    "equipment_required": [
      "Maillot de bain",
      "Serviette",
      "Crème solaire"
    ],
    "includes": [
      "Équipement de plongée",
      "Guide professionnel certifié",
      "Assurance",
      "Petit déjeuner léger"
    ],
    "cancellation_policy": "Annulation gratuite jusqu'à 48h avant. Remboursement à 50% entre 48h et 24h. Pas de remboursement moins de 24h avant.",
    "featured_image": { /* ... */ },
    "gallery": [ /* ... */ ],
    "tour_operator": { /* ... */ },
    "is_featured": true,
    "weather_dependent": true,
    "views_count": 235,
    "registrations_count": 45
  }
}
```

#### 3. Activités à Proximité (GPS)
```http
GET /api/activities/nearby
```

**Query Parameters (Required):**
| Paramètre | Type | Description |
|-----------|------|-------------|
| `latitude` | number | Latitude GPS |
| `longitude` | number | Longitude GPS |
| `radius` | number | Rayon en km (défaut: 50, max: 100) |

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/activities/nearby?latitude=11.5889&longitude=43.1456&radius=30" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      /* Structure identique à /api/activities */
      "distance_km": 5.32  // Distance calculée en km
    }
  ]
}
```

#### 4. S'inscrire à une Activité
```http
POST /api/activities/{activity_id}/register
```

**Headers:**
- `Accept-Language: fr` (optionnel)
- `Authorization: Bearer {token}` (si utilisateur authentifié)

**Body Parameters:**
| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `number_of_people` | integer | ✅ | Nombre de participants (min: 1) |
| `preferred_date` | date | ❌ | Date préférée (format: Y-m-d, après aujourd'hui) |
| `special_requirements` | string | ❌ | Exigences spéciales (max: 500 chars) |
| `medical_conditions` | string | ❌ | Conditions médicales (max: 500 chars) |
| `guest_name` | string | 🟡 | Nom (requis si invité) |
| `guest_email` | email | 🟡 | Email (requis si invité) |
| `guest_phone` | string | ❌ | Téléphone invité |

**Exemple Requête (Utilisateur Authentifié):**
```bash
curl -X POST "https://api.example.com/api/activities/1/register" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: fr" \
  -d '{
    "number_of_people": 2,
    "preferred_date": "2025-02-15",
    "special_requirements": "Régime végétarien",
    "medical_conditions": null
  }'
```

**Exemple Requête (Invité):**
```bash
curl -X POST "https://api.example.com/api/activities/1/register" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: fr" \
  -d '{
    "number_of_people": 2,
    "preferred_date": "2025-02-15",
    "guest_name": "Jean Dupont",
    "guest_email": "jean.dupont@example.com",
    "guest_phone": "+253 77 12 34 56"
  }'
```

**Réponse Succès (201):**
```json
{
  "success": true,
  "message": "Inscription enregistrée avec succès. En attente de confirmation.",
  "data": {
    "id": 42,
    "activity": {
      "id": 1,
      "slug": "plongee-day-forest",
      "title": "Plongée à Day Forest",
      "price": 15000.00,
      "currency": "DJF",
      "featured_image": {
        "url": "https://...",
        "thumbnail_url": "https://..."
      },
      "tour_operator": {
        "name": "Djibouti Adventures",
        "phone": "+253 21 35 00 00"
      }
    },
    "number_of_people": 2,
    "preferred_date": "2025-02-15",
    "special_requirements": "Régime végétarien",
    "medical_conditions": null,
    "status": "pending",
    "status_label": "En attente",
    "payment_status": "pending",
    "payment_status_label": "En attente",
    "total_price": 30000.00,
    "created_at": "2025-01-30T14:23:45+00:00",
    "confirmed_at": null,
    "completed_at": null,
    "cancelled_at": null,
    "cancellation_reason": null
  }
}
```

**Erreurs Possibles:**
- `400` - Activité inactive
- `400` - Inscription déjà existante (utilisateur authentifié)
- `400` - Pas assez de places disponibles
- `422` - Données invalides

#### 5. Mes Inscriptions (Authentifié)
```http
GET /api/activity-registrations
Authorization: Bearer {token}
```

**Query Parameters:**
| Paramètre | Type | Description |
|-----------|------|-------------|
| `status` | string | `pending`, `confirmed`, `completed`, `cancelled_by_user`, `cancelled_by_operator` |

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/activity-registrations?status=confirmed" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 42,
      "activity": {
        "id": 1,
        "slug": "plongee-day-forest",
        "title": "Plongée à Day Forest",
        "price": 15000.00,
        "currency": "DJF",
        "featured_image": { /* ... */ },
        "tour_operator": { /* ... */ }
      },
      "number_of_people": 2,
      "preferred_date": "2025-02-15",
      "special_requirements": "Régime végétarien",
      "medical_conditions": null,
      "status": "confirmed",
      "status_label": "Confirmé",
      "payment_status": "pending",
      "payment_status_label": "En attente",
      "total_price": 30000.00,
      "created_at": "2025-01-30T14:23:45+00:00",
      "confirmed_at": "2025-01-30T16:45:12+00:00",
      "completed_at": null,
      "cancelled_at": null,
      "cancellation_reason": null
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 2,
    "per_page": 15,
    "total": 23
  }
}
```

#### 6. Annuler une Inscription (Authentifié)
```http
DELETE /api/activity-registrations/{registration_id}
Authorization: Bearer {token}
```

**Body Parameters:**
| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `reason` | string | ❌ | Raison de l'annulation (max: 500 chars) |

**Exemple Requête:**
```bash
curl -X DELETE "https://api.example.com/api/activity-registrations/42" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Changement de programme"
  }'
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "message": "Inscription annulée avec succès"
}
```

**Erreurs Possibles:**
- `403` - Inscription appartient à un autre utilisateur
- `400` - Inscription ne peut pas être annulée (déjà terminée ou annulée)

---

## Avis (Reviews)

### 📋 Concept
Les avis sont des évaluations **avec notation étoilée (1-5)** exclusivement pour les **POIs (Points d'Intérêt)**. Un utilisateur ne peut laisser qu'un seul avis par POI.

### 🔗 Endpoints API

#### 1. Liste des Avis d'un POI
```http
GET /api/pois/{poi_id}/reviews
```

**Query Parameters:**
| Paramètre | Type | Description |
|-----------|------|-------------|
| `rating` | integer | Filtrer par note (1-5) |
| `verified_only` | boolean | Seulement avis vérifiés |
| `sort_by` | string | `recent`, `helpful`, `rating_high`, `rating_low` |
| `per_page` | number | Items par page (max 50) |

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/pois/5/reviews?sort_by=helpful&per_page=10" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "author": {
        "name": "Marie Laurent",
        "is_verified": true,
        "is_me": false
      },
      "rating": 5,
      "title": "Lieu exceptionnel !",
      "comment": "J'ai adoré visiter ce site. Le personnel était très accueillant et les paysages magnifiques. Je recommande vivement !",
      "helpful_count": 42,
      "is_helpful": false,
      "created_at": "2025-01-15T10:30:00+00:00",
      "updated_at": "2025-01-15T10:30:00+00:00",
      "operator_response": {
        "text": "Merci beaucoup pour votre retour ! Nous sommes ravis que vous ayez apprécié votre visite.",
        "date": "2025-01-16T09:15:00+00:00"
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 10,
    "total": 28
  },
  "statistics": {
    "average_rating": 4.3,
    "total_reviews": 28,
    "rating_distribution": {
      "1": 1,
      "2": 2,
      "3": 5,
      "4": 8,
      "5": 12
    }
  }
}
```

#### 2. Créer un Avis
```http
POST /api/pois/{poi_id}/reviews
```

**Headers:**
- `Authorization: Bearer {token}` (si authentifié)
- `X-Guest-ID: {unique_device_id}` (si invité)

**Body Parameters:**
| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `rating` | integer | ✅ | Note de 1 à 5 étoiles |
| `title` | string | ❌ | Titre de l'avis (max: 255 chars) |
| `comment` | string | ❌ | Commentaire détaillé (max: 2000 chars) |
| `guest_name` | string | 🟡 | Nom (requis si invité) |
| `guest_email` | email | 🟡 | Email (requis si invité) |

**Exemple Requête (Authentifié):**
```bash
curl -X POST "https://api.example.com/api/pois/5/reviews" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: fr" \
  -d '{
    "rating": 5,
    "title": "Absolument magnifique",
    "comment": "Un des plus beaux endroits que j'ai visités à Djibouti. Les paysages sont à couper le souffle."
  }'
```

**Exemple Requête (Invité):**
```bash
curl -X POST "https://api.example.com/api/pois/5/reviews" \
  -H "Content-Type: application/json" \
  -H "X-Guest-ID: device-uuid-12345" \
  -H "Accept-Language: fr" \
  -d '{
    "rating": 4,
    "title": "Très bien",
    "comment": "Belle expérience, je recommande",
    "guest_name": "Ahmed Hassan",
    "guest_email": "ahmed@example.com"
  }'
```

**Réponse Succès (201):**
```json
{
  "success": true,
  "message": "Votre avis a été ajouté avec succès",
  "data": {
    "id": 124,
    "author": {
      "name": "Ahmed Hassan",
      "is_verified": false,
      "is_me": true
    },
    "rating": 4,
    "title": "Très bien",
    "comment": "Belle expérience, je recommande",
    "helpful_count": 0,
    "is_helpful": false,
    "created_at": "2025-01-30T15:20:00+00:00",
    "updated_at": "2025-01-30T15:20:00+00:00",
    "operator_response": null
  }
}
```

**Erreurs Possibles:**
- `400` - Utilisateur a déjà laissé un avis pour ce POI
- `422` - Données invalides

#### 3. Modifier son Avis (Authentifié)
```http
PUT /api/reviews/{review_id}
Authorization: Bearer {token}
```

**Body Parameters:**
```json
{
  "rating": 5,
  "title": "Titre modifié",
  "comment": "Commentaire modifié"
}
```

**Réponse:** Même structure que création

#### 4. Supprimer son Avis (Authentifié)
```http
DELETE /api/reviews/{review_id}
Authorization: Bearer {token}
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "message": "Votre avis a été supprimé"
}
```

#### 5. Marquer un Avis comme Utile (Authentifié)
```http
POST /api/reviews/{review_id}/helpful
Authorization: Bearer {token}
```

**Note:** C'est un toggle - appeler une 2ème fois retire le vote

**Réponse Succès (200):**
```json
{
  "success": true,
  "message": "Merci pour votre vote",
  "helpful_count": 43,
  "is_helpful": true
}
```

Ou si vote retiré:
```json
{
  "success": true,
  "message": "Vote retiré",
  "helpful_count": 42,
  "is_helpful": false
}
```

#### 6. Mes Avis (Authentifié)
```http
GET /api/reviews/my-reviews
Authorization: Bearer {token}
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      /* Structure d'avis classique */
      "poi": {
        "id": 5,
        "name": "Lac Assal",
        "slug": "lac-assal",
        "featured_image": "https://..."
      }
    }
  ],
  "meta": { /* pagination */ }
}
```

---

## Commentaires

### 📋 Concept
Les commentaires sont **polymorphiques** - ils peuvent être ajoutés sur **n'importe quelle ressource** (POI, Event, Tour, TourOperator, Activity). Ils supportent les **réponses imbriquées** (threads de discussion).

### 🔗 Endpoints API

#### 1. Liste des Commentaires d'une Ressource
```http
GET /api/comments
```

**Query Parameters (Required):**
| Paramètre | Type | Requis | Valeurs Possibles |
|-----------|------|--------|-------------------|
| `commentable_type` | string | ✅ | `poi`, `event`, `tour`, `tour_operator`, `activity` |
| `commentable_id` | integer | ✅ | ID de la ressource |

**Exemple Requête:**
```bash
curl -X GET "https://api.example.com/api/comments?commentable_type=activity&commentable_id=5" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept-Language: fr"
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 456,
      "author": {
        "name": "Sophie Martin",
        "is_me": false
      },
      "comment": "Super activité ! Le guide était très professionnel.",
      "likes_count": 12,
      "is_liked": false,
      "created_at": "2025-01-28T14:30:00+00:00",
      "updated_at": "2025-01-28T14:30:00+00:00",
      "replies": [
        {
          "id": 457,
          "author": {
            "name": "Jean Dupont",
            "is_me": false
          },
          "comment": "Je confirme, j'y étais aussi et c'était génial !",
          "likes_count": 3,
          "is_liked": false,
          "created_at": "2025-01-28T16:15:00+00:00",
          "updated_at": "2025-01-28T16:15:00+00:00"
        }
      ]
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 2,
    "per_page": 20,
    "total": 35
  }
}
```

#### 2. Créer un Commentaire
```http
POST /api/comments
```

**Headers:**
- `Authorization: Bearer {token}` (si authentifié)
- `X-Guest-ID: {unique_device_id}` (si invité)

**Body Parameters:**
| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| `commentable_type` | string | ✅ | `poi`, `event`, `tour`, `tour_operator`, `activity` |
| `commentable_id` | integer | ✅ | ID de la ressource |
| `comment` | string | ✅ | Texte du commentaire (3-1000 chars) |
| `parent_id` | integer | ❌ | ID du commentaire parent (pour répondre) |
| `guest_name` | string | 🟡 | Nom (requis si invité) |
| `guest_email` | email | 🟡 | Email (requis si invité) |

**Exemple Requête (Commentaire Racine):**
```bash
curl -X POST "https://api.example.com/api/comments" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: fr" \
  -d '{
    "commentable_type": "activity",
    "commentable_id": 5,
    "comment": "Activité incroyable ! Merci au guide pour sa patience."
  }'
```

**Exemple Requête (Réponse à un Commentaire):**
```bash
curl -X POST "https://api.example.com/api/comments" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "commentable_type": "activity",
    "commentable_id": 5,
    "comment": "Tout à fait d'accord, c'était formidable !",
    "parent_id": 456
  }'
```

**Réponse Succès (201):**
```json
{
  "success": true,
  "message": "Commentaire ajouté avec succès",
  "data": {
    "id": 458,
    "author": {
      "name": "Votre Nom",
      "is_me": true
    },
    "comment": "Activité incroyable ! Merci au guide pour sa patience.",
    "likes_count": 0,
    "is_liked": false,
    "created_at": "2025-01-30T16:00:00+00:00",
    "updated_at": "2025-01-30T16:00:00+00:00"
  }
}
```

#### 3. Modifier son Commentaire (Authentifié)
```http
PUT /api/comments/{comment_id}
Authorization: Bearer {token}
```

**Body Parameters:**
```json
{
  "comment": "Commentaire modifié avec plus de détails"
}
```

#### 4. Supprimer son Commentaire (Authentifié)
```http
DELETE /api/comments/{comment_id}
Authorization: Bearer {token}
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "message": "Commentaire supprimé"
}
```

#### 5. Liker/Unliker un Commentaire (Authentifié)
```http
POST /api/comments/{comment_id}/like
Authorization: Bearer {token}
```

**Note:** Toggle - appeler 2 fois retire le like

**Réponse Succès (200):**
```json
{
  "success": true,
  "message": "Commentaire liké",
  "likes_count": 13,
  "is_liked": true
}
```

#### 6. Mes Commentaires (Authentifié)
```http
GET /api/comments/my-comments
Authorization: Bearer {token}
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": [
    {
      /* Structure commentaire classique */
      "resource": {
        "type": "activity",
        "id": 5,
        "name": "Plongée à Day Forest"
      }
    }
  ],
  "meta": { /* pagination */ }
}
```

---

## Modèles de Données

### Status des Inscriptions Activités
```javascript
const ActivityRegistrationStatus = {
  PENDING: 'pending',              // En attente de confirmation
  CONFIRMED: 'confirmed',          // Confirmé par l'opérateur
  COMPLETED: 'completed',          // Activité terminée
  CANCELLED_BY_USER: 'cancelled_by_user',        // Annulé par l'utilisateur
  CANCELLED_BY_OPERATOR: 'cancelled_by_operator' // Annulé par l'opérateur
};
```

### Status des Paiements
```javascript
const PaymentStatus = {
  PENDING: 'pending',    // En attente
  PAID: 'paid',         // Payé
  REFUNDED: 'refunded'  // Remboursé
};
```

### Niveaux de Difficulté
```javascript
const DifficultyLevel = {
  EASY: 'easy',           // Facile
  MODERATE: 'moderate',   // Modéré
  DIFFICULT: 'difficult', // Difficile
  EXPERT: 'expert'       // Expert
};
```

### Régions de Djibouti
```javascript
const Regions = [
  'Djibouti',
  'Ali Sabieh',
  'Dikhil',
  'Tadjourah',
  'Obock',
  'Arta'
];
```

### Types de Ressources Commentables
```javascript
const CommentableTypes = {
  POI: 'poi',
  EVENT: 'event',
  TOUR: 'tour',
  TOUR_OPERATOR: 'tour_operator',
  ACTIVITY: 'activity'
};
```

---

## Cas d'Usage UI/UX

### 1. Exploration par Région

**Page Sélection de Région:**

Écran permettant de choisir une région pour explorer son contenu touristique.

```
┌─────────────────────────────────────┐
│  Explorez Djibouti par région       │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🗺️ Djibouti                   │ │
│  │ 25 POIs • 12 événements       │ │
│  │ 8 activités                   │ │
│  │                            👉 │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🗺️ Tadjourah                  │ │
│  │ 15 POIs • 7 événements        │ │
│  │ 6 activités                   │ │
│  │                            👉 │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🗺️ Dikhil                     │ │
│  │ 10 POIs • 5 événements        │ │
│  │ 4 activités                   │ │
│  │                            👉 │ │
│  └───────────────────────────────┘ │
│                                     │
│  [Voir toutes les régions...]     │
└─────────────────────────────────────┘
```

**Page Contenu d'une Région:**

Affichage de tout le contenu touristique pour la région sélectionnée.

```
┌─────────────────────────────────────┐
│ ← Djibouti                          │
│                                     │
│ 📊 45 sites et activités            │
│ 25 POIs • 12 événements • 8 activités│
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📌 Points d'Intérêt (25)        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌──────────────────┐                │
│ │ [Image]          │ Lac Assal      │
│ │                  │ Le point le... │
│ └──────────────────┘ ⭐ 4.8 (156)   │
│                                     │
│ ┌──────────────────┐                │
│ │ [Image]          │ Forêt du Day   │
│ │                  │ Oasis de...    │
│ └──────────────────┘ ⭐ 4.5 (89)    │
│                                     │
│ [Voir tous les POIs...]             │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🎉 Événements (12)              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌──────────────────┐                │
│ │ [Image]          │ Festival       │
│ │                  │ 15-17 mars     │
│ └──────────────────┘ Gratuit        │
│                                     │
│ [Voir tous les événements...]       │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏃 Activités (8)                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌──────────────────┐                │
│ │ [Image]          │ Plongée        │
│ │                  │ 15,000 DJF     │
│ └──────────────────┘ 3 places       │
│                                     │
│ [Voir toutes les activités...]      │
└─────────────────────────────────────┘
```

**Carte Interactive avec Régions:**

Carte de Djibouti avec zones cliquables et indicateurs.

```
┌─────────────────────────────────────┐
│  🗺️ Carte des Régions               │
│                                     │
│     ┌──────────────────────┐        │
│     │   Obock (11)         │        │
│     └──────────────────────┘        │
│                                     │
│  ┌──────────┐  ┌──────────────┐    │
│  │Tadjourah │  │  Djibouti    │    │
│  │  (28)    │  │    (45) ★    │    │
│  └──────────┘  └──────────────┘    │
│                                     │
│     ┌──────────┐  ┌──────────┐     │
│     │ Dikhil   │  │Ali Sabieh│     │
│     │  (19)    │  │   (13)   │     │
│     └──────────┘  └──────────┘     │
│          ┌──────┐                   │
│          │ Arta │                   │
│          │  (7) │                   │
│          └──────┘                   │
│                                     │
│ Légende: (nombre total de contenus)│
│ ★ Région la plus populaire          │
└─────────────────────────────────────┘
```

**Dashboard Analytics (Statistiques):**

Écran d'accueil avec recommandations basées sur les statistiques.

```
┌─────────────────────────────────────┐
│  Top Régions à Explorer 🌟          │
│                                     │
│  1️⃣ Djibouti                        │
│  ████████████████████ 45 sites     │
│  La capitale et ses environs        │
│  [Explorer →]                       │
│                                     │
│  2️⃣ Tadjourah                       │
│  ████████████ 28 sites             │
│  Plages et sites historiques        │
│  [Explorer →]                       │
│                                     │
│  3️⃣ Dikhil                          │
│  ████████ 19 sites                 │
│  Lac Assal et déserts               │
│  [Explorer →]                       │
│                                     │
│  [Voir toutes les régions]          │
│                                     │
│  📊 Distribution du Contenu         │
│  ┌─────────────────────────────┐   │
│  │ Djibouti  ████████████ 37%  │   │
│  │ Tadjourah ████████ 23%      │   │
│  │ Dikhil    █████ 16%         │   │
│  │ Ali Sabieh ███ 11%          │   │
│  │ Obock     ██ 9%             │   │
│  │ Arta      █ 4%              │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Filtre par Région (dans listes POIs/Events/Activities):**

Menu déroulant ou chips de filtrage.

```
┌─────────────────────────────────────┐
│  Filtrer par région                 │
│                                     │
│  [Toutes les régions ▼]             │
│  ┌─────────────────────────────┐   │
│  │ ✓ Toutes (123)              │   │
│  │   Djibouti (45)             │   │
│  │   Tadjourah (28)            │   │
│  │   Dikhil (19)               │   │
│  │   Ali Sabieh (13)           │   │
│  │   Obock (11)                │   │
│  │   Arta (7)                  │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Ou en format Chips:**

```
┌─────────────────────────────────────┐
│  Régions:                           │
│  [Toutes] [Djibouti] [Tadjourah]    │
│  [Dikhil] [Ali Sabieh] [Obock]      │
│  [Arta]                             │
└─────────────────────────────────────┘
```

---

### 2. Page Liste des Activités

**Éléments UI:**
- 🔍 Barre de recherche
- 🎛️ Filtres (région, difficulté, prix)
- 📋 Liste scrollable avec cards
- ⭐ Badge "Mise en avant" pour activités featured
- 📍 Distance (si géolocalisation activée)
- 💰 Prix affiché
- 👥 Places disponibles
- 🌤️ Icône météo si `weather_dependent: true`

**Card Activité:**
```
┌─────────────────────────────────────┐
│ [Image Featured]          [❤️ Fav]  │
│                                     │
│ Plongée à Day Forest          ⭐    │
│ Modéré • 3h30 • 15,000 DJF          │
│ 📍 Djibouti • 3 places disponibles  │
│ ⭐⭐⭐⭐⭐ 4.5 (42 avis)              │
└─────────────────────────────────────┘
```

### 2. Page Détails d'une Activité

**Sections (ordre recommandé):**
1. **Hero** - Image principale + galerie
2. **En-tête** - Titre, difficulté, durée, prix
3. **Quick Info** - Opérateur, participants, météo
4. **Description** - Texte complet
5. **Ce qui est inclus** - Liste à puces
6. **Équipement** - Fourni vs À apporter (2 colonnes)
7. **Prérequis** - Physique + Certifications
8. **Point de rendez-vous** - Adresse + carte
9. **Politique d'annulation** - Texte explicatif
10. **Avis** - Section reviews (voir ci-dessous)
11. **Commentaires** - Section comments (voir ci-dessous)
12. **CTA Fixe** - Bouton "S'inscrire" sticky en bas

**Bouton S'inscrire:**
```
┌─────────────────────────────────────┐
│  S'inscrire - 15,000 DJF / personne │
│        3 places disponibles          │
└─────────────────────────────────────┘
```

### 3. Formulaire d'Inscription

**Champs:**
```
Nombre de participants: [2] [- +]
Date préférée: [📅 15/02/2025]

Exigences spéciales (optionnel):
[Textarea]

Conditions médicales (optionnel):
[Textarea - avec icône ⚠️]

[Si invité]
Nom: [________]
Email: [________]
Téléphone (optionnel): [________]

Total: 30,000 DJF

[Annuler] [Confirmer l'inscription]
```

**Confirmation:**
```
┌─────────────────────────────────────┐
│       ✅ Inscription Enregistrée     │
│                                     │
│  Votre inscription a été envoyée    │
│  à l'opérateur pour confirmation.   │
│                                     │
│  N° réservation: #42                │
│  Status: En attente                 │
│                                     │
│  [Voir mes inscriptions]            │
└─────────────────────────────────────┘
```

### 4. Page Mes Inscriptions

**Filtres:**
- Tous
- En attente
- Confirmés
- Terminés
- Annulés

**Card Inscription:**
```
┌─────────────────────────────────────┐
│ Plongée à Day Forest                │
│ #42 • En attente                    │
│ 2 participants • 30,000 DJF         │
│ Date préférée: 15/02/2025           │
│                                     │
│ [Voir détails] [Annuler]            │
└─────────────────────────────────────┘
```

### 5. Section Avis (POI uniquement)

**En-tête:**
```
┌─────────────────────────────────────┐
│ Avis des visiteurs                  │
│                                     │
│ ⭐ 4.3/5  (42 avis)                 │
│                                     │
│ ★★★★★ ████████████ 12              │
│ ★★★★☆ ████████ 8                   │
│ ★★★☆☆ █████ 5                      │
│ ★★☆☆☆ ██ 2                         │
│ ★☆☆☆☆ █ 1                          │
│                                     │
│ Filtrer: [Tous ▼] Trier: [Utiles ▼]│
└─────────────────────────────────────┘
```

**Card Avis:**
```
┌─────────────────────────────────────┐
│ Marie Laurent ✓ • 15 jan 2025      │
│ ⭐⭐⭐⭐⭐                            │
│                                     │
│ Lieu exceptionnel !                 │
│                                     │
│ J'ai adoré visiter ce site. Le      │
│ personnel était très accueillant... │
│                                     │
│ [👍 Utile (42)] [Modifier] [Supp.] │
│                                     │
│ 📝 Réponse de l'opérateur:          │
│ Merci beaucoup pour votre retour... │
└─────────────────────────────────────┘
```

**Formulaire Nouvel Avis:**
```
┌─────────────────────────────────────┐
│ Laisser un avis                     │
│                                     │
│ Votre note: ⭐⭐⭐⭐⭐               │
│                                     │
│ Titre (optionnel):                  │
│ [________________________]          │
│                                     │
│ Votre avis:                         │
│ [Textarea]                          │
│                                     │
│ [Annuler] [Publier l'avis]          │
└─────────────────────────────────────┘
```

### 6. Section Commentaires (Toutes ressources)

**En-tête:**
```
┌─────────────────────────────────────┐
│ Commentaires (23)                   │
│                                     │
│ [Ajouter un commentaire...]         │
└─────────────────────────────────────┘
```

**Card Commentaire avec Réponses:**
```
┌─────────────────────────────────────┐
│ Sophie Martin • Il y a 2 jours      │
│                                     │
│ Super activité ! Le guide était très│
│ professionnel.                      │
│                                     │
│ [❤️ 12] [💬 Répondre] [⋮]           │
│                                     │
│   ┌─────────────────────────────┐   │
│   │ Jean Dupont • Il y a 1 jour │   │
│   │ Je confirme, j'y étais...   │   │
│   │ [❤️ 3] [💬 Répondre]         │   │
│   └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Formulaire Commentaire:**
```
┌─────────────────────────────────────┐
│ [Avatar] Votre commentaire...       │
│                                     │
│ [Textarea - auto-expand]            │
│                                     │
│       [Annuler] [Commenter]         │
└─────────────────────────────────────┘
```

### 7. Flow Utilisateur Invité vs Authentifié

**Invité:**
1. Parcourt activités ✅
2. Clique "S'inscrire" ➜ **Modal login/register**
3. Option: "Continuer en tant qu'invité"
4. Remplit nom/email dans formulaire
5. Reçoit email de confirmation

**Authentifié:**
1. Parcourt activités ✅
2. Clique "S'inscrire" ➜ **Direct au formulaire**
3. Champs pré-remplis
4. Notification push + email

### 8. Gestion Hors-Ligne

**Stratégie Recommandée:**

**Cache des Listes:**
```javascript
// Stocker en cache avec TTL
localStorage.setItem('activities_cache', JSON.stringify({
  data: activities,
  timestamp: Date.now(),
  ttl: 3600000 // 1 heure
}));
```

**Actions Hors-Ligne:**
- ✅ Voir les activités en cache
- ✅ Voir détails d'activité en cache
- ❌ S'inscrire (nécessite connexion)
- ❌ Créer avis/commentaire (nécessite connexion)
- ✅ Voir avis/commentaires en cache

**Indicateur UI:**
```
┌─────────────────────────────────────┐
│ 📡 Mode hors ligne                  │
│ Les données peuvent être obsolètes  │
└─────────────────────────────────────┘
```

---

## Gestion des Erreurs

### Codes d'Erreur HTTP

| Code | Signification | Action UI |
|------|---------------|-----------|
| `400` | Requête invalide | Afficher message d'erreur |
| `401` | Non authentifié | Rediriger vers login |
| `403` | Non autorisé | Afficher "Accès refusé" |
| `404` | Ressource non trouvée | Afficher "Non trouvé" |
| `422` | Validation échouée | Afficher erreurs de champs |
| `500` | Erreur serveur | "Erreur serveur, réessayez" |

### Format des Erreurs

**Erreur Simple:**
```json
{
  "success": false,
  "message": "Vous avez déjà laissé un avis pour ce lieu"
}
```

**Erreur de Validation:**
```json
{
  "success": false,
  "message": "Données invalides",
  "errors": {
    "rating": ["Le champ rating est requis."],
    "guest_email": ["Le champ guest email doit être une adresse email valide."]
  }
}
```

### Messages d'Erreur Utilisateur

**Activités:**
- Inscription déjà existante: "Vous êtes déjà inscrit à cette activité"
- Plus de places: "Désolé, il n'y a plus de places disponibles"
- Activité inactive: "Cette activité n'est plus disponible"
- Date invalide: "La date doit être dans le futur"

**Avis:**
- Avis déjà existant: "Vous avez déjà laissé un avis pour ce lieu"
- Note invalide: "Veuillez choisir une note entre 1 et 5 étoiles"
- Champs manquants (invité): "Veuillez renseigner votre nom et email"

**Commentaires:**
- Texte trop court: "Votre commentaire doit contenir au moins 3 caractères"
- Parent invalide: "Le commentaire auquel vous répondez n'existe pas"
- Type invalide: "Type de ressource non supporté"

### Retry Logic

**Recommandations:**
```javascript
// Retry automatique pour erreurs réseau
const retryRequest = async (requestFn, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await requestFn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      if (error.response?.status >= 500) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
      } else {
        throw error;
      }
    }
  }
};
```

---

## Checklist Implémentation

### Phase 0: Régions 🗺️
- [ ] Page de sélection de région
- [ ] Page contenu par région
- [ ] Carte interactive des régions
- [ ] Dashboard statistiques
- [ ] Filtres par région dans POIs/Events/Activities
- [ ] Cache des données régionales
- [ ] Tests unitaires

### Phase 1: Activités ✅
- [ ] Liste des activités avec filtres
- [ ] Détails d'une activité
- [ ] Activités à proximité (GPS)
- [ ] Formulaire d'inscription
- [ ] Mes inscriptions
- [ ] Annulation d'inscription
- [ ] Gestion cache local
- [ ] Tests unitaires

### Phase 2: Avis ⭐
- [ ] Affichage des avis sur POI
- [ ] Statistiques de notation
- [ ] Formulaire création d'avis
- [ ] Modification/Suppression avis
- [ ] Vote "utile"
- [ ] Mes avis
- [ ] Tests unitaires

### Phase 3: Commentaires 💬
- [ ] Affichage des commentaires (toutes ressources)
- [ ] Création de commentaire
- [ ] Réponses imbriquées
- [ ] Like/Unlike commentaires
- [ ] Modification/Suppression
- [ ] Mes commentaires
- [ ] Tests unitaires

### Phase 4: Intégration UI/UX 🎨
- [ ] Design cards activités
- [ ] Design formulaire inscription
- [ ] Design section avis avec notation
- [ ] Design threads de commentaires
- [ ] Animations et transitions
- [ ] Mode hors-ligne
- [ ] Tests E2E

### Phase 5: Tests & Optimisations 🚀
- [ ] Tests de charge
- [ ] Optimisation images
- [ ] Lazy loading
- [ ] Analytics tracking
- [ ] Error monitoring
- [ ] Beta testing

---

## Ressources Supplémentaires

### Documentation Backend
- API Postman Collection: À créer
- Swagger/OpenAPI: À générer
- Database Schema: Voir migrations

### Assets Design
- Icônes difficulté: À fournir
- Icônes météo: À fournir
- Placeholder images: À fournir
- Avatar par défaut: À fournir

### Configuration
```javascript
// config.js
export const API_CONFIG = {
  BASE_URL: 'https://api.visitdjibouti.dj',
  TIMEOUT: 30000,
  HEADERS: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': 'fr' // ou récupérer depuis settings app
  }
};

export const PAGINATION = {
  DEFAULT_PER_PAGE: 15,
  MAX_PER_PAGE: 50
};

export const CACHE_TTL = {
  REGIONS: 86400000,        // 24 heures (données statiques)
  REGION_CONTENT: 3600000,  // 1 heure
  ACTIVITIES: 3600000,      // 1 heure
  ACTIVITY_DETAIL: 1800000, // 30 minutes
  REVIEWS: 1800000,         // 30 minutes
  COMMENTS: 600000          // 10 minutes
};
```

### Contact Support
Pour toute question technique:
- 📧 Email: dev@visitdjibouti.dj
- 💬 Slack: #mobile-dev
- 📝 Issues: GitHub Repository

---

**Document Version**: 1.1
**Date**: 4 Novembre 2025
**Dernière Mise à Jour**: Ajout de la section Régions (3 endpoints + UI/UX)
**Auteur**: Système Backend Visit Djibouti
**Status**: ✅ Prêt pour implémentation
