import '../models/poi.dart';
import '../models/event.dart';
import '../models/category.dart';
import 'localization_service.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final LocalizationService _localizationService = LocalizationService();

  /// Traduit le nom d'un POI selon la langue actuelle
  String translatePoiName(Poi poi) {
    final currentLang = _localizationService.currentLanguageCode;
    return _getStaticTranslation(poi.name, currentLang);
  }

  /// Traduit la description d'un POI selon la langue actuelle
  String translatePoiDescription(Poi poi) {
    final currentLang = _localizationService.currentLanguageCode;
    return _getStaticTranslation(poi.shortDescription, currentLang);
  }

  /// Traduit le nom d'un événement selon la langue actuelle
  String translateEventName(Event event) {
    final currentLang = _localizationService.currentLanguageCode;
    return _getStaticTranslation(event.title, currentLang);
  }

  /// Traduit la description d'un événement selon la langue actuelle
  String translateEventDescription(Event event) {
    final currentLang = _localizationService.currentLanguageCode;
    return _getStaticTranslation(event.shortDescription, currentLang);
  }

  /// Traduit le nom d'une catégorie selon la langue actuelle
  String translateCategoryName(Category category) {
    final currentLang = _localizationService.currentLanguageCode;
    return _getCategoryTranslation(category.name, currentLang);
  }

  /// Traduit le nom d'une région selon la langue actuelle
  String translateRegionName(String region) {
    final currentLang = _localizationService.currentLanguageCode;
    return _getRegionTranslation(region, currentLang);
  }

  /// Traductions statiques pour les contenus courants
  String _getStaticTranslation(String text, String languageCode) {
    if (languageCode == 'fr') return text; // Le contenu original est en français
    
    final translations = <String, Map<String, String>>{
      // POIs populaires de Djibouti
      'Lac Assal': {
        'en': 'Assal Lake',
        'ar': 'بحيرة عسل',
      },
      'Lac Abbé': {
        'en': 'Abbe Lake',
        'ar': 'بحيرة عبيه',
      },
      'Forêt du Day': {
        'en': 'Day Forest',
        'ar': 'غابة داي',
      },
      'Tadjourah': {
        'en': 'Tadjourah',
        'ar': 'تاجورة',
      },
      'Obock': {
        'en': 'Obock',
        'ar': 'أوبوك',
      },
      'Arta': {
        'en': 'Arta',
        'ar': 'أرتا',
      },
      'Ali Sabieh': {
        'en': 'Ali Sabieh',
        'ar': 'علي صبيح',
      },
      'Dikhil': {
        'en': 'Dikhil',
        'ar': 'دخيل',
      },
      
      // Descriptions courantes
      'Un magnifique lac salé': {
        'en': 'A magnificent salt lake',
        'ar': 'بحيرة ملحية رائعة',
      },
      'Paysage volcanique unique': {
        'en': 'Unique volcanic landscape',
        'ar': 'منظر طبيعي بركاني فريد',
      },
      'Forêt tropicale préservée': {
        'en': 'Preserved tropical forest',
        'ar': 'غابة استوائية محمية',
      },
      'Ville historique portuaire': {
        'en': 'Historic port city',
        'ar': 'مدينة ميناء تاريخية',
      },
      'Centre culturel et artistique': {
        'en': 'Cultural and artistic center',
        'ar': 'مركز ثقافي وفني',
      },
      'Festival de musique traditionnelle': {
        'en': 'Traditional music festival',
        'ar': 'مهرجان الموسيقى التقليدية',
      },
      'Excursion découverte': {
        'en': 'Discovery excursion',
        'ar': 'رحلة استطلاعية',
      },
      'Visite guidée': {
        'en': 'Guided tour',
        'ar': 'جولة مرشدة',
      },
    };

    // Rechercher une traduction exacte
    if (translations.containsKey(text)) {
      return translations[text]![languageCode] ?? text;
    }

    // Rechercher des mots-clés dans le texte pour traductions partielles
    String translatedText = text;
    translations.forEach((key, value) {
      if (text.contains(key) && value.containsKey(languageCode)) {
        translatedText = translatedText.replaceAll(key, value[languageCode]!);
      }
    });

    return translatedText;
  }

  /// Traductions spécifiques pour les catégories
  String _getCategoryTranslation(String categoryName, String languageCode) {
    if (languageCode == 'fr') return categoryName;

    final categoryTranslations = <String, Map<String, String>>{
      'Sites naturels': {
        'en': 'Natural Sites',
        'ar': 'المواقع الطبيعية',
      },
      'Patrimoine culturel': {
        'en': 'Cultural Heritage',
        'ar': 'التراث الثقافي',
      },
      'Activités sportives': {
        'en': 'Sports Activities',
        'ar': 'الأنشطة الرياضية',
      },
      'Restaurants': {
        'en': 'Restaurants',
        'ar': 'المطاعم',
      },
      'Hébergement': {
        'en': 'Accommodation',
        'ar': 'الإقامة',
      },
      'Shopping': {
        'en': 'Shopping',
        'ar': 'التسوق',
      },
      'Vie nocturne': {
        'en': 'Nightlife',
        'ar': 'الحياة الليلية',
      },
      'Transport': {
        'en': 'Transportation',
        'ar': 'النقل',
      },
      'Services': {
        'en': 'Services',
        'ar': 'الخدمات',
      },
      'Événements': {
        'en': 'Events',
        'ar': 'الأحداث',
      },
    };

    return categoryTranslations[categoryName]?[languageCode] ?? categoryName;
  }

  /// Traductions spécifiques pour les régions
  String _getRegionTranslation(String regionName, String languageCode) {
    if (languageCode == 'fr') return regionName;

    final regionTranslations = <String, Map<String, String>>{
      'Djibouti-Ville': {
        'en': 'Djibouti City',
        'ar': 'مدينة جيبوتي',
      },
      'Région de Tadjourah': {
        'en': 'Tadjourah Region',
        'ar': 'منطقة تاجورة',
      },
      'Région d\'Obock': {
        'en': 'Obock Region',
        'ar': 'منطقة أوبوك',
      },
      'Région d\'Arta': {
        'en': 'Arta Region',
        'ar': 'منطقة أرتا',
      },
      'Région d\'Ali Sabieh': {
        'en': 'Ali Sabieh Region',
        'ar': 'منطقة علي صبيح',
      },
      'Région de Dikhil': {
        'en': 'Dikhil Region',
        'ar': 'منطقة دخيل',
      },
    };

    return regionTranslations[regionName]?[languageCode] ?? regionName;
  }

  /// Crée un POI traduit avec les noms et descriptions dans la langue actuelle
  Poi translatePoi(Poi originalPoi) {
    // Pour créer un POI traduit, nous devons utiliser le constructeur existant
    // et les champs de la classe Poi tels qu'ils sont définis
    return Poi(
      id: originalPoi.id,
      slug: originalPoi.slug,
      name: translatePoiName(originalPoi),
      shortDescription: translatePoiDescription(originalPoi),
      description: originalPoi.description != null ? _getStaticTranslation(originalPoi.description!, _localizationService.currentLanguageCode) : null,
      address: originalPoi.address,
      region: translateRegionName(originalPoi.region),
      fullAddress: originalPoi.fullAddress,
      latitude: originalPoi.latitude,
      longitude: originalPoi.longitude,
      isFeatured: originalPoi.isFeatured,
      allowReservations: originalPoi.allowReservations,
      website: originalPoi.website,
      openingHours: originalPoi.openingHours,
      entryFee: originalPoi.entryFee,
      tips: originalPoi.tips,
      featuredImage: originalPoi.featuredImage,
      media: originalPoi.media,
      categories: originalPoi.categories.map((cat) => Category(
        id: cat.id,
        name: translateCategoryName(cat),
        slug: cat.slug,
        description: cat.description,
        color: cat.color,
        icon: cat.icon,
        parentId: cat.parentId,
        level: cat.level,
        subCategories: cat.subCategories,
      )).toList(),
      contacts: originalPoi.contacts,
      hasContacts: originalPoi.hasContacts,
      contactsCount: originalPoi.contactsCount,
      primaryContact: originalPoi.primaryContact,
      tourOperators: originalPoi.tourOperators,
      hasTourOperators: originalPoi.hasTourOperators,
      tourOperatorsCount: originalPoi.tourOperatorsCount,
      primaryTourOperator: originalPoi.primaryTourOperator,
      favoritesCount: originalPoi.favoritesCount,
      isFavorited: originalPoi.isFavorited,
      createdAt: originalPoi.createdAt,
      updatedAt: originalPoi.updatedAt,
      distance: originalPoi.distance,
    );
  }

  /// Crée un événement traduit avec les noms et descriptions dans la langue actuelle
  Event translateEvent(Event originalEvent) {
    // Pour l'instant, retournons l'événement original car nous devons vérifier les champs exacts du modèle Event
    return originalEvent; // TODO: Implémenter après vérification du modèle Event
  }
}