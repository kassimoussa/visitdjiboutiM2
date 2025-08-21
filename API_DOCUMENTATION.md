# 📱 API Documentation - Visit Djibouti Mobile App

**Complete API with 33 endpoints** for mobile tourism application with authentication, POIs, events, favorites, tour operators, app settings, and organization management.

## 🚀 New: Anonymous User Support
The API now supports **anonymous users** for a frictionless onboarding experience. Users can browse, add favorites, and make reservations without providing personal information, then convert to full accounts when ready.

## 🔐 Authentication Endpoints

### Base URL
```
http://your-domain.com/api
```

### Headers Required for Protected Routes
```
Authorization: Bearer {your_token}
Content-Type: application/json
Accept: application/json
```

---

## 👤 User Authentication

### 📝 Register
**POST** `/auth/register`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "+253 21 35 40 50",
  "preferred_language": "fr",
  "date_of_birth": "1990-05-15",
  "gender": "male"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+253 21 35 40 50",
      "preferred_language": "fr",
      "is_active": true,
      "avatar_url": null,
      "age": 33,
      "is_social_user": false
    },
    "token": "1|abc123...",
    "token_type": "Bearer"
  }
}
```

### 🔑 Login
**POST** `/auth/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { /* user object */ },
    "token": "2|def456...",
    "token_type": "Bearer"
  }
}
```

### 🚪 Logout
**POST** `/auth/logout` (Protected)

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 🎭 Anonymous User Authentication

### 🆔 Create Anonymous User
**POST** `/auth/anonymous`

Create an anonymous user for immediate app usage without requiring personal information.

**Request Body:**
```json
{
  "device_id": "unique-device-identifier", // Optional but recommended
  "preferred_language": "fr" // Optional: fr, en, ar
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Utilisateur anonyme créé avec succès",
  "data": {
    "user": {
      "id": 123,
      "is_anonymous": true,
      "anonymous_id": "anon_66c5f9d47a2ef_1724234196",
      "device_id": "unique-device-identifier",
      "preferred_language": "fr",
      "is_active": true,
      "display_name": "Utilisateur anonyme",
      "unique_identifier": "anon_66c5f9d47a2ef_1724234196"
    },
    "token": "3|PlainTextToken",
    "anonymous_id": "anon_66c5f9d47a2ef_1724234196",
    "is_existing": false
  }
}
```

### 🔍 Retrieve Anonymous User
**POST** `/auth/anonymous/retrieve`

Retrieve an existing anonymous user by their anonymous_id.

**Request Body:**
```json
{
  "anonymous_id": "anon_66c5f9d47a2ef_1724234196"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Utilisateur anonyme récupéré",
  "data": {
    "user": { /* anonymous user object */ },
    "token": "4|NewPlainTextToken",
    "anonymous_id": "anon_66c5f9d47a2ef_1724234196"
  }
}
```

### 🔄 Convert Anonymous to Complete Account
**POST** `/auth/convert-anonymous` (Protected - Anonymous Token Required)

Convert an anonymous user to a complete account with full registration.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "+253 21 35 40 50",
  "date_of_birth": "1990-05-15",
  "gender": "male",
  "city": "Djibouti",
  "country": "Djibouti",
  "conversion_source": "favorites_prompted" // Optional tracking
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Compte converti avec succès",
  "data": {
    "user": {
      "id": 123,
      "name": "John Doe",
      "email": "john@example.com",
      "is_anonymous": false,
      "converted_at": "2024-08-21T10:30:00.000000Z",
      "conversion_source": {
        "source": "favorites_prompted",
        "timestamp": "2024-08-21T10:30:00.000000Z"
      }
      // ... complete user object
    },
    "token": "5|NewCompleteUserToken"
  }
}
```

### ⚙️ Update Anonymous Preferences
**PUT** `/auth/anonymous/preferences` (Protected - Anonymous Token Required)

Update preferences for an anonymous user.

**Request Body:**
```json
{
  "preferred_language": "en",
  "push_notifications_enabled": true
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Préférences mises à jour",
  "data": {
    "user": { /* updated anonymous user object */ }
  }
}
```

### 🗑️ Delete Anonymous User
**DELETE** `/auth/anonymous` (Protected - Anonymous Token Required)

Delete an anonymous user and all associated data (favorites, reservations).

**Response:**
```json
{
  "status": "success",
  "message": "Utilisateur anonyme supprimé avec succès"
}
```

### 🔄 Anonymous User Workflow
1. **App Launch**: Call `POST /auth/anonymous` with device_id
2. **Usage**: Use returned token for all API calls (favorites, reservations)
3. **Conversion**: When user decides to register, call `POST /auth/convert-anonymous`
4. **Seamless Transition**: All existing data (favorites, reservations) is preserved

---

## 👤 User Profile Management

