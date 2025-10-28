// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'زيارة جيبوتي';

  @override
  String get appDescription => 'اكتشف عجائب جيبوتي';

  @override
  String get navigationHome => 'الرئيسية';

  @override
  String get navigationDiscover => 'اكتشف';

  @override
  String get navigationEvents => 'الفعاليات';

  @override
  String get navigationMap => 'الخريطة';

  @override
  String get navigationFavorites => 'المفضلة';

  @override
  String get homeWelcomeMessage => 'مرحباً بكم في جيبوتي';

  @override
  String get homeFeaturedPois => 'أماكن للاكتشاف';

  @override
  String get homeUpcomingEvents => 'الفعاليات القادمة';

  @override
  String get homeExploreMore => 'استكشف المزيد';

  @override
  String get homeDiscoverByRegion => 'اكتشف حسب المنطقة';

  @override
  String get homeDiscoverByRegionSubtitle => 'انقر للاستكشاف';

  @override
  String get homeEssentials => 'الأساسيات';

  @override
  String get homeDiscover => 'اكتشف';

  @override
  String get discoverTitle => 'اكتشف جيبوتي';

  @override
  String get discoverCategories => 'الفئات';

  @override
  String get discoverAllPois => 'جميع الأماكن';

  @override
  String get discoverSearchHint => 'ابحث عن مكان...';

  @override
  String get discoverNearbyPois => 'الأماكن القريبة';

  @override
  String get discoverNoResults => 'لم يتم العثور على نتائج';

  @override
  String get eventsTitle => 'الفعاليات';

  @override
  String get eventsUpcoming => 'قادمة';

  @override
  String get eventsOngoing => 'جارية';

  @override
  String get eventsPast => 'منتهية';

  @override
  String get eventsRegister => 'سجل';

  @override
  String get eventsRegistered => 'مسجل';

  @override
  String get eventsSoldOut => 'مكتمل';

  @override
  String get eventsEnded => 'منتهية';

  @override
  String get eventsFree => 'مجاني';

  @override
  String eventsPrice(String price) {
    return '$price فرنك جيبوتي';
  }

  @override
  String eventsParticipants(int count) {
    return '$count مشارك';
  }

  @override
  String get favoritesTitle => 'مفضلاتي';

  @override
  String get favoritesEmpty => 'لا توجد مفضلات';

  @override
  String get favoritesEmptyDescription =>
      'استكشف جيبوتي وأضف أماكنك\\nالمفضلة إلى مجموعتك';

  @override
  String get favoritesAddedToFavorites => 'تمت الإضافة إلى المفضلة';

  @override
  String get favoritesRemovedFromFavorites => 'تم الحذف من المفضلة';

  @override
  String get favoritesPoisTab => 'الأماكن';

  @override
  String get favoritesEventsTab => 'الفعاليات';

  @override
  String get favoritesAllTab => 'الكل';

  @override
  String get favoritesSortRecent => 'الأحدث';

  @override
  String get favoritesSortAlphabetical => 'أبجدياً';

  @override
  String get favoritesSortRating => 'التقييم';

  @override
  String get mapTitle => 'الخريطة';

  @override
  String get mapMyLocation => 'موقعي';

  @override
  String get mapSearchLocation => 'ابحث عن موقع...';

  @override
  String get mapRouteTo => 'الطريق إلى';

  @override
  String mapDistance(String distance) {
    return '$distance كم';
  }

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authRegister => 'إنشاء حساب';

  @override
  String get authLogout => 'تسجيل الخروج';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authName => 'الاسم الكامل';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authDontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSignInWithGoogle => 'متابعة مع جوجل';

  @override
  String get authSignInWithFacebook => 'متابعة مع فيسبوك';

  @override
  String get authOrContinueWith => 'أو متابعة مع';

  @override
  String get authTermsAndConditions => 'الشروط والأحكام';

  @override
  String get authPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get authAcceptTerms => 'أوافق على';

  @override
  String get authAcceptTermsAnd => 'و';

  @override
  String get authCreateAccount => 'إنشاء حسابي';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get authResetPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لتلقي رابط إعادة التعيين';

  @override
  String get authSendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get authResetEmailSent => 'تم إرسال بريد إعادة التعيين';

  @override
  String get authResetEmailSentMessage =>
      'تحقق من صندوق البريد الخاص بك لإعادة تعيين كلمة المرور';

  @override
  String get authBackToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileEditProfile => 'تعديل الملف الشخصي';

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profileAboutApp => 'حول التطبيق';

  @override
  String get profileContactSupport => 'الدعم';

  @override
  String get conversionAfterFavoritesTitle => 'احفظ اكتشافاتك!';

  @override
  String get conversionAfterFavoritesDescription =>
      'أنشئ حسابك لمزامنة مفضلاتك عبر جميع أجهزتك';

  @override
  String get conversionAfterFavoritesButton => 'احفظ مفضلاتي';

  @override
  String get conversionBeforeReservationTitle => 'أكمل تسجيلك';

  @override
  String get conversionBeforeReservationDescription =>
      'مطلوب حساب لإنهاء حجز الفعالية';

  @override
  String get conversionBeforeReservationButton => 'إنشاء حساب';

  @override
  String get conversionBeforeExportTitle => 'استلم برنامجك بالبريد الإلكتروني';

  @override
  String get conversionBeforeExportDescription =>
      'أنشئ حسابك لتلقي برنامجك المخصص بالبريد الإلكتروني';

  @override
  String get conversionBeforeExportButton => 'استلم بالبريد الإلكتروني';

  @override
  String get conversionAfterWeekUsageTitle => 'أنشئ ملفك الشخصي للمسافر';

  @override
  String get conversionAfterWeekUsageDescription =>
      'بعد أسبوع من الاستكشاف، أنشئ ملفك الشخصي لتجربة مخصصة';

  @override
  String get conversionAfterWeekUsageButton => 'أنشئ ملفي الشخصي';

  @override
  String get conversionBenefits => 'مع الحساب، يمكنك:';

  @override
  String get conversionBenefitSync => 'مزامنة مفضلاتك عبر جميع أجهزتك';

  @override
  String get conversionBenefitNotifications => 'تلقي إشعارات لأماكنك المفضلة';

  @override
  String get conversionBenefitItineraries => 'إنشاء برامج مخصصة';

  @override
  String get conversionBenefitReservations => 'إدارة جميع حجوزاتك في مكان واحد';

  @override
  String get conversionBenefitHistory => 'الوصول إلى تاريخ حجوزاتك';

  @override
  String get conversionBenefitEmail => 'تلقي برامجك بالبريد الإلكتروني';

  @override
  String get conversionBenefitShare => 'شارك اكتشافاتك مع الأصدقاء';

  @override
  String get conversionBenefitRecommendations => 'احصل على توصيات مخصصة';

  @override
  String get conversionBenefitOffers => 'الوصول إلى عروض حصرية';

  @override
  String get conversionBenefitCommunity => 'انضم إلى مجتمع المسافرين';

  @override
  String get conversionLaterButton => 'لاحقاً';

  @override
  String get conversionContinueWithoutAccount => 'متابعة بدون حساب';

  @override
  String get conversionNotNowButton => 'ليس الآن';

  @override
  String get conversionMaybeLaterButton => 'ربما لاحقاً';

  @override
  String get conversionCancelButton => 'إلغاء';

  @override
  String get drawerGuest => 'ضيف';

  @override
  String get drawerViewProfile => 'عرض ملفي الشخصي ←';

  @override
  String get drawerProfile => 'Profil';

  @override
  String get drawerReservations => 'Mes Réservations';

  @override
  String get drawerReservationsSubtitle => 'Gérer vos réservations';

  @override
  String get drawerOfflineMode => 'Mode hors ligne';

  @override
  String get drawerSettingsSection => 'الإعدادات';

  @override
  String get drawerTestApi => 'اختبار API';

  @override
  String get drawerTestApiSubtitle => 'اختبار النقاط النهائية';

  @override
  String get drawerSettings => 'الإعدادات';

  @override
  String get drawerLanguage => 'اللغة';

  @override
  String get drawerNotifications => 'الإشعارات';

  @override
  String get drawerHelpSection => 'المساعدة والدعم';

  @override
  String get drawerHelp => 'المساعدة';

  @override
  String get drawerFeedback => 'التعليقات';

  @override
  String get drawerAbout => 'حول';

  @override
  String get drawerUsefulLinks => 'روابط مفيدة';

  @override
  String get drawerTourismOffice => 'مكتب السياحة';

  @override
  String get drawerEmbassies => 'السفارات';

  @override
  String get drawerEmergencyNumbers => 'أرقام الطوارئ';

  @override
  String get drawerAnonymousUser => 'Explorateur anonyme';

  @override
  String get drawerCreateAccount => 'Créer compte';

  @override
  String get drawerLogin => 'Connexion';

  @override
  String get drawerConnected => 'Connecté';

  @override
  String get drawerLogoutTitle => 'Déconnexion';

  @override
  String get drawerLogoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ? Vous redeviendrez un utilisateur anonyme.';

  @override
  String get drawerLogoutSuccess => 'Déconnexion réussie';

  @override
  String get drawerVersion => 'الإصدار 1.0.0';

  @override
  String get drawerChooseLanguage => 'اختر اللغة';

  @override
  String drawerLanguageChanged(String language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get drawerSendFeedback => 'إرسال تعليق';

  @override
  String get drawerFeedbackHint => 'شارك تجربتك مع زيارة جيبوتي...';

  @override
  String get drawerFeedbackThanks => 'شكراً لك على تعليقك!';

  @override
  String get drawerPolice => '🚨 الشرطة: 17';

  @override
  String get drawerFire => '🚒 الإطفاء: 18';

  @override
  String get drawerSamu => '🏥 الإسعاف: 351351';

  @override
  String get drawerMedical => '🚑 الطوارئ الطبية: 35 35 35';

  @override
  String get drawerInfo => '📞 الاستعلامات: 12';

  @override
  String get drawerTourismOfficeSnackbar => 'فتح موقع مكتب السياحة';

  @override
  String get commonLoading => 'جارٍ التحميل...';

  @override
  String get commonError => 'خطأ';

  @override
  String get commonErrorUnknown => 'Erreur inconnue';

  @override
  String get commonErrorSync => 'Erreur de synchronisation';

  @override
  String get commonErrorDownload => 'Erreur de téléchargement';

  @override
  String get commonErrorCache => 'Erreur lors du vidage du cache';

  @override
  String get commonErrorFavorites =>
      'Erreur lors de la modification des favoris';

  @override
  String get commonErrorLoading => 'Erreur lors du chargement';

  @override
  String get commonErrorUnexpected => 'Une erreur inattendue s\'est produite';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonPrevious => 'السابق';

  @override
  String get commonDone => 'تم';

  @override
  String get commonSkip => 'تخطي';

  @override
  String get commonAll => 'الكل';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonShowMore => 'عرض المزيد';

  @override
  String get commonShowLess => 'عرض أقل';

  @override
  String get commonSend => 'إرسال';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsPreferredRegion => 'Région préférée';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsDarkModeSubtitle =>
      'Interface sombre pour économiser la batterie';

  @override
  String get settingsDarkModeActivated => 'Mode sombre activé';

  @override
  String get settingsDarkModeDeactivated => 'Mode sombre désactivé';

  @override
  String get settingsPushNotifications => 'Notifications push';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Recevoir les alertes sur les nouveaux événements';

  @override
  String get settingsEventReminders => 'Rappels d\'événements';

  @override
  String get settingsEventRemindersSubtitle =>
      'Notifications avant vos événements réservés';

  @override
  String get settingsNewPois => 'Nouveaux POIs';

  @override
  String get settingsNewPoisSubtitle =>
      'Être informé des nouveaux lieux découverts';

  @override
  String get settingsLocation => 'Localisation';

  @override
  String get settingsLocationServices => 'Services de localisation';

  @override
  String get settingsLocationServicesSubtitle =>
      'Permettre la géolocalisation pour les POIs proches';

  @override
  String get settingsDefaultZoom => 'Niveau de zoom par défaut';

  @override
  String get settingsDefaultZoomSubtitle => 'Zoom initial sur la carte';

  @override
  String get settingsDataStorage => 'Données & Stockage';

  @override
  String get settingsOfflineModeSubtitle =>
      'Gérer les téléchargements et la synchronisation';

  @override
  String get settingsManageCache => 'Gérer le cache';

  @override
  String settingsImageCache(String size) {
    return 'Cache des images: $size';
  }

  @override
  String get settingsOfflineMaps => 'Cartes hors ligne';

  @override
  String get settingsOfflineMapsSubtitle =>
      'Télécharger les cartes de Djibouti';

  @override
  String get settingsSecurityPrivacy => 'Sécurité & Confidentialité';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsPrivacySubtitle => 'Gérer vos données personnelles';

  @override
  String get settingsTermsSubtitle => 'Lire les conditions d\'utilisation';

  @override
  String get settingsActions => 'Actions';

  @override
  String get settingsBackupData => 'Sauvegarder mes données';

  @override
  String get settingsBackupDataSubtitle =>
      'Favoris, réservations et préférences';

  @override
  String get settingsResetSettings => 'Restaurer paramètres par défaut';

  @override
  String get settingsResetSettingsSubtitle =>
      'Remettre tous les paramètres à zéro';

  @override
  String get settingsAllowGeolocation => 'Autoriser la géolocalisation';

  @override
  String get settingsGeolocationRequest =>
      'Visit Djibouti souhaite accéder à votre position pour vous montrer les points d\'intérêt proches de vous.';

  @override
  String get settingsAllow => 'Autoriser';

  @override
  String get settingsGeolocationEnabled => 'Géolocalisation activée';

  @override
  String get settingsClearCache => 'Vider le cache';

  @override
  String get settingsCacheClearedSuccess => 'Cache vidé avec succès';

  @override
  String settingsErrorClearing(String error) {
    return 'Erreur lors du vidage: $error';
  }

  @override
  String get settingsClear => 'Vider';

  @override
  String get eventsSearchHint => 'Rechercher un événement...';

  @override
  String get eventsAll => 'Tous';

  @override
  String get eventsNoEventsFound => 'Aucun événement trouvé';

  @override
  String get eventsClearFilters => 'Effacer les filtres';

  @override
  String get eventsPopular => 'Populaire';

  @override
  String eventsRemovedFromFavorites(String title) {
    return '$title retiré des favoris';
  }

  @override
  String eventsAddedToFavorites(String title) {
    return '$title ajouté aux favoris';
  }

  @override
  String get homeShufflePois => 'Mélanger les POIs';

  @override
  String get homeNoFeaturedPois => 'Aucun POI en vedette disponible';

  @override
  String get homeNoUpcomingEvents => 'Aucun événement à venir';

  @override
  String get homeTourOperators => 'Opérateurs Touristiques';

  @override
  String get homeTourOperatorsSubtitle =>
      'Planifiez votre aventure avec des experts';

  @override
  String get homeEssentialInfo => 'Infos Essentielles';

  @override
  String get homeEssentialInfoSubtitle => 'Organisation et liens utiles';

  @override
  String get homeEmbassies => 'Ambassades';

  @override
  String get homeEmbassiesSubtitle =>
      'Représentations diplomatiques à Djibouti et à l\'étranger';

  @override
  String mapErrorLoadingPois(String message) {
    return 'Erreur lors du chargement des POIs: $message';
  }

  @override
  String mapError(String error) {
    return 'Erreur: $error';
  }

  @override
  String get mapUnknownPlace => 'Lieu inconnu';

  @override
  String get authWelcomeBack => 'Bon retour !';

  @override
  String get authSignInSubtitle =>
      'Connectez-vous à votre compte Visit Djibouti';

  @override
  String get authOr => 'ou';

  @override
  String get authSuccessTitle => 'نجح تسجيل الدخول!';

  @override
  String get authErrorTitle => 'خطأ';

  @override
  String get authSignUpSuccessTitle => 'نجح التسجيل';

  @override
  String get authConversionProblemTitle => 'مشكلة في التحويل';

  @override
  String get authKeepDiscoveries => 'أنشئ حسابك في زيارة جيبوتي';

  @override
  String get authWelcomeToApp => 'أنشئ حسابك في زيارة جيبوتي';

  @override
  String get authCreateAccountDescription =>
      'اكتشف كل ما تقدمه جيبوتي من خلال حسابك الشخصي';

  @override
  String get authDataPreserved => 'ستبقى بياناتك الحالية محفوظة';

  @override
  String get authKeepingDataInfo => '✨ بإنشاء حسابك، ستحتفظ بـ:';

  @override
  String get authCurrentFavorites => 'جميع مفضلاتك الحالية';

  @override
  String get authPreferences => 'إعداداتك';

  @override
  String get authBrowsingHistory => 'سجل تصفحك';

  @override
  String get authDiscoveredPlaces => 'أماكنك المكتشفة';

  @override
  String get aboutPageDescription =>
      'زيارة جيبوتي هو التطبيق الرسمي للسياحة الجيبوتية. اكتشف المواقع الاستثنائية والفعاليات الثقافية والتجارب الفريدة التي يقدمها بلدنا. من المناظر البركانية إلى قيعان البحر البكر، مروراً بتراثنا الثقافي الغني، استكشف جيبوتي كما لم تفعل من قبل.';

  @override
  String get aboutPointsOfInterest => 'نقاط الاهتمام';

  @override
  String get aboutEvents => 'الفعاليات';

  @override
  String get aboutTourismOffice => 'مكتب السياحة الجيبوتي';

  @override
  String get aboutTourismOfficeSubtitle => 'منظمة الترويج السياحي الرسمية';

  @override
  String get aboutMinistry => 'وزارة التجارة والسياحة';

  @override
  String get aboutMinistrySubtitle => 'جمهورية جيبوتي';

  @override
  String get aboutHotelsAssociation => 'جمعية الفنادق';

  @override
  String get aboutHotelsAssociationSubtitle => 'القطاع السياحي الخاص';

  @override
  String get helpHowCanWeHelp => 'كيف يمكننا مساعدتك؟';

  @override
  String get helpSearchPlaceholder => 'البحث في المساعدة...';

  @override
  String get helpContactUs => 'اتصل بنا';

  @override
  String get helpLiveChat => 'دردشة مباشرة';

  @override
  String get helpConnectingToChat => 'الاتصال بالدردشة...';

  @override
  String get helpStartChat => 'بدء الدردشة';

  @override
  String get helpSubject => 'الموضوع';

  @override
  String get helpMessage => 'رسالتك';

  @override
  String get helpEmailOptional => 'بريدك الإلكتروني (اختياري)';

  @override
  String get helpProblemTitle => 'عنوان المشكلة';

  @override
  String get helpMessageSentSuccess => 'تم إرسال الرسالة بنجاح!';

  @override
  String get helpHowToUseMap => 'كيفية استخدام الخريطة';

  @override
  String get helpBookEvent => 'حجز فعالية';

  @override
  String get helpManageFavorites => 'إدارة المفضلات';

  @override
  String get helpDescribeProblem => 'صف المشكلة التي واجهتها...';

  @override
  String get helpDuration3Min => '3 دقائق';

  @override
  String get helpDuration2Min => 'دقيقتان';

  @override
  String get helpDuration1Min => 'دقيقة واحدة';

  @override
  String get embassiesTitle => 'السفارات';

  @override
  String get embassiesCall => 'اتصال';

  @override
  String get embassiesEmail => 'بريد إلكتروني';

  @override
  String get embassiesWebsite => 'الموقع الإلكتروني';

  @override
  String get embassiesCannotOpenPhone => 'لا يمكن فتح تطبيق الهاتف';

  @override
  String get embassiesCannotOpenEmail => 'لا يمكن فتح تطبيق البريد الإلكتروني';

  @override
  String get embassiesCannotOpenWebsite => 'لا يمكن فتح الموقع الإلكتروني';

  @override
  String get embassiesNoForeignFound => 'لم يتم العثور على سفارة أجنبية';

  @override
  String get embassiesNoForeignSubtitle => 'معلومات السفارات ليست متاحة بعد';

  @override
  String get embassiesNoDjiboutianFound => 'لم يتم العثور على سفارة جيبوتية';

  @override
  String get embassiesNoDjiboutianSubtitle =>
      'معلومات السفارات الجيبوتية ليست متاحة بعد';

  @override
  String get essentialsTitle => 'المعلومات الأساسية';

  @override
  String get essentialsUnavailableInfo => 'المعلومات غير متوفرة';

  @override
  String get essentialsNoLinksAvailable => 'لا توجد روابط متاحة';

  @override
  String get eventDetailErrorLoading => 'خطأ في تحميل التفاصيل';

  @override
  String get eventDetailRegistrationConfirmed => 'تأكيد التسجيل!';

  @override
  String eventDetailReservationNumber(String number) {
    return 'رقم الحجز: $number';
  }

  @override
  String eventDetailSpecialRequirements(String requirements) {
    return 'المتطلبات الخاصة';
  }

  @override
  String get eventDetailParticipantsLabel => 'مشاركين';

  @override
  String get eventDetailFullNameLabel => 'الاسم الكامل';

  @override
  String get eventDetailEmailLabel => 'البريد الإلكتروني';

  @override
  String get eventDetailPhoneLabel => 'الهاتف';

  @override
  String get eventDetailSpecialRequirementsLabel =>
      'المتطلبات الخاصة (اختياري)';

  @override
  String get eventDetailSpecialRequirementsHint =>
      'الحساسيات، احتياجات إمكانية الوصول، إلخ.';

  @override
  String get commonOk => 'موافق';

  @override
  String get commonConnectionError => 'خطأ في الاتصال';

  @override
  String get commonNoNavigationApp => 'لم يتم العثور على تطبيق ملاحة';

  @override
  String get commonUnknownPlace => 'مكان غير معروف';

  @override
  String get commonUnknown => 'غير معروف';

  @override
  String get commonDescription => 'الوصف';

  @override
  String get commonOverview => 'نظرة عامة';

  @override
  String get commonDiscoverPlace => 'اكتشف هذا المكان الفريد في';

  @override
  String get commonExploreOnSite => 'استكشف ميزاته من خلال الزيارة شخصياً.';

  @override
  String get commonLocation => 'الموقع';

  @override
  String get commonAddress => 'العنوان';

  @override
  String get commonCoordinates => 'Coordonnées';

  @override
  String get commonPracticalInfo => 'معلومات عملية';

  @override
  String get commonOpeningHours => 'ساعات العمل';

  @override
  String get commonEntryPrice => 'سعر الدخول';

  @override
  String get commonWebsite => 'الموقع الإلكتروني';

  @override
  String get commonReservationsAccepted => 'يتم قبول الحجوزات';

  @override
  String get commonCategories => 'الفئات';

  @override
  String get commonCategory => 'فئة';

  @override
  String get commonVisitorTips => 'نصائح للزائرين';

  @override
  String get commonContact => 'اتصال';

  @override
  String get commonReservePlace => 'احجز هذا المكان';

  @override
  String get commonSharePlace => 'شارك هذا المكان';

  @override
  String get commonSharedFrom => 'مشارك من Visit Djibouti';

  @override
  String get commonCopiedToClipboard => 'تم نسخ المعلومات إلى الحافظة!';

  @override
  String get commonPhone => 'الهاتف';

  @override
  String get commonEmail => 'البريد الإلكتروني';

  @override
  String get commonCopy => 'نسخ';

  @override
  String get commonEvent => 'حدث';

  @override
  String get commonUnknownEvent => 'حدث غير معروف';

  @override
  String get commonInformations => 'المعلومات';

  @override
  String get commonDate => 'التاريخ';

  @override
  String get commonFieldRequired => 'هذا الحقل مطلوب';

  @override
  String get eventDetailRegistrationNumber => 'رقم التسجيل';

  @override
  String get eventDetailParticipants => 'المشاركين';

  @override
  String get eventDetailEventEnded => 'انتهى هذا الحدث';

  @override
  String get eventDetailEventFull => 'الحدث مكتمل';

  @override
  String get eventDetailSpotsRemaining => 'أماكن متبقية';

  @override
  String get eventDetailReserveEvent => 'احجز لهذا الحدث';

  @override
  String get eventDetailReservationsClosed => 'الحجوزات مغلقة';

  @override
  String get eventDetailDetailsUnavailable => 'قد تكون بعض التفاصيل غير متاحة';

  @override
  String get eventDetailPopular => 'شائع';

  @override
  String get eventDetailFree => 'مجاني';

  @override
  String get eventDetailEndDate => 'تاريخ الانتهاء';

  @override
  String get eventDetailVenue => 'المكان';

  @override
  String get eventDetailPrice => 'السعر';

  @override
  String get eventDetailRegistration => 'التسجيل';

  @override
  String get eventDetailParticipantsCount => 'عدد المشاركين';

  @override
  String get eventDetailInvalidNumber => 'رقم غير صحيح';

  @override
  String get eventDetailMaxParticipants => 'الحد الأقصى';

  @override
  String get eventDetailContactInfo => 'معلومات الاتصال';

  @override
  String get eventDetailFullName => 'الاسم الكامل';

  @override
  String get eventDetailSpecialRequirementsOptional =>
      'المتطلبات الخاصة (اختياري)';

  @override
  String get eventDetailInvalidEmail => 'بريد إلكتروني غير صحيح';

  @override
  String get eventDetailTotalToPay => 'المجموع المطلوب دفعه';

  @override
  String get eventDetailConfirmRegistration => 'تأكيد التسجيل';

  @override
  String reservationsAll(int count) {
    return 'الكل ($count)';
  }

  @override
  String reservationsConfirmed(int count) {
    return 'مؤكدة ($count)';
  }

  @override
  String reservationsPending(int count) {
    return 'قيد الانتظار ($count)';
  }

  @override
  String reservationsCancelled(int count) {
    return 'ملغاة ($count)';
  }

  @override
  String get reservationsNoneAll => 'لا توجد حجوزات';

  @override
  String get reservationsNoneConfirmed => 'لا توجد حجوزات مؤكدة';

  @override
  String get reservationsNonePending => 'لا توجد حجوزات قيد الانتظار';

  @override
  String get reservationsNoneCancelled => 'لا توجد حجوزات ملغاة';

  @override
  String get reservationsCancelTitle => 'إلغاء الحجز';

  @override
  String get reservationsDeleteTitle => 'حذف الحجز';

  @override
  String get tourOperatorsNoneFound => 'لم يتم العثور على منظمي رحلات';

  @override
  String get offlineLoadingSettings => 'تحميل الإعدادات...';

  @override
  String get offlineConnectionStatus => 'حالة الاتصال';

  @override
  String get offlineClearCacheTitle => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get profileUser => 'مستخدم';

  @override
  String get profileLogoutTitle => 'تسجيل الخروج';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileEditTooltip => 'تعديل';

  @override
  String get profileSecurity => 'الأمان';

  @override
  String get apiTestTitle => 'اختبار API للمواقع';

  @override
  String get discoverClearFilters => 'مسح المرشحات';

  @override
  String get mapSearchHint => 'البحث في الخريطة...';

  @override
  String get categoryFilterClear => 'مسح';

  @override
  String get offlineIndicatorConnectionRestored => 'تم استعادة الاتصال!';

  @override
  String get offlineIndicatorOfflineMode => 'وضع عدم الاتصال';

  @override
  String get offlineIndicatorOfflineModeTitle => 'وضع عدم الاتصال';

  @override
  String get reservationFormDateLabel => 'التاريخ *';

  @override
  String get reservationFormDatePlaceholder => 'اختر تاريخاً';

  @override
  String get reservationFormTimeLabel => 'الوقت';

  @override
  String get reservationFormTimePlaceholder => 'ساعة:دقيقة';

  @override
  String get reservationFormParticipantsLabel => 'عدد الأشخاص *';

  @override
  String get reservationFormParticipantsPlaceholder => '1';

  @override
  String get reservationFormNotesLabel => 'ملاحظات أو طلبات خاصة';

  @override
  String get reservationFormNotesPlaceholder =>
      'حساسية الطعام، احتياجات خاصة...';

  @override
  String get reservationFormPleaseSelectDate => 'يرجى اختيار تاريخ';

  @override
  String reservationFormUnexpectedError(String error) {
    return 'خطأ غير متوقع: $error';
  }

  @override
  String tourOperatorDetailsSnackbar(String name) {
    return 'تفاصيل $name';
  }

  @override
  String get tourOperatorCallButton => 'اتصال';

  @override
  String get tourOperatorWebsiteButton => 'الموقع الإلكتروني';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get eventDetailRegistrationError => 'خطأ في التسجيل';

  @override
  String get commonUnexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get operatorFeatured => 'مميز';

  @override
  String get operatorLabel => 'منظم الرحلات السياحية';

  @override
  String get operatorAddress => 'العنوان';

  @override
  String get operatorDescription => 'الوصف';

  @override
  String get operatorContact => 'جهة الاتصال';

  @override
  String get operatorPhone => 'الهاتف';

  @override
  String get operatorEmail => 'البريد الإلكتروني';

  @override
  String get operatorWebsite => 'الموقع الإلكتروني';

  @override
  String get operatorCall => 'اتصل';

  @override
  String get operatorTours => 'الجولات المعروضة';

  @override
  String get operatorSeeAll => 'عرض الكل';

  @override
  String get operatorNoTours => 'لا توجد جولات متاحة';

  @override
  String get operatorNoToursMessage => 'لم ينشر هذا المنظم أي جولات بعد.';

  @override
  String get operatorPoisServed => 'الأماكن المخدومة';

  @override
  String get operatorNoPois => 'لا توجد أماكن مخدومة';

  @override
  String get operatorNoPoisMessage =>
      'هذا المشغل لا يخدم أي مكان في الوقت الحالي';

  @override
  String get operatorTourAddedToFavorites => 'تمت إضافة الجولة إلى المفضلة';

  @override
  String get operatorTourRemovedFromFavorites => 'تمت إزالة الجولة من المفضلة';

  @override
  String get operatorPoiAddedToFavorites => 'تمت إضافة المكان إلى المفضلة';

  @override
  String get operatorPoiRemovedFromFavorites => 'تمت إزالة المكان من المفضلة';

  @override
  String get operatorViews => 'مشاهدات';

  @override
  String get operatorPlace => 'مكان';

  @override
  String get homeFeaturedTours => 'Tours guidés';

  @override
  String get homeNoFeaturedTours => 'Aucun tour guidé disponible';

  @override
  String get tourFeatured => 'À la une';

  @override
  String tourMaxParticipants(int count) {
    return '$count places max';
  }

  @override
  String get tourDescription => 'الوصف';

  @override
  String get tourItinerary => 'خط الرحلة';

  @override
  String get tourHighlights => 'النقاط البارزة';

  @override
  String get tourWhatToBring => 'ما يجب إحضاره';

  @override
  String get tourPhotoGallery => 'معرض الصور';

  @override
  String get tourRetry => 'إعادة المحاولة';

  @override
  String get tourViewOnMap => 'عرض على الخريطة';

  @override
  String get tourCall => 'اتصل';

  @override
  String get tourEmail => 'البريد الإلكتروني';

  @override
  String poiCannotCall(String phone) {
    return 'لا يمكن الاتصال بـ $phone';
  }

  @override
  String poiCallError(String error) {
    return 'خطأ في الاتصال: $error';
  }

  @override
  String get poiCannotOpenEmail => 'لا يمكن فتح البريد الإلكتروني';

  @override
  String poiEmailError(String error) {
    return 'خطأ في فتح البريد الإلكتروني: $error';
  }

  @override
  String get profileAnonymousExplorer => 'مستكشف مجهول';

  @override
  String get profileDiscoverDjibouti => 'اكتشف جيبوتي بدون قيود';

  @override
  String get profileKeepDiscoveries => 'احتفظ باكتشافاتك!';

  @override
  String get profileCreateAccountBenefits =>
      'أنشئ حسابك لحفظ المفضلات والوصول إلى ميزات حصرية.';

  @override
  String get profileFavorites => 'المفضلات';

  @override
  String get profileEvents => 'الأحداث';

  @override
  String get profileDiscoveries => 'الاكتشافات';

  @override
  String get profileTimeSpent => 'الوقت المستغرق';

  @override
  String get profilePersonalInfoSubtitle => 'إدارة بيانات ملفك الشخصي';

  @override
  String get profileSecuritySubtitle => 'كلمة المرور والمصادقة';

  @override
  String get profileNotificationsSubtitle => 'تفضيلات الإشعارات';

  @override
  String get profileLogoutSubtitle => 'تسجيل الخروج من الحساب';

  @override
  String get profileLogoutConfirm =>
      'هل أنت متأكد أنك تريد تسجيل الخروج؟ ستصبح مستخدمًا مجهولاً مرة أخرى.';

  @override
  String get profileSettingsSubtitle => 'التفضيلات العامة';

  @override
  String get profileHelp => 'المساعدة';

  @override
  String get profileHelpSubtitle => 'الدعم والأسئلة الشائعة';

  @override
  String get profileComingSoon => 'قريبًا!';

  @override
  String get profileComingSoonMessage => 'نحن نعمل بجد لنقدم لك هذه الميزة.';

  @override
  String profileLanguageChanged(String language) {
    return 'تم تغيير اللغة إلى $language';
  }
}
