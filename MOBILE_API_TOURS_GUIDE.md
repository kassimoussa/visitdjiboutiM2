# Guide d'intégration API Mobile - Tours Guidés

> Documentation technique basée sur le code source réel pour l'intégration des tours guidés dans l'application mobile Visit Djibouti

**Version :** 1.0
**Date :** 17 Octobre 2025
**Base URL :** `http://91.134.241.240/api`

---

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Authentification](#authentification)
4. [Endpoints API Tours](#endpoints-api-tours)
5. [Endpoints API Réservations](#endpoints-api-réservations)
6. [Modèles de données](#modèles-de-données)
7. [Flux de réservation](#flux-de-réservation)
8. [Exemples d'intégration](#exemples-dintégration)
9. [Gestion des erreurs](#gestion-des-erreurs)

---

## Vue d'ensemble

### Qu'est-ce qu'un Tour ?

Un **Tour** est un circuit guidé proposé par un opérateur touristique. Caractéristiques principales :

- **Réservation directe** : Pas de créneaux horaires, réservation directe sur le tour
- **Gestion de capacité** : `current_participants` / `max_participants`
- **Multilingue** : Contenu traduit (FR, EN, AR)
- **Géolocalisation** : Point de rencontre avec GPS
- **Support invités** : Réservation avec ou sans compte utilisateur

---

## Architecture

### Modèle simplifié

```
Tour
├─ id
├─ slug
├─ tour_operator_id
├─ price
├─ max_participants
├─ current_participants
└─ available_spots (calculé)

TourReservation
├─ id
├─ tour_id
├─ app_user_id (nullable)
├─ guest_name (si invité)
├─ guest_email (si invité)
├─ number_of_people
└─ status
```

### Statuts

#### Statuts des Tours
- `active` : Tour actif et visible
- `inactive` : Tour inactif
- `draft` : Brouillon

#### Statuts des Réservations
- `pending` : En attente de confirmation opérateur
- `confirmed` : Confirmée
- `cancelled_by_user` : Annulée par l'utilisateur

### Types de Tours
- `poi` : Visite de site
- `event` : Accompagnement événement
- `mixed` : Circuit mixte
- `cultural` : Culturel
- `adventure` : Aventure
- `nature` : Nature
- `gastronomic` : Gastronomique

### Niveaux de difficulté
- `easy` : Facile
- `moderate` : Modéré
- `difficult` : Difficile
- `expert` : Expert

---

## Authentification

### Headers requis

```http
Accept: application/json
Content-Type: application/json
Accept-Language: fr|en|ar
```

### Pour utilisateur authentifié

```http
Authorization: Bearer {token}
```

### Pour utilisateur anonyme (optionnel)

```http
X-Anonymous-ID: {anonymous_id}
```

### Pour invités
Aucun header d'authentification nécessaire pour consulter les tours. Pour réserver, fournir `guest_name` et `guest_email` dans le corps de la requête.

---

## Endpoints API Tours

### 1. Lister les tours

**GET** `/tours`

Liste tous les tours actifs avec filtrage et pagination.

#### Paramètres de requête (tous optionnels)

| Paramètre | Type | Description |
|-----------|------|-------------|
| `search` | string | Recherche dans titre et description |
| `operator_id` | integer | Filtrer par ID d'opérateur |
| `type` | string | Type de tour (voir types ci-dessus) |
| `difficulty` | string | Niveau de difficulté |
| `min_price` | number | Prix minimum |
| `max_price` | number | Prix maximum |
| `max_duration_hours` | integer | Durée max en heures |
| `max_duration_days` | integer | Durée max en jours |
| `date_from` | date | Date de début (YYYY-MM-DD) |
| `date_to` | date | Date de fin (YYYY-MM-DD) |
| `featured` | boolean | Seulement les tours en vedette |
| `latitude` | number | Latitude pour recherche à proximité |
| `longitude` | number | Longitude pour recherche à proximité |
| `radius` | number | Rayon en km (défaut: 50) |
| `sort_by` | string | Tri : `created_at`, `price`, `title` |
| `sort_order` | string | Ordre : `asc`, `desc` (défaut: desc) |
| `per_page` | integer | Résultats par page (max: 50, défaut: 15) |

#### Exemple de requête

```bash
curl -X GET "http://91.134.241.240/api/tours?type=nature&difficulty=easy&max_price=10000&per_page=10" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

#### Exemple de réponse

```json
{
  "success": true,
  "data": {
    "tours": [
      {
        "id": 1,
        "slug": "visite-lac-assal",
        "title": "Visite du Lac Assal",
        "type": "nature",
        "type_label": "Nature",
        "difficulty_level": "moderate",
        "difficulty_label": "Modéré",
        "start_date": "2025-02-01",
        "end_date": "2025-02-01",
        "formatted_date_range": "01/02/2025",
        "duration": {
          "hours": 6,
          "days": 1,
          "formatted": "1 jour 6 heures"
        },
        "price": 8000,
        "formatted_price": "8 000 DJF",
        "is_free": false,
        "is_featured": true,
        "max_participants": 15,
        "min_participants": 4,
        "available_spots": 7,
        "tour_operator": {
          "id": 5,
          "name": "Djibouti Adventures",
          "slug": "djibouti-adventures"
        },
        "featured_image": {
          "id": 45,
          "url": "http://91.134.241.240/storage/media/images/lac-assal.jpg",
          "alt": "Lac Assal"
        },
        "created_at": "2025-01-15T10:30:00.000000Z",
        "updated_at": "2025-01-17T14:22:00.000000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 3,
      "per_page": 10,
      "total": 28,
      "from": 1,
      "to": 10
    },
    "filters": {
      "operators": [
        {
          "id": 5,
          "name": "Djibouti Adventures",
          "slug": "djibouti-adventures"
        }
      ],
      "types": [
        { "value": "poi", "label": "Visite de site" },
        { "value": "event", "label": "Accompagnement événement" },
        { "value": "mixed", "label": "Circuit mixte" },
        { "value": "cultural", "label": "Culturel" },
        { "value": "adventure", "label": "Aventure" },
        { "value": "nature", "label": "Nature" },
        { "value": "gastronomic", "label": "Gastronomique" }
      ],
      "difficulties": [
        { "value": "easy", "label": "Facile" },
        { "value": "moderate", "label": "Modéré" },
        { "value": "difficult", "label": "Difficile" },
        { "value": "expert", "label": "Expert" }
      ]
    }
  }
}
```

---

### 2. Détails d'un tour

**GET** `/tours/{identifier}`

Récupère les détails complets d'un tour. L'identifiant peut être l'ID numérique ou le slug.

#### Exemple de requête

```bash
curl -X GET "http://91.134.241.240/api/tours/visite-lac-assal" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

#### Exemple de réponse

```json
{
  "success": true,
  "data": {
    "tour": {
      "id": 1,
      "slug": "visite-lac-assal",
      "title": "Visite du Lac Assal",
      "type": "nature",
      "type_label": "Nature",
      "difficulty_level": "moderate",
      "difficulty_label": "Modéré",
      "start_date": "2025-02-01",
      "end_date": "2025-02-01",
      "formatted_date_range": "01/02/2025",
      "duration": {
        "hours": 6,
        "days": 1,
        "formatted": "1 jour 6 heures"
      },
      "price": 8000,
      "formatted_price": "8 000 DJF",
      "is_free": false,
      "is_featured": true,
      "max_participants": 15,
      "min_participants": 4,
      "available_spots": 7,
      "description": "Découvrez le point le plus bas d'Afrique avec ses paysages lunaires...",
      "itinerary": "09h00 - Départ de Djibouti\n10h30 - Arrivée au Lac Assal...",
      "meeting_point": {
        "latitude": 11.5951,
        "longitude": 43.1480,
        "address": "Place Mahmoud Harbi, Djibouti",
        "description": "Devant la banque centrale"
      },
      "highlights": [
        "Point le plus bas d'Afrique",
        "Paysages volcaniques uniques",
        "Sel cristallisé"
      ],
      "what_to_bring": [
        "Chaussures de marche",
        "Chapeau et crème solaire",
        "Eau minérale"
      ],
      "age_restrictions": {
        "min": 12,
        "max": null,
        "text": "à partir de 12 ans"
      },
      "weather_dependent": true,
      "views_count": 342,
      "tour_operator": {
        "id": 5,
        "name": "Djibouti Adventures",
        "slug": "djibouti-adventures"
      },
      "featured_image": {
        "id": 45,
        "url": "http://91.134.241.240/storage/media/images/lac-assal.jpg",
        "alt": "Lac Assal",
        "order": 0
      },
      "media": [
        {
          "id": 46,
          "url": "http://91.134.241.240/storage/media/images/lac-assal-2.jpg",
          "alt": "Vue panoramique",
          "order": 1
        }
      ],
      "created_at": "2025-01-15T10:30:00.000000Z",
      "updated_at": "2025-01-17T14:22:00.000000Z"
    }
  }
}
```

---

## Endpoints API Réservations

### 3. Créer une réservation

**POST** `/tour-reservations/{tour}/register`

Crée une nouvelle réservation pour un tour. Support pour utilisateurs authentifiés, anonymes et invités.

#### Corps de la requête

##### Utilisateur authentifié

```json
{
  "number_of_people": 2,
  "notes": "Nous préférons un guide anglophone"
}
```

##### Utilisateur invité (sans compte)

```json
{
  "number_of_people": 2,
  "guest_name": "Jean Dupont",
  "guest_email": "jean.dupont@example.com",
  "guest_phone": "+253 77 12 34 56",
  "notes": "Première visite à Djibouti"
}
```

#### Validation

- `number_of_people` : requis, entier, min 1, max 20
- `guest_name` : requis si non authentifié, max 255 caractères
- `guest_email` : requis si non authentifié, email valide
- `guest_phone` : optionnel, max 20 caractères
- `notes` : optionnel, max 1000 caractères

#### Exemple de requête (utilisateur authentifié)

```bash
curl -X POST "http://91.134.241.240/api/tour-reservations/1/register" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -H "Accept-Language: fr" \
  -d '{
    "number_of_people": 2,
    "notes": "Guide anglophone souhaité"
  }'
```

#### Exemple de requête (invité)

```bash
curl -X POST "http://91.134.241.240/api/tour-reservations/1/register" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: fr" \
  -d '{
    "number_of_people": 3,
    "guest_name": "Ahmed Mohamed",
    "guest_email": "ahmed@example.com",
    "guest_phone": "+253 77 12 34 56",
    "notes": "Besoin d'\''assistance en français"
  }'
```

#### Exemple de réponse (succès)

```json
{
  "success": true,
  "message": "Tour reservation request sent successfully. It is pending confirmation from the operator.",
  "reservation": {
    "id": 42,
    "tour_id": 1,
    "app_user_id": 15,
    "guest_name": null,
    "guest_email": null,
    "guest_phone": null,
    "number_of_people": 2,
    "status": "pending",
    "notes": "Guide anglophone souhaité",
    "created_at": "2025-01-17T16:45:00.000000Z",
    "updated_at": "2025-01-17T16:45:00.000000Z"
  }
}
```

#### Exemple de réponse (erreur - capacité dépassée)

```json
{
  "success": false,
  "message": "Not enough available spots for the number of people requested.",
  "available_spots": 5
}
```

---

### 4. Mes réservations

**GET** `/tour-reservations/{}`

**⚠️ Note** : Il semble y avoir une erreur dans la route (placeholder vide). Utiliser comme endpoint protégé.

Liste toutes les réservations de l'utilisateur authentifié.

#### Exemple de requête

```bash
curl -X GET "http://91.134.241.240/api/tour-reservations" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer {token}" \
  -H "Accept-Language: fr"
```

#### Exemple de réponse

```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 42,
        "tour_id": 1,
        "app_user_id": 15,
        "number_of_people": 2,
        "status": "pending",
        "notes": "Guide anglophone souhaité",
        "tour": {
          "id": 1,
          "slug": "visite-lac-assal",
          "translations": [
            {
              "locale": "fr",
              "title": "Visite du Lac Assal"
            }
          ],
          "tour_operator": {
            "id": 5,
            "translations": [
              {
                "locale": "fr",
                "name": "Djibouti Adventures"
              }
            ]
          }
        },
        "created_at": "2025-01-17T16:45:00.000000Z",
        "updated_at": "2025-01-17T16:45:00.000000Z"
      }
    ],
    "per_page": 15,
    "total": 3
  }
}
```

---

### 5. Détails d'une réservation

**GET** `/tour-reservations/{reservation}`

Récupère les détails d'une réservation spécifique. Requiert authentification et autorisation (uniquement propriétaire).

#### Exemple de requête

```bash
curl -X GET "http://91.134.241.240/api/tour-reservations/42" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer {token}" \
  -H "Accept-Language: fr"
```

#### Exemple de réponse

```json
{
  "success": true,
  "data": {
    "id": 42,
    "tour_id": 1,
    "app_user_id": 15,
    "number_of_people": 2,
    "status": "confirmed",
    "notes": "Guide anglophone souhaité",
    "tour": {
      "id": 1,
      "slug": "visite-lac-assal",
      "price": 8000,
      "translations": [
        {
          "locale": "fr",
          "title": "Visite du Lac Assal",
          "description": "..."
        }
      ],
      "tour_operator": {
        "id": 5,
        "slug": "djibouti-adventures",
        "translations": [
          {
            "locale": "fr",
            "name": "Djibouti Adventures"
          }
        ]
      }
    },
    "created_at": "2025-01-17T16:45:00.000000Z",
    "updated_at": "2025-01-17T18:30:00.000000Z"
  }
}
```

---

### 6. Mettre à jour une réservation

**PATCH** `/tour-reservations/{reservation}`

Met à jour une réservation existante. Seulement possible si `status` = `pending` ou `confirmed`.

#### Corps de la requête

```json
{
  "number_of_people": 3,
  "notes": "Modification : besoin de 3 places maintenant"
}
```

#### Validation

- `number_of_people` : optionnel, entier, min 1, max 20
- `notes` : optionnel, max 1000 caractères

#### Exemple de requête

```bash
curl -X PATCH "http://91.134.241.240/api/tour-reservations/42" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -H "Accept-Language: fr" \
  -d '{
    "number_of_people": 3,
    "notes": "Changement du nombre de participants"
  }'
```

#### Exemple de réponse (succès)

```json
{
  "success": true,
  "message": "Tour reservation successfully updated.",
  "reservation": {
    "id": 42,
    "number_of_people": 3,
    "notes": "Changement du nombre de participants",
    "status": "pending",
    "updated_at": "2025-01-17T19:00:00.000000Z"
  }
}
```

---

### 7. Annuler une réservation

**PATCH** `/tour-reservations/{reservation}/cancel`

Annule une réservation existante. Seulement possible si `status` = `pending` ou `confirmed`.

#### Exemple de requête

```bash
curl -X PATCH "http://91.134.241.240/api/tour-reservations/42/cancel" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer {token}" \
  -H "Accept-Language: fr"
```

#### Exemple de réponse (succès)

```json
{
  "success": true,
  "message": "Tour reservation successfully cancelled.",
  "reservation": {
    "id": 42,
    "status": "cancelled_by_user",
    "updated_at": "2025-01-18T10:15:00.000000Z"
  }
}
```

#### Exemple de réponse (erreur)

```json
{
  "success": false,
  "message": "This reservation cannot be cancelled.",
  "current_status": "cancelled_by_user"
}
```

---

## Modèles de données

### Tour (complet)

```typescript
interface Tour {
  id: number;
  slug: string;
  title: string; // Traduit selon Accept-Language

  // Type et classification
  type: 'poi' | 'event' | 'mixed' | 'cultural' | 'adventure' | 'nature' | 'gastronomic';
  type_label: string;
  difficulty_level: 'easy' | 'moderate' | 'difficult' | 'expert';
  difficulty_label: string;

  // Dates
  start_date: string | null; // YYYY-MM-DD
  end_date: string | null; // YYYY-MM-DD
  formatted_date_range: string;

  // Durée
  duration: {
    hours: number | null;
    days: number;
    formatted: string;
  };

  // Prix
  price: number;
  formatted_price: string;
  is_free: boolean;

  // Capacité
  max_participants: number | null;
  min_participants: number | null;
  available_spots: number; // Calculé: max_participants - current_participants

  // État
  is_featured: boolean;
  status: 'active' | 'inactive' | 'draft';

  // Contenu traduit
  description?: string;
  itinerary?: string;

  // Point de rencontre
  meeting_point?: {
    latitude: number | null;
    longitude: number | null;
    address: string | null;
    description: string | null;
  };

  // Listes
  highlights?: string[];
  what_to_bring?: string[];

  // Restrictions
  age_restrictions?: {
    min: number | null;
    max: number | null;
    text: string;
  };
  weather_dependent: boolean;

  // Statistiques
  views_count: number;

  // Relations
  tour_operator: {
    id: number;
    name: string;
    slug: string;
  };

  featured_image: {
    id: number;
    url: string;
    alt: string;
  } | null;

  media?: Array<{
    id: number;
    url: string;
    alt: string;
    order: number;
  }>;

  // Timestamps
  created_at: string; // ISO 8601
  updated_at: string; // ISO 8601
}
```

### TourReservation (complet)

```typescript
interface TourReservation {
  id: number;
  tour_id: number;

  // Utilisateur
  app_user_id: number | null;

  // Invité (si app_user_id est null)
  guest_name: string | null;
  guest_email: string | null;
  guest_phone: string | null;

  // Détails de la réservation
  number_of_people: number;
  notes: string | null;

  // État
  status: 'pending' | 'confirmed' | 'cancelled_by_user';

  // Relation tour (si incluse)
  tour?: Tour;

  // Timestamps
  created_at: string; // ISO 8601
  updated_at: string; // ISO 8601
}
```

---

## Flux de réservation

### Scénario 1 : Utilisateur authentifié

```
1. Navigation dans les tours
   GET /api/tours?type=nature&difficulty=easy

2. Consultation des détails
   GET /api/tours/visite-lac-assal

3. Vérification de la disponibilité
   - Vérifier available_spots > 0
   - Vérifier available_spots >= number_of_people souhaité

4. Création de la réservation
   POST /api/tour-reservations/1/register
   Headers: Authorization: Bearer {token}
   Body: {
     "number_of_people": 2,
     "notes": "..."
   }

5. Réservation créée avec status "pending"
   Le tour.current_participants est automatiquement incrémenté

6. Consultation de mes réservations
   GET /api/tour-reservations

7. L'opérateur confirme → status passe à "confirmed"
   (via l'interface opérateur, pas via l'API mobile)

8. Annulation possible si besoin
   PATCH /api/tour-reservations/42/cancel
```

### Scénario 2 : Invité (sans compte)

```
1. Navigation sans authentification
   GET /api/tours

2. Consultation des détails
   GET /api/tours/1

3. Création de la réservation sans token
   POST /api/tour-reservations/1/register
   Body: {
     "number_of_people": 2,
     "guest_name": "Jean Dupont",
     "guest_email": "jean@example.com",
     "guest_phone": "+253 77 12 34 56",
     "notes": "..."
   }

4. Réservation créée (guest fields remplis, app_user_id = null)
   Email de confirmation envoyé à guest_email

5. L'invité peut ensuite créer un compte et ses réservations
   seront liées à son compte
```

### Scénario 3 : Modification

```
1. Utilisateur consulte sa réservation
   GET /api/tour-reservations/42

2. Vérifier si status = "pending" ou "confirmed"

3. Modifier la réservation
   PATCH /api/tour-reservations/42
   Body: {
     "number_of_people": 3
   }

4. Mise à jour réussie si disponibilité suffisante
```

---

## Exemples d'intégration

### React Native / Expo

#### Service API (tours.service.ts)

```typescript
import axios from 'axios';

const API_BASE_URL = 'http://91.134.241.240/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Accept-Language': 'fr',
  },
});

// Intercepteur pour ajouter le token
apiClient.interceptors.request.use(async (config) => {
  const token = await getAuthToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const toursService = {
  // Liste des tours
  async getTours(params?: {
    search?: string;
    type?: string;
    difficulty?: string;
    operator_id?: number;
    min_price?: number;
    max_price?: number;
    max_duration_hours?: number;
    featured?: boolean;
    sort_by?: string;
    sort_order?: string;
    page?: number;
    per_page?: number;
  }) {
    const response = await apiClient.get('/tours', { params });
    return response.data;
  },

  // Détails d'un tour
  async getTourDetails(tourId: number | string) {
    const response = await apiClient.get(`/tours/${tourId}`);
    return response.data;
  },

  // Tours à proximité
  async getNearbyTours(latitude: number, longitude: number, radius: number = 50) {
    const response = await apiClient.get('/tours', {
      params: { latitude, longitude, radius },
    });
    return response.data;
  },

  // Créer une réservation
  async createReservation(tourId: number, data: {
    number_of_people: number;
    guest_name?: string;
    guest_email?: string;
    guest_phone?: string;
    notes?: string;
  }) {
    const response = await apiClient.post(`/tour-reservations/${tourId}/register`, data);
    return response.data;
  },

  // Mes réservations
  async getMyReservations() {
    const response = await apiClient.get('/tour-reservations');
    return response.data;
  },

  // Détails d'une réservation
  async getReservationDetails(reservationId: number) {
    const response = await apiClient.get(`/tour-reservations/${reservationId}`);
    return response.data;
  },

  // Mettre à jour une réservation
  async updateReservation(reservationId: number, data: {
    number_of_people?: number;
    notes?: string;
  }) {
    const response = await apiClient.patch(`/tour-reservations/${reservationId}`, data);
    return response.data;
  },

  // Annuler une réservation
  async cancelReservation(reservationId: number) {
    const response = await apiClient.patch(`/tour-reservations/${reservationId}/cancel`);
    return response.data;
  },
};
```

#### Hook personnalisé (useTours.ts)

```typescript
import { useState, useEffect } from 'react';
import { toursService } from './tours.service';

export const useTours = (filters?: any) => {
  const [tours, setTours] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [pagination, setPagination] = useState(null);

  const fetchTours = async (page = 1) => {
    try {
      setLoading(true);
      const response = await toursService.getTours({ ...filters, page });
      setTours(response.data.tours);
      setPagination(response.data.pagination);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTours();
  }, [filters]);

  return { tours, loading, error, pagination, refetch: fetchTours };
};

export const useTourDetails = (tourId: number | string) => {
  const [tour, setTour] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchTour = async () => {
      try {
        setLoading(true);
        const response = await toursService.getTourDetails(tourId);
        setTour(response.data.tour);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    if (tourId) {
      fetchTour();
    }
  }, [tourId]);

  return { tour, loading, error };
};
```

#### Composant de réservation (BookingForm.tsx)

```typescript
import React, { useState } from 'react';
import { View, TextInput, Button, Alert } from 'react-native';
import { toursService } from './tours.service';
import { useAuth } from './useAuth';

export const BookingForm = ({ tour, onSuccess }) => {
  const { user } = useAuth();
  const [numberOfPeople, setNumberOfPeople] = useState(1);
  const [guestName, setGuestName] = useState('');
  const [guestEmail, setGuestEmail] = useState('');
  const [guestPhone, setGuestPhone] = useState('');
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    // Validation
    if (tour.available_spots < numberOfPeople) {
      Alert.alert('Erreur', `Seulement ${tour.available_spots} places disponibles`);
      return;
    }

    if (!user && (!guestName || !guestEmail)) {
      Alert.alert('Erreur', 'Veuillez remplir vos informations de contact');
      return;
    }

    try {
      setLoading(true);

      const data: any = {
        number_of_people: numberOfPeople,
        notes,
      };

      // Si utilisateur non authentifié, ajouter les infos invité
      if (!user) {
        data.guest_name = guestName;
        data.guest_email = guestEmail;
        data.guest_phone = guestPhone;
      }

      const response = await toursService.createReservation(tour.id, data);

      Alert.alert(
        'Succès',
        'Votre réservation a été créée. Elle est en attente de confirmation par l\'opérateur.',
        [{ text: 'OK', onPress: () => onSuccess(response.reservation) }]
      );
    } catch (error) {
      const errorMessage = error.response?.data?.message || 'Une erreur est survenue';
      Alert.alert('Erreur', errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View>
      {/* Nombre de personnes */}
      <TextInput
        placeholder="Nombre de personnes"
        value={String(numberOfPeople)}
        onChangeText={(text) => setNumberOfPeople(parseInt(text) || 1)}
        keyboardType="number-pad"
      />

      {/* Infos invité si non authentifié */}
      {!user && (
        <>
          <TextInput
            placeholder="Nom complet *"
            value={guestName}
            onChangeText={setGuestName}
          />
          <TextInput
            placeholder="Email *"
            value={guestEmail}
            onChangeText={setGuestEmail}
            keyboardType="email-address"
          />
          <TextInput
            placeholder="Téléphone"
            value={guestPhone}
            onChangeText={setGuestPhone}
            keyboardType="phone-pad"
          />
        </>
      )}

      {/* Notes */}
      <TextInput
        placeholder="Notes ou demandes spéciales"
        value={notes}
        onChangeText={setNotes}
        multiline
        numberOfLines={4}
      />

      <Button
        title={loading ? 'Envoi en cours...' : 'Confirmer la réservation'}
        onPress={handleSubmit}
        disabled={loading}
      />
    </View>
  );
};
```

---

## Gestion des erreurs

### Codes de statut HTTP

| Code | Signification | Description |
|------|---------------|-------------|
| 200 | OK | Requête réussie |
| 201 | Created | Ressource créée |
| 400 | Bad Request | Données invalides |
| 401 | Unauthorized | Non authentifié |
| 403 | Forbidden | Accès refusé |
| 404 | Not Found | Ressource introuvable |
| 422 | Unprocessable Entity | Erreurs de validation |
| 500 | Server Error | Erreur serveur |

### Format des erreurs

```json
{
  "success": false,
  "message": "Message d'erreur principal",
  "errors": {
    "field_name": [
      "Message d'erreur pour ce champ"
    ]
  }
}
```

### Gestion côté client

```typescript
try {
  const response = await toursService.createReservation(tourId, data);
  // Succès
} catch (error) {
  if (error.response) {
    const { status, data } = error.response;

    switch (status) {
      case 422:
        // Erreurs de validation
        if (data.errors) {
          Object.entries(data.errors).forEach(([field, messages]) => {
            console.error(`${field}: ${messages.join(', ')}`);
          });
        }
        Alert.alert('Erreur', data.message);
        break;

      case 401:
        // Non authentifié
        navigation.navigate('Login');
        break;

      case 403:
        // Accès refusé
        Alert.alert('Accès refusé', data.message);
        break;

      case 404:
        // Ressource introuvable
        Alert.alert('Erreur', 'Tour introuvable');
        break;

      default:
        Alert.alert('Erreur', data.message || 'Une erreur est survenue');
    }
  } else if (error.request) {
    Alert.alert('Erreur', 'Impossible de contacter le serveur');
  } else {
    Alert.alert('Erreur', error.message);
  }
}
```

---

## Points importants

### Gestion de la capacité

- `current_participants` est automatiquement incrémenté lors de la création d'une réservation
- `available_spots` est calculé dynamiquement : `max_participants - current_participants`
- Utilisation de `lockForUpdate()` pour éviter les race conditions lors des réservations simultanées

### Multilingue

- Header `Accept-Language: fr|en|ar` détermine la langue du contenu
- Toutes les traductions sont gérées côté serveur
- Fallback automatique vers le français si traduction manquante

### Utilisateurs invités

- Peuvent consulter tous les tours sans authentification
- Peuvent créer des réservations en fournissant nom et email
- Leurs réservations sont stockées avec `app_user_id = null`
- `guest_name`, `guest_email`, `guest_phone` sont remplis

### Statuts de réservation

- `pending` : En attente de confirmation opérateur (état initial)
- `confirmed` : Confirmée par l'opérateur
- `cancelled_by_user` : Annulée par l'utilisateur
- Seules les réservations `pending` ou `confirmed` peuvent être modifiées/annulées

---

## Support

Pour toute question technique :
- **Documentation API complète** : `API_DOCUMENTATION.md`
- **Email** : dev@visitdjibouti.dj

---

**Document généré le 17 Janvier 2025**
**Version : 1.0**
**Basé sur le code source réel**