### 📋 Get Profile
**GET** `/auth/profile` (Protected)

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+253 21 35 40 50",
      "avatar": null,
      "date_of_birth": "1990-05-15",
      "gender": "male",
      "preferred_language": "fr",
      "push_notifications_enabled": true,
      "email_notifications_enabled": true,
      "city": "Djibouti",
      "country": "DJ",
      "provider": "email",
      "is_active": true,
      "last_login_at": "2024-08-12T10:30:00Z",
      "avatar_url": null,
      "age": 33,
      "is_social_user": false
    }
  }
}
```

### ✏️ Update Profile
**PUT** `/auth/profile` (Protected)

**Request Body:**
```json
{
  "name": "John Updated",
  "phone": "+253 21 35 41 60",
  "preferred_language": "en",
  "date_of_birth": "1990-05-15",
  "gender": "male",
  "city": "Ali Sabieh",
  "push_notifications_enabled": false,
  "email_notifications_enabled": true
}
```

### 🔒 Change Password
**POST** `/auth/change-password` (Protected)

**Request Body:**
```json
{
  "current_password": "oldpassword123",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

### 🗑️ Delete Account
**DELETE** `/auth/account` (Protected)

**Request Body:**
```json
{
  "password": "currentpassword123"
}
```

---

## 🔗 OAuth Social Authentication

### 🌐 Get OAuth Redirect URL
**GET** `/auth/{provider}/redirect`

**Parameters:**
- `provider`: `google` or `facebook`

**Response:**
```json
{
  "success": true,
  "data": {
    "redirect_url": "https://accounts.google.com/oauth/authorize?client_id=..."
  }
}
```

### 🔄 OAuth Callback
**GET** `/auth/{provider}/callback`

Automatically handles the OAuth callback and returns user data with token.

**Response:**
```json
{
  "success": true,
  "message": "Social authentication successful",
  "data": {
    "user": { /* user object */ },
    "token": "3|ghi789...",
    "token_type": "Bearer",
    "provider": "google"
  }
}
```

### 📱 Mobile OAuth (Token-based)
**POST** `/auth/{provider}/token`

For mobile apps that handle OAuth flow themselves.

**Request Body:**
```json
{
  "access_token": "oauth_access_token_from_provider"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Social authentication successful",
  "data": {
    "user": { /* user object */ },
    "token": "4|jkl012...",
    "token_type": "Bearer",
    "provider": "facebook"
  }
}
```

### 🔓 Unlink Social Account
**DELETE** `/auth/{provider}/unlink` (Protected)

**Parameters:**
- `provider`: `google` or `facebook`

**Response:**
```json
{
  "success": true,
  "message": "Google account unlinked successfully"
}
```

### 📋 Get Linked Accounts
**GET** `/auth/linked-accounts` (Protected)

**Response:**
```json
{
  "success": true,
  "data": {
    "linked_accounts": {
      "email": true,
      "google": true,
      "facebook": false
    },
    "primary_provider": "google"
  }
}
```

---

## 📊 Response Format

### ✅ Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ }
}
```

### ❌ Error Response
```json
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field_name": ["Error details"]
  }
}
```

---

## 🚨 HTTP Status Codes

- `200` - OK
- `201` - Created
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Server Error

---

## 🧪 Testing with cURL

### Register a new user
```bash
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "preferred_language": "fr"
  }'
```

### Login
```bash
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Get profile (replace TOKEN with actual token)
```bash
curl -X GET http://localhost/api/auth/profile \
  -H "Authorization: Bearer TOKEN" \
  -H "Accept: application/json"
```

### Get all POIs
```bash
curl -X GET "http://localhost/api/pois?featured=1&region=Tadjourah" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

### Get POI details
```bash
curl -X GET http://localhost/api/pois/1 \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

### Search nearby POIs
```bash
curl -X GET "http://localhost/api/pois/nearby?latitude=11.6560&longitude=42.4065&radius=20" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

### Get upcoming events
```bash
curl -X GET "http://localhost/api/events?status=upcoming&featured=1" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

### Register for event (authenticated)
```bash
curl -X POST http://localhost/api/events/1/register \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "participants_count": 2,
    "special_requirements": "Accès PMR nécessaire"
  }'
```

### Register for event (guest)
```bash
curl -X POST http://localhost/api/events/1/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "participants_count": 1,
    "user_name": "Jean Dupont",
    "user_email": "jean@example.com",
    "user_phone": "+253 21 35 40 50"
  }'
```

### Get organization information
```bash
curl -X GET http://localhost/api/organization \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

### Get external links
```bash
curl -X GET http://localhost/api/external-links \
  -H "Accept: application/json"
```

### Get embassies by type
```bash
curl -X GET http://localhost/api/embassies/type/foreign_in_djibouti \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

---

## 🏛️ Points of Interest (POIs)

### 📍 Get All POIs
**GET** `/pois`

