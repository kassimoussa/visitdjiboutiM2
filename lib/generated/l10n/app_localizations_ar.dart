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
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonShowMore => 'عرض المزيد';

  @override
  String get commonShowLess => 'عرض أقل';

  @override
  String get commonSend => 'إرسال';
}