**Query Parameters:**
- `search` - Search by name or description
- `category_id` - Filter by category ID
- `region` - Filter by region (Djibouti, Ali Sabieh, Dikhil, Tadjourah, Obock, Arta)
- `featured` - Filter featured POIs only (any value)
- `sort_by` - Sort by: `created_at`, `name` (default: `created_at`)
- `sort_order` - Sort order: `asc`, `desc` (default: `desc`)
- `per_page` - Items per page (max 50, default: 15)
- `page` - Page number

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "pois": [
      {
        "id": 1,
        "slug": "lac-assal",
        "name": "Lac Assal",
        "short_description": "Le point le plus bas d'Afrique",
        "address": "Route du Lac Assal",
        "region": "Tadjourah",
        "full_address": "Route du Lac Assal, Tadjourah",
        "latitude": 11.6560,
        "longitude": 42.4065,
        "is_featured": true,
        "allow_reservations": false,
        "website": null,
        "contact": "+253 21 35 40 50",
        "featured_image": {
          "id": 5,
          "url": "https://domain.com/storage/media/images/lac-assal.jpg",
          "alt": "Vue panoramique du Lac Assal"
        },
        "categories": [
          {
            "id": 2,
            "name": "Sites Naturels",
            "slug": "sites-naturels"
          }
        ],
        "favorites_count": 23,
        "is_favorited": true,
        "created_at": "2024-08-12T10:00:00Z",
        "updated_at": "2024-08-12T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 3,
      "per_page": 15,
      "total": 42,
      "from": 1,
      "to": 15
    },
    "filters": {
      "regions": ["Djibouti", "Ali Sabieh", "Dikhil", "Tadjourah", "Obock", "Arta"],
      "categories": [
        {"id": 1, "name": "Attractions Touristiques", "slug": "attractions"},
        {"id": 2, "name": "Sites Naturels", "slug": "sites-naturels"}
      ]
    }
  }
}
```

### 🔍 Get POI Details
**GET** `/pois/{id}` or **GET** `/pois/{slug}`

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "poi": {
      "id": 1,
      "slug": "lac-assal",
      "name": "Lac Assal",
      "short_description": "Le point le plus bas d'Afrique",
      "description": "Le Lac Assal est un lac salé situé dans la région de Tadjourah...",
      "address": "Route du Lac Assal",
      "region": "Tadjourah",
      "full_address": "Route du Lac Assal, Tadjourah",
      "latitude": 11.6560,
      "longitude": 42.4065,
      "opening_hours": "Ouvert 24h/24",
      "entry_fee": "Gratuit",
      "tips": "Apportez de l'eau et un chapeau, il fait très chaud",
      "is_featured": true,
      "allow_reservations": false,
      "website": null,
      "contact": "+253 21 35 40 50",
      "featured_image": { /* featured image object */ },
      "media": [
        {
          "id": 5,
          "url": "https://domain.com/storage/media/images/lac-assal-1.jpg",
          "alt": "Vue panoramique du Lac Assal",
          "order": 1
        },
        {
          "id": 6,
          "url": "https://domain.com/storage/media/images/lac-assal-2.jpg",
          "alt": "Cristaux de sel au bord du lac",
          "order": 2
        }
      ],
      "categories": [ /* categories array */ ],
      "created_at": "2024-08-12T10:00:00Z",
      "updated_at": "2024-08-12T10:00:00Z"
    }
  }
}
```

### 📂 Get POIs by Category
**GET** `/pois/category/{category_id}`

**Query Parameters:**
- `per_page` - Items per page (max 50, default: 15)
- `page` - Page number

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "category": {
      "id": 2,
      "name": "Sites Naturels",
      "description": "Découvrez les merveilles naturelles de Djibouti"
    },
    "pois": [ /* array of POIs */ ],
    "pagination": { /* pagination object */ }
  }
}
```

### 📍 Get Nearby POIs
**GET** `/pois/nearby`

**Query Parameters (Required):**
- `latitude` - Latitude (-90 to 90)
- `longitude` - Longitude (-180 to 180)

**Query Parameters (Optional):**
- `radius` - Search radius in kilometers (1-100, default: 10)
- `limit` - Maximum results (max 50, default: 20)

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "pois": [
      {
        "id": 1,
        "slug": "lac-assal",
        "name": "Lac Assal",
        "distance": 5.23,
        /* ... other POI fields ... */
      }
    ],
    "search_params": {
      "latitude": 11.6560,
      "longitude": 42.4065,
      "radius_km": 10,
      "total_found": 3
    }
  }
}
```

---

## 🎉 Events

### 📅 Get All Events
**GET** `/events`

**Query Parameters:**
- `search` - Search by title or description
- `category_id` - Filter by category ID
- `date_from` - Filter events from date (YYYY-MM-DD)
- `date_to` - Filter events to date (YYYY-MM-DD)
- `status` - Filter by status: `upcoming`, `ongoing`
- `featured` - Filter featured events only (any value)
- `location` - Filter by location
- `sort_by` - Sort by: `start_date`, `title`, `created_at` (default: `start_date`)
- `sort_order` - Sort order: `asc`, `desc` (default: `asc`)
- `per_page` - Items per page (max 50, default: 15)
- `page` - Page number

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": 1,
        "slug": "festival-culturel-djibouti",
        "title": "Festival Culturel de Djibouti 2024",
        "short_description": "Célébration de la culture djiboutienne",
        "location": "Place du 27 Juin",
        "full_location": "Place du 27 Juin - Centre ville de Djibouti",
        "start_date": "2024-12-15T00:00:00Z",
        "end_date": "2024-12-17T00:00:00Z",
        "start_time": "18:00",
        "end_time": "23:00",
        "formatted_date_range": "15/12/2024 - 17/12/2024",
        "price": 0.00,
        "is_free": true,
        "is_featured": true,
        "max_participants": 500,
        "current_participants": 245,
        "available_spots": 255,
        "is_sold_out": false,
        "is_active": true,
        "is_ongoing": false,
        "has_ended": false,
        "organizer": "Ministère de la Culture",
        "featured_image": {
          "id": 8,
          "url": "https://domain.com/storage/media/images/festival.jpg",
          "alt": "Festival Culturel de Djibouti"
        },
        "categories": [
          {
            "id": 3,
            "name": "Culture & Arts",
            "slug": "culture-arts"
          }
        ],
        "created_at": "2024-08-12T10:00:00Z",
        "updated_at": "2024-08-12T10:00:00Z"
      }
    ],
    "pagination": { /* pagination object */ },
    "filters": {
      "categories": [ /* categories array */ ]
    }
  }
}
```

### 🔍 Get Event Details
**GET** `/events/{id}` or **GET** `/events/{slug}`

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "event": {
      "id": 1,
      "slug": "festival-culturel-djibouti",
      "title": "Festival Culturel de Djibouti 2024",
      "short_description": "Célébration de la culture djiboutienne",
      "description": "Venez célébrer la richesse culturelle de Djibouti...",
      "location": "Place du 27 Juin",
      "location_details": "Centre ville de Djibouti, près de la mosquée centrale",
      "full_location": "Place du 27 Juin - Centre ville de Djibouti",
      "requirements": "Aucune exigence particulière",
      "program": "18h: Ouverture, 19h: Spectacles traditionnels...",
      "additional_info": "Restauration sur place disponible",
      "latitude": 11.5721,
      "longitude": 43.1456,
      "contact_email": "culture@djibouti.gov.dj",
      "contact_phone": "+253 21 35 40 50",
      "website_url": "https://culture.djibouti.gov.dj",
      "ticket_url": null,
      "views_count": 1250,
      /* ... other fields from list view ... */,
      "media": [
        {
          "id": 8,
          "url": "https://domain.com/storage/media/images/festival-1.jpg",
          "alt": "Scène principale du festival",
          "order": 1
        }
      ]
    }
  }
}
```

### ✍️ Register for Event
**POST** `/events/{event_id}/register`

**Request Body (Authenticated User):**
```json
{
  "participants_count": 2,
  "special_requirements": "Accès PMR nécessaire"
}
```

**Request Body (Guest Registration):**
```json
{
  "participants_count": 1,
  "user_name": "Jean Dupont",
  "user_email": "jean@example.com",
  "user_phone": "+253 21 35 40 50",
  "special_requirements": null
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "registration": {
      "id": 15,
      "registration_number": "REG-64F2A1B3E4C5D",
      "participants_count": 2,
      "status": "confirmed",
      "payment_status": "paid",
      "payment_amount": 0.00,
      "total_amount": 0.00,
      "special_requirements": "Accès PMR nécessaire",
      "created_at": "2024-08-12T14:30:00Z"
    },
    "payment_required": false,
    "total_amount": 0.00
  }
}
```

### ❌ Cancel Registration
**DELETE** `/events/{event_id}/registration` (Protected)

**Request Body:**
```json
{
  "reason": "Empêchement de dernière minute"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration cancelled successfully"
}
```

### 📋 Get My Registrations
**GET** `/my-registrations` (Protected)

**Query Parameters:**
- `status` - Filter by status: `pending`, `confirmed`, `cancelled`

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "registrations": [
      {
        "id": 15,
        "registration_number": "REG-64F2A1B3E4C5D",
        "participants_count": 2,
        "status": "confirmed",
        "payment_status": "paid",
        "payment_amount": 0.00,
        "total_amount": 0.00,
        "special_requirements": "Accès PMR nécessaire",
        "created_at": "2024-08-12T14:30:00Z",
        "event": {
          "id": 1,
          "slug": "festival-culturel-djibouti",
          "title": "Festival Culturel de Djibouti 2024",
          /* ... other event fields ... */
        }
      }
    ],
    "pagination": { /* pagination object */ }
  }
}
```

---

## ❤️ Favorites Management

### 📋 Get All User Favorites
**GET** `/favorites` 🔐

Retrieve all user's favorites (POIs and Events) with full details.

**Headers:**
- `Authorization: Bearer {token}` (Required)
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "favorites": [
      {
        "id": 1,
        "type": "Poi",
        "slug": "lac-assal",
        "name": "Lac Assal",
        "description": "Le point le plus bas d'Afrique...",
        "short_description": "Un lac salé exceptionnel",
        "featured_image": {
          "id": 5,
          "url": "https://domain.com/storage/media/images/lac-assal.jpg",
          "thumbnail_url": "https://domain.com/storage/media/images/thumbs/lac-assal.jpg",
          "alt_text": "Vue du Lac Assal"
        },
        "categories": [
          {
            "id": 2,
            "name": "Sites Naturels",
            "color": "#22c55e",
            "icon": "fas fa-mountain"
          }
        ],
        "region": "Tadjourah",
        "address": "Route du Lac Assal",
        "latitude": 11.6560,
        "longitude": 42.4065,
        "favorited_at": "2024-08-17T14:30:00Z"
      },
      {
        "id": 3,
        "type": "Event",
        "slug": "festival-nomade",
        "name": "Festival Nomade",
        "description": "Festival célébrant la culture nomade...",
        "short_description": "Célébration de la culture nomade",
        "start_date": "2024-09-15T00:00:00Z",
        "end_date": "2024-09-17T23:59:59Z",
        "location": "Tadjourah",
        "price": 2500,
        "organizer": "Office National du Tourisme",
        "favorited_at": "2024-08-17T10:15:00Z"
      }
    ],
    "total": 2,
    "pois_count": 1,
    "events_count": 1
  }
}
```

### 🏛️ Get User's Favorite POIs
**GET** `/favorites/pois` 🔐

Get only the user's favorite POIs with complete details.

**Headers:**
- `Authorization: Bearer {token}` (Required)
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "pois": [
      {
        "id": 1,
        "slug": "lac-assal",
        "name": "Lac Assal",
        "description": "Le point le plus bas d'Afrique...",
        "short_description": "Un lac salé exceptionnel",
        "address": "Route du Lac Assal",
        "region": "Tadjourah",
        "latitude": 11.6560,
        "longitude": 42.4065,
        "is_featured": true,
        "featured_image": {
          "id": 5,
          "url": "https://domain.com/storage/media/images/lac-assal.jpg",
          "thumbnail_url": "https://domain.com/storage/media/images/thumbs/lac-assal.jpg"
        },
        "categories": [
          {
            "id": 2,
            "name": "Sites Naturels",
            "color": "#22c55e",
            "icon": "fas fa-mountain"
          }
        ],
        "favorites_count": 23,
        "is_favorited": true,
        "favorited_at": "2024-08-17T14:30:00Z"
      }
    ],
    "total": 1
  }
}
```

### ➕ Add POI to Favorites (Toggle)
**POST** `/favorites/pois/{poi}` 🔐

Add or remove a POI from user's favorites. This endpoint toggles the favorite status.

**Headers:**
- `Authorization: Bearer {token}` (Required)

**Response:**
```json
{
  "success": true,
  "message": "Point d'intérêt ajouté aux favoris",
  "data": {
    "is_favorited": true,
    "action": "added",
    "favorites_count": 24
  }
}
```

**If already favorited:**
```json
{
  "success": true,
  "message": "Point d'intérêt retiré des favoris",
  "data": {
    "is_favorited": false,
    "action": "removed",
    "favorites_count": 22
  }
}
```

### ❌ Remove POI from Favorites
**DELETE** `/favorites/pois/{poi}` 🔐

Explicitly remove a POI from user's favorites.

**Headers:**
- `Authorization: Bearer {token}` (Required)

**Response:**
```json
{
  "success": true,
  "message": "Point d'intérêt retiré des favoris",
  "data": {
    "is_favorited": false,
    "removed": true,
    "favorites_count": 22
  }
}
```

### 🎉 Add Event to Favorites (Toggle)
**POST** `/favorites/events/{event}` 🔐

Add or remove an Event from user's favorites. This endpoint toggles the favorite status.

**Headers:**
- `Authorization: Bearer {token}` (Required)

**Response:**
```json
{
  "success": true,
  "message": "Événement ajouté aux favoris",
  "data": {
    "is_favorited": true,
    "action": "added"
  }
}
```

### ❌ Remove Event from Favorites
**DELETE** `/favorites/events/{event}` 🔐

Explicitly remove an Event from user's favorites.

**Headers:**
- `Authorization: Bearer {token}` (Required)

**Response:**
```json
{
  "success": true,
  "message": "Événement retiré des favoris",
  "data": {
    "is_favorited": false,
    "removed": true
  }
}
```

### 📊 Get Favorites Statistics
**GET** `/favorites/stats` 🔐

Get statistics about user's favorites.

**Headers:**
- `Authorization: Bearer {token}` (Required)

**Response:**
```json
{
  "success": true,
  "data": {
    "total_favorites": 15,
    "pois_count": 8,
    "events_count": 7,
    "recent_favorites": [
      {
        "id": 1,
        "type": "Poi",
        "name": "Lac Assal",
        "favorited_at": "2024-08-17T14:30:00Z"
      },
      {
        "id": 3,
        "type": "Event",
        "name": "Festival Nomade",
        "favorited_at": "2024-08-17T10:15:00Z"
      }
    ]
  }
}
```

**cURL Examples:**

```bash
# Get all favorites
curl -X GET "http://your-domain.com/api/favorites" \
  -H "Authorization: Bearer your_token" \
  -H "Accept-Language: fr"

# Add POI to favorites
curl -X POST "http://your-domain.com/api/favorites/pois/1" \
  -H "Authorization: Bearer your_token"

# Remove POI from favorites
curl -X DELETE "http://your-domain.com/api/favorites/pois/1" \
  -H "Authorization: Bearer your_token"

# Get favorites statistics
curl -X GET "http://your-domain.com/api/favorites/stats" \
  -H "Authorization: Bearer your_token"
```

---

## 🏢 Organization Information

### ℹ️ Get Organization Information
**GET** `/organization`

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "organization": {
      "id": 1,
      "name": "Office National du Tourisme de Djibouti",
      "description": "Organisme officiel chargé de la promotion du tourisme à Djibouti",
      "email": "info@visitdjibouti.dj",
      "phone": "+253 21 35 40 50",
      "address": "Boulevard du 26 Juin, Djibouti",
      "opening_hours": "Lundi à Vendredi: 08h00 - 17h00",
      "logo": {
        "id": 1,
        "url": "https://domain.com/storage/media/images/logo.png",
        "alt": "Logo Office du Tourisme"
      },
      "created_at": "2024-08-12T10:00:00Z",
      "updated_at": "2024-08-12T10:00:00Z"
    }
  }
}
```

---

## 🔗 External Links

### 📋 Get All External Links
**GET** `/external-links`

**Response:**
```json
{
  "success": true,
  "data": {
    "links": [
      {
        "id": 1,
        "name": "Ministère du Tourisme",
        "url": "https://tourisme.gouv.dj",
        "status": true,
        "is_external": true,
        "domain": "tourisme.gouv.dj",
        "created_at": "2024-08-12T10:00:00Z",
        "updated_at": "2024-08-12T10:00:00Z"
      },
      {
        "id": 2,
        "name": "Agence Djiboutienne de Développement Social",
        "url": "https://adds.dj",
        "status": true,
        "is_external": true,
        "domain": "adds.dj",
        "created_at": "2024-08-12T10:00:00Z",
        "updated_at": "2024-08-12T10:00:00Z"
      }
    ],
    "total": 2
  }
}
```

### 🔍 Get External Link Details
**GET** `/external-links/{id}`

**Response:**
```json
{
  "success": true,
  "data": {
    "link": {
      "id": 1,
      "name": "Ministère du Tourisme",
      "url": "https://tourisme.gouv.dj",
      "status": true,
      "is_external": true,
      "domain": "tourisme.gouv.dj",
      "created_at": "2024-08-12T10:00:00Z",
      "updated_at": "2024-08-12T10:00:00Z"
    }
  }
}
```

---

## 🏛️ Embassies

### 📋 Get All Embassies
**GET** `/embassies`

**Query Parameters:**
- `type` - Filter by type: `foreign_in_djibouti`, `djiboutian_abroad`
- `search` - Search by name or country
- `country_code` - Filter by country code

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "embassies": [
      {
        "id": 1,
        "type": "foreign_in_djibouti",
        "type_label": "Ambassades étrangères à Djibouti",
        "country_code": "FR",
        "name": "Ambassade de France",
        "ambassador_name": "Son Excellence M. Jean Dupont",
        "phones": ["+253 21 35 40 50", "+253 21 35 40 51"],
        "emails": ["contact@ambafrance-dj.org"],
        "website": "https://dj.ambafrance.org",
        "is_active": true,
        "created_at": "2024-08-12T10:00:00Z",
        "updated_at": "2024-08-12T10:00:00Z"
      }
    ],
    "total": 1,
    "types": {
      "foreign_in_djibouti": "Ambassades étrangères à Djibouti",
      "djiboutian_abroad": "Ambassades djiboutiennes à l'étranger"
    }
  }
}
```

### 🔍 Get Embassy Details
**GET** `/embassies/{id}`

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "embassy": {
      "id": 1,
      "type": "foreign_in_djibouti",
      "type_label": "Ambassades étrangères à Djibouti",
      "country_code": "FR",
      "name": "Ambassade de France",
      "ambassador_name": "Son Excellence M. Jean Dupont",
      "address": "Plateau du Serpent, Djibouti",
      "postal_box": "B.P. 2039",
      "phones": ["+253 21 35 40 50", "+253 21 35 40 51"],
      "emails": ["contact@ambafrance-dj.org"],
      "fax": "+253 21 35 40 52",
      "ld": ["LD1234", "LD5678"],
      "website": "https://dj.ambafrance.org",
      "latitude": 11.5721,
      "longitude": 43.1456,
      "has_coordinates": true,
      "is_active": true,
      "created_at": "2024-08-12T10:00:00Z",
      "updated_at": "2024-08-12T10:00:00Z"
    }
  }
}
```

### 📂 Get Embassies by Type
**GET** `/embassies/type/{type}`

Where `type` is either `foreign_in_djibouti` or `djiboutian_abroad`.

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "embassies": [ /* array of embassies */ ],
    "type": "foreign_in_djibouti",
    "type_label": "Ambassades étrangères à Djibouti",
    "total": 5
  }
}
```

### 📍 Get Nearby Embassies
**GET** `/embassies/nearby`

**Query Parameters (Required):**
- `latitude` - Latitude (-90 to 90)
- `longitude` - Longitude (-180 to 180)

**Query Parameters (Optional):**
- `radius` - Search radius in kilometers (1-100, default: 50)
- `limit` - Maximum results (max 50, default: 20)

**Headers:**
- `Accept-Language` - Language code (fr, en, ar)

**Response:**
```json
{
  "success": true,
  "data": {
    "embassies": [
      {
        "id": 1,
        "type": "foreign_in_djibouti",
        "name": "Ambassade de France",
        "distance": 2.15,
        /* ... other embassy fields ... */
      }
    ],
    "search_params": {
      "latitude": 11.5721,
      "longitude": 43.1456,
      "radius_km": 50,
      "total_found": 3
    }
  }
}
```

---

## 🎛️ App Settings Endpoints

### 📋 Get All App Settings
**GET** `/app-settings`

Get all mobile app configuration settings grouped by type.

**Response:**
```json
{
  "success": true,
  "data": {
    "app_info": {
      "app_name": "Visit Djibouti",
      "version": "1.0.0",
      "logo_url": "https://domain.com/storage/logo.png"
    },
    "splash_screens": [
      {
        "title": "Découvrez Djibouti",
        "description": "Explorez les merveilles du pays",
        "image_url": "https://domain.com/storage/splash1.jpg"
      }
    ],
    "onboarding": [
      {
        "title": "Points d'Intérêt",
        "description": "Découvrez les lieux emblématiques",
        "icon": "fas fa-map-marker-alt"
      }
    ]
  }
}
```

### 📱 Get Settings by Type
**GET** `/app-settings/type/{type}`

Get settings for a specific type (app_info, splash_screens, onboarding, etc.).

---

## 🚐 Tour Operators Endpoints

### 📋 Get All Tour Operators
**GET** `/tour-operators`

**Query Parameters:**
- `search` - Search in name/description/address/contact info
- `featured` - Show only featured operators (true/false) 
- `latitude` - User latitude for distance-based sorting
- `longitude` - User longitude for distance-based sorting
- `radius` - Search radius in km when using coordinates (default: 50, max: 200)
- `per_page` - Results per page (default: 15, max: 50)
- `page` - Page number

**Headers:**
```
Accept-Language: fr|en|ar (default: fr)
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "slug": "desert-adventures-djibouti", 
      "name": "Desert Adventures Djibouti",
      "description": "Spécialiste des excursions dans le désert et des tours culturels à travers Djibouti",
      "address": "Avenue République, Djibouti Ville",
      "phones": ["+253 21 35 40 50", "+253 77 12 34 56"],
      "emails": ["contact@desertadventures.dj", "info@desertadventures.dj"],
      "website": "https://desertadventures.dj",
      "location": {
        "latitude": 11.5721,
        "longitude": 43.1456,
        "has_coordinates": true
      },
      "logo": {
        "id": 15,
        "url": "/storage/media/tour-operators/logo.png",
        "thumbnail": "/storage/media/tour-operators/logo_thumb.png", 
        "alt_text": "Logo Desert Adventures"
      },
      "gallery_count": 12,
      "is_featured": true,
      "created_at": "2024-08-20T10:30:00.000000Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 15,
    "total": 8,
    "last_page": 1,
    "has_more_pages": false
  },
  "filters_applied": {
    "search": null,
    "featured": true,
    "nearby": false
  },
  "locale": "fr"
}
```

**cURL Example:**
```bash
curl -X GET "http://your-domain.com/api/tour-operators?featured=true&per_page=5" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

### 🗺️ Get Nearby Tour Operators
**GET** `/tour-operators/nearby`

Find tour operators within a specified radius of user's location.

**Query Parameters:**
- `latitude` (required) - User latitude (-90 to 90)
- `longitude` (required) - User longitude (-180 to 180)  
- `radius` - Search radius in km (default: 25, max: 200)
- `limit` - Number of results (default: 10, max: 20)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "slug": "desert-adventures-djibouti",
      "name": "Desert Adventures Djibouti", 
      "description": "Spécialiste des excursions dans le désert",
      "address": "Avenue République, Djibouti",
      "phones": ["+253 21 35 40 50"],
      "emails": ["contact@desertadventures.dj"],
      "website": "https://desertadventures.dj",
      "location": {
        "latitude": 11.5721,
        "longitude": 43.1456,
        "has_coordinates": true
      },
      "logo": {
        "id": 15,
        "url": "/storage/media/tour-operators/logo.png",
        "thumbnail": "/storage/media/tour-operators/logo_thumb.png",
        "alt_text": "Logo Desert Adventures"
      },
      "gallery_count": 12,
      "is_featured": true,
      "created_at": "2024-08-20T10:30:00.000000Z",
      "distance": 2.8,
      "distance_unit": "km"
    }
  ],
  "search_params": {
    "latitude": 11.5721,
    "longitude": 43.1456,
    "radius": 25
  },
  "locale": "fr"
}
```

**cURL Example:**
```bash
curl -X GET "http://your-domain.com/api/tour-operators/nearby?latitude=11.5721&longitude=43.1456&radius=50" \
  -H "Accept: application/json" \
  -H "Accept-Language: fr"
```

### 📄 Get Tour Operator Details
**GET** `/tour-operators/{identifier}`

Get detailed information about a specific tour operator by ID or slug.

**Parameters:**
- `identifier` - Tour operator ID (numeric) or slug (string)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "slug": "desert-adventures-djibouti",
    "name": "Desert Adventures Djibouti",
    "description": "Spécialiste des excursions dans le désert et des tours culturels à travers tout Djibouti. Nous proposons des expériences uniques au Lac Assal, Lac Abbé, et dans le désert du Grand Bara.",
    "address": "Avenue République, Djibouti Ville",
    "contact": {
      "phones": ["+253 21 35 40 50", "+253 77 12 34 56"],
      "emails": ["contact@desertadventures.dj", "info@desertadventures.dj"],
      "website": "https://desertadventures.dj",
      "primary_phone": "+253 21 35 40 50",
      "primary_email": "contact@desertadventures.dj"
    },
    "location": {
      "address": "Avenue République, Djibouti Ville",
      "latitude": 11.5721,
      "longitude": 43.1456,
      "has_coordinates": true
    },
    "logo": {
      "id": 15,
      "url": "/storage/media/tour-operators/logo.png",
      "thumbnail": "/storage/media/tour-operators/logo_thumb.png",
      "alt_text": "Logo Desert Adventures",
      "title": "Desert Adventures - Logo officiel"
    },
    "gallery": [
      {
        "id": 45,
        "url": "/storage/media/tour-operators/gallery1.jpg",
        "thumbnail": "/storage/media/tour-operators/gallery1_thumb.jpg",
        "type": "images",
        "mime_type": "image/jpeg", 
        "size": 2048576,
        "alt_text": "Excursion au Lac Assal",
        "title": "Lac Assal - Point le plus bas d'Afrique",
        "description": "Vue panoramique du célèbre Lac Assal",
        "order": 1
      }
    ],
    "metadata": {
      "is_featured": true,
      "is_active": true,
      "created_at": "2024-08-20T10:30:00.000000Z",
      "updated_at": "2024-08-20T15:45:00.000000Z"
    },
    "translations_available": ["fr", "en", "ar"]
  },
  "locale": "fr"
}
```

**cURL Example:**
```bash
curl -X GET "http://your-domain.com/api/tour-operators/desert-adventures-djibouti" \
  -H "Accept: application/json" \
  -H "Accept-Language: en"
```

---

## 🔮 Future Endpoints (To be implemented)

- `POST /tour-operators/{id}/contact` - Contact tour operator
- `POST /tour-operators/{id}/review` - Add review for tour operator
- `GET /tour-operators/{id}/reviews` - Get reviews for tour operator

---

## 📱 Mobile App Integration Notes

1. **Token Storage**: Store the token securely (Keychain on iOS, Keystore on Android)
2. **Token Refresh**: Tokens don't expire by default, but implement logout on 401 responses
3. **Offline Support**: Cache user profile data for offline access
4. **Language**: Send `Accept-Language` header based on user preference
5. **Push Notifications**: Use FCM tokens for push notifications (to be implemented)