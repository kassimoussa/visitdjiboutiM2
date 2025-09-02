import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// Titre de l'application
  ///
  /// In fr, this message translates to:
  /// **'Visit Djibouti'**
  String get appTitle;

  /// Description de l'application
  ///
  /// In fr, this message translates to:
  /// **'Découvrez les merveilles de Djibouti'**
  String get appDescription;

  /// No description provided for @navigationHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navigationHome;

  /// No description provided for @navigationDiscover.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get navigationDiscover;

  /// No description provided for @navigationEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get navigationEvents;

  /// No description provided for @navigationMap.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get navigationMap;

  /// No description provided for @navigationFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get navigationFavorites;

  /// No description provided for @homeWelcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue à Djibouti'**
  String get homeWelcomeMessage;

  /// No description provided for @homeFeaturedPois.
  ///
  /// In fr, this message translates to:
  /// **'Lieux à découvrir'**
  String get homeFeaturedPois;

  /// No description provided for @homeUpcomingEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements à venir'**
  String get homeUpcomingEvents;

  /// No description provided for @homeExploreMore.
  ///
  /// In fr, this message translates to:
  /// **'Explorer plus'**
  String get homeExploreMore;

  /// No description provided for @discoverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir Djibouti'**
  String get discoverTitle;

  /// No description provided for @discoverCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get discoverCategories;

  /// No description provided for @discoverAllPois.
  ///
  /// In fr, this message translates to:
  /// **'Tous les lieux'**
  String get discoverAllPois;

  /// No description provided for @discoverSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un lieu...'**
  String get discoverSearchHint;

  /// No description provided for @discoverNearbyPois.
  ///
  /// In fr, this message translates to:
  /// **'Lieux à proximité'**
  String get discoverNearbyPois;

  /// No description provided for @discoverNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé'**
  String get discoverNoResults;

  /// No description provided for @eventsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get eventsTitle;

  /// No description provided for @eventsUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get eventsUpcoming;

  /// No description provided for @eventsOngoing.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get eventsOngoing;

  /// No description provided for @eventsPast.
  ///
  /// In fr, this message translates to:
  /// **'Terminés'**
  String get eventsPast;

  /// No description provided for @eventsRegister.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get eventsRegister;

  /// No description provided for @eventsRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Inscrit'**
  String get eventsRegistered;

  /// No description provided for @eventsSoldOut.
  ///
  /// In fr, this message translates to:
  /// **'Complet'**
  String get eventsSoldOut;

  /// No description provided for @eventsFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get eventsFree;

  /// No description provided for @eventsPrice.
  ///
  /// In fr, this message translates to:
  /// **'{price} DJF'**
  String eventsPrice(String price);

  /// No description provided for @eventsParticipants.
  ///
  /// In fr, this message translates to:
  /// **'{count} participants'**
  String eventsParticipants(int count);

  /// No description provided for @favoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes Favoris'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Explorez Djibouti et ajoutez vos lieux\\npréférés à votre collection'**
  String get favoritesEmptyDescription;

  /// No description provided for @favoritesAddedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté aux favoris'**
  String get favoritesAddedToFavorites;

  /// No description provided for @favoritesRemovedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Supprimé des favoris'**
  String get favoritesRemovedFromFavorites;

  /// No description provided for @favoritesPoisTab.
  ///
  /// In fr, this message translates to:
  /// **'Lieux'**
  String get favoritesPoisTab;

  /// No description provided for @favoritesEventsTab.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get favoritesEventsTab;

  /// No description provided for @favoritesAllTab.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get favoritesAllTab;

  /// No description provided for @favoritesSortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Récent'**
  String get favoritesSortRecent;

  /// No description provided for @favoritesSortAlphabetical.
  ///
  /// In fr, this message translates to:
  /// **'Alphabétique'**
  String get favoritesSortAlphabetical;

  /// No description provided for @favoritesSortRating.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get favoritesSortRating;

  /// No description provided for @mapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get mapTitle;

  /// No description provided for @mapMyLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get mapMyLocation;

  /// No description provided for @mapSearchLocation.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un lieu...'**
  String get mapSearchLocation;

  /// No description provided for @mapRouteTo.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire vers'**
  String get mapRouteTo;

  /// No description provided for @mapDistance.
  ///
  /// In fr, this message translates to:
  /// **'{distance} km'**
  String mapDistance(String distance);

  /// No description provided for @authLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get authRegister;

  /// No description provided for @authLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get authLogout;

  /// No description provided for @authEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get authConfirmPassword;

  /// No description provided for @authName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get authName;

  /// No description provided for @authForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgotPassword;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ?'**
  String get authDontHaveAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get authSignInWithGoogle;

  /// No description provided for @authSignInWithFacebook.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Facebook'**
  String get authSignInWithFacebook;

  /// No description provided for @authOrContinueWith.
  ///
  /// In fr, this message translates to:
  /// **'Ou continuer avec'**
  String get authOrContinueWith;

  /// No description provided for @authTermsAndConditions.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get authTermsAndConditions;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get authPrivacyPolicy;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEditProfile;

  /// No description provided for @profileSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get profileSettings;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// No description provided for @profileNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileAboutApp.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get profileAboutApp;

  /// No description provided for @profileContactSupport.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get profileContactSupport;

  /// No description provided for @conversionAfterFavoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardez vos découvertes !'**
  String get conversionAfterFavoritesTitle;

  /// No description provided for @conversionAfterFavoritesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte pour synchroniser vos favoris sur tous vos appareils'**
  String get conversionAfterFavoritesDescription;

  /// No description provided for @conversionAfterFavoritesButton.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder mes favoris'**
  String get conversionAfterFavoritesButton;

  /// No description provided for @conversionBeforeReservationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Finalisez votre inscription'**
  String get conversionBeforeReservationTitle;

  /// No description provided for @conversionBeforeReservationDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un compte est requis pour finaliser votre réservation d\'événement'**
  String get conversionBeforeReservationDescription;

  /// No description provided for @conversionBeforeReservationButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get conversionBeforeReservationButton;

  /// No description provided for @conversionBeforeExportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recevez votre itinéraire par email'**
  String get conversionBeforeExportTitle;

  /// No description provided for @conversionBeforeExportDescription.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte pour recevoir votre itinéraire personnalisé par email'**
  String get conversionBeforeExportDescription;

  /// No description provided for @conversionBeforeExportButton.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir par email'**
  String get conversionBeforeExportButton;

  /// No description provided for @conversionAfterWeekUsageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre profil voyageur'**
  String get conversionAfterWeekUsageTitle;

  /// No description provided for @conversionAfterWeekUsageDescription.
  ///
  /// In fr, this message translates to:
  /// **'Après une semaine d\'exploration, créez votre profil pour une expérience personnalisée'**
  String get conversionAfterWeekUsageDescription;

  /// No description provided for @conversionAfterWeekUsageButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon profil'**
  String get conversionAfterWeekUsageButton;

  /// No description provided for @conversionBenefits.
  ///
  /// In fr, this message translates to:
  /// **'Avec un compte, vous pourrez :'**
  String get conversionBenefits;

  /// No description provided for @conversionBenefitSync.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser vos favoris sur tous vos appareils'**
  String get conversionBenefitSync;

  /// No description provided for @conversionBenefitNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir des notifications pour vos lieux préférés'**
  String get conversionBenefitNotifications;

  /// No description provided for @conversionBenefitItineraries.
  ///
  /// In fr, this message translates to:
  /// **'Créer des itinéraires personnalisés'**
  String get conversionBenefitItineraries;

  /// No description provided for @conversionBenefitReservations.
  ///
  /// In fr, this message translates to:
  /// **'Gérer toutes vos réservations en un endroit'**
  String get conversionBenefitReservations;

  /// No description provided for @conversionBenefitHistory.
  ///
  /// In fr, this message translates to:
  /// **'Accéder à votre historique de réservations'**
  String get conversionBenefitHistory;

  /// No description provided for @conversionBenefitEmail.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir vos itinéraires par email'**
  String get conversionBenefitEmail;

  /// No description provided for @conversionBenefitShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager vos découvertes avec vos amis'**
  String get conversionBenefitShare;

  /// No description provided for @conversionBenefitRecommendations.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir des recommandations personnalisées'**
  String get conversionBenefitRecommendations;

  /// No description provided for @conversionBenefitOffers.
  ///
  /// In fr, this message translates to:
  /// **'Accéder à des offres exclusives'**
  String get conversionBenefitOffers;

  /// No description provided for @conversionBenefitCommunity.
  ///
  /// In fr, this message translates to:
  /// **'Participer à la communauté de voyageurs'**
  String get conversionBenefitCommunity;

  /// No description provided for @conversionLaterButton.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get conversionLaterButton;

  /// No description provided for @conversionContinueWithoutAccount.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans compte'**
  String get conversionContinueWithoutAccount;

  /// No description provided for @conversionNotNowButton.
  ///
  /// In fr, this message translates to:
  /// **'Pas maintenant'**
  String get conversionNotNowButton;

  /// No description provided for @conversionMaybeLaterButton.
  ///
  /// In fr, this message translates to:
  /// **'Peut-être plus tard'**
  String get conversionMaybeLaterButton;

  /// No description provided for @conversionCancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get conversionCancelButton;

  /// No description provided for @drawerGuest.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get drawerGuest;

  /// No description provided for @drawerViewProfile.
  ///
  /// In fr, this message translates to:
  /// **'Voir mon profil →'**
  String get drawerViewProfile;

  /// No description provided for @drawerProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get drawerProfile;

  /// No description provided for @drawerReservations.
  ///
  /// In fr, this message translates to:
  /// **'Mes Réservations'**
  String get drawerReservations;

  /// No description provided for @drawerReservationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos réservations'**
  String get drawerReservationsSubtitle;

  /// No description provided for @drawerOfflineMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get drawerOfflineMode;

  /// No description provided for @drawerSettingsSection.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get drawerSettingsSection;

  /// No description provided for @drawerTestApi.
  ///
  /// In fr, this message translates to:
  /// **'Test API'**
  String get drawerTestApi;

  /// No description provided for @drawerTestApiSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Test des endpoints'**
  String get drawerTestApiSubtitle;

  /// No description provided for @drawerSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get drawerSettings;

  /// No description provided for @drawerLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get drawerLanguage;

  /// No description provided for @drawerNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get drawerNotifications;

  /// No description provided for @drawerHelpSection.
  ///
  /// In fr, this message translates to:
  /// **'Aide & Support'**
  String get drawerHelpSection;

  /// No description provided for @drawerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get drawerHelp;

  /// No description provided for @drawerFeedback.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get drawerFeedback;

  /// No description provided for @drawerAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get drawerAbout;

  /// No description provided for @drawerUsefulLinks.
  ///
  /// In fr, this message translates to:
  /// **'Liens utiles'**
  String get drawerUsefulLinks;

  /// No description provided for @drawerTourismOffice.
  ///
  /// In fr, this message translates to:
  /// **'Office du Tourisme'**
  String get drawerTourismOffice;

  /// No description provided for @drawerEmbassies.
  ///
  /// In fr, this message translates to:
  /// **'Ambassades'**
  String get drawerEmbassies;

  /// No description provided for @drawerEmergencyNumbers.
  ///
  /// In fr, this message translates to:
  /// **'Numéros d\'urgence'**
  String get drawerEmergencyNumbers;

  /// No description provided for @drawerAnonymousUser.
  ///
  /// In fr, this message translates to:
  /// **'Explorateur anonyme'**
  String get drawerAnonymousUser;

  /// No description provided for @drawerCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer compte'**
  String get drawerCreateAccount;

  /// No description provided for @drawerLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get drawerLogin;

  /// No description provided for @drawerConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get drawerConnected;

  /// No description provided for @drawerLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get drawerLogoutTitle;

  /// No description provided for @drawerLogoutMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ? Vous redeviendrez un utilisateur anonyme.'**
  String get drawerLogoutMessage;

  /// No description provided for @drawerLogoutSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion réussie'**
  String get drawerLogoutSuccess;

  /// No description provided for @drawerVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version 1.0.0'**
  String get drawerVersion;

  /// No description provided for @drawerChooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get drawerChooseLanguage;

  /// No description provided for @drawerLanguageChanged.
  ///
  /// In fr, this message translates to:
  /// **'Langue changée vers {language}'**
  String drawerLanguageChanged(String language);

  /// No description provided for @drawerSendFeedback.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un commentaire'**
  String get drawerSendFeedback;

  /// No description provided for @drawerFeedbackHint.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre expérience avec Visit Djibouti...'**
  String get drawerFeedbackHint;

  /// No description provided for @drawerFeedbackThanks.
  ///
  /// In fr, this message translates to:
  /// **'Merci pour vos commentaires !'**
  String get drawerFeedbackThanks;

  /// No description provided for @drawerPolice.
  ///
  /// In fr, this message translates to:
  /// **'🚨 Police: 17'**
  String get drawerPolice;

  /// No description provided for @drawerFire.
  ///
  /// In fr, this message translates to:
  /// **'🚒 Pompiers: 18'**
  String get drawerFire;

  /// No description provided for @drawerSamu.
  ///
  /// In fr, this message translates to:
  /// **'🏥 SAMU: 351351'**
  String get drawerSamu;

  /// No description provided for @drawerMedical.
  ///
  /// In fr, this message translates to:
  /// **'🚑 Urgences médicales: 35 35 35'**
  String get drawerMedical;

  /// No description provided for @drawerInfo.
  ///
  /// In fr, this message translates to:
  /// **'📞 Renseignements: 12'**
  String get drawerInfo;

  /// No description provided for @drawerTourismOfficeSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture du site web de l\'Office du Tourisme'**
  String get drawerTourismOfficeSnackbar;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get commonError;

  /// No description provided for @commonErrorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inconnue'**
  String get commonErrorUnknown;

  /// No description provided for @commonErrorSync.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de synchronisation'**
  String get commonErrorSync;

  /// No description provided for @commonErrorDownload.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de téléchargement'**
  String get commonErrorDownload;

  /// No description provided for @commonErrorCache.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du vidage du cache'**
  String get commonErrorCache;

  /// No description provided for @commonErrorFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la modification des favoris'**
  String get commonErrorFavorites;

  /// No description provided for @commonErrorLoading.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement'**
  String get commonErrorLoading;

  /// No description provided for @commonErrorUnexpected.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue s\'est produite'**
  String get commonErrorUnexpected;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get commonShare;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get commonNext;

  /// No description provided for @commonPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get commonPrevious;

  /// No description provided for @commonDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get commonDone;

  /// No description provided for @commonSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get commonSkip;

  /// No description provided for @commonSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get commonSeeAll;

  /// No description provided for @commonShowMore.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get commonShowMore;

  /// No description provided for @commonShowLess.
  ///
  /// In fr, this message translates to:
  /// **'Voir moins'**
  String get commonShowLess;

  /// No description provided for @commonSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get commonSend;

  /// No description provided for @settingsGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get settingsGeneral;

  /// No description provided for @settingsPreferredRegion.
  ///
  /// In fr, this message translates to:
  /// **'Région préférée'**
  String get settingsPreferredRegion;

  /// No description provided for @settingsDarkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Interface sombre pour économiser la batterie'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsDarkModeActivated.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre activé'**
  String get settingsDarkModeActivated;

  /// No description provided for @settingsDarkModeDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre désactivé'**
  String get settingsDarkModeDeactivated;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications push'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir les alertes sur les nouveaux événements'**
  String get settingsPushNotificationsSubtitle;

  /// No description provided for @settingsEventReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels d\'événements'**
  String get settingsEventReminders;

  /// No description provided for @settingsEventRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications avant vos événements réservés'**
  String get settingsEventRemindersSubtitle;

  /// No description provided for @settingsNewPois.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux POIs'**
  String get settingsNewPois;

  /// No description provided for @settingsNewPoisSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Être informé des nouveaux lieux découverts'**
  String get settingsNewPoisSubtitle;

  /// No description provided for @settingsLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get settingsLocation;

  /// No description provided for @settingsLocationServices.
  ///
  /// In fr, this message translates to:
  /// **'Services de localisation'**
  String get settingsLocationServices;

  /// No description provided for @settingsLocationServicesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Permettre la géolocalisation pour les POIs proches'**
  String get settingsLocationServicesSubtitle;

  /// No description provided for @settingsDefaultZoom.
  ///
  /// In fr, this message translates to:
  /// **'Niveau de zoom par défaut'**
  String get settingsDefaultZoom;

  /// No description provided for @settingsDefaultZoomSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Zoom initial sur la carte'**
  String get settingsDefaultZoomSubtitle;

  /// No description provided for @settingsDataStorage.
  ///
  /// In fr, this message translates to:
  /// **'Données & Stockage'**
  String get settingsDataStorage;

  /// No description provided for @settingsOfflineModeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les téléchargements et la synchronisation'**
  String get settingsOfflineModeSubtitle;

  /// No description provided for @settingsManageCache.
  ///
  /// In fr, this message translates to:
  /// **'Gérer le cache'**
  String get settingsManageCache;

  /// No description provided for @settingsImageCache.
  ///
  /// In fr, this message translates to:
  /// **'Cache des images: {size}'**
  String settingsImageCache(String size);

  /// No description provided for @settingsOfflineMaps.
  ///
  /// In fr, this message translates to:
  /// **'Cartes hors ligne'**
  String get settingsOfflineMaps;

  /// No description provided for @settingsOfflineMapsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les cartes de Djibouti'**
  String get settingsOfflineMapsSubtitle;

  /// No description provided for @settingsSecurityPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité & Confidentialité'**
  String get settingsSecurityPrivacy;

  /// No description provided for @settingsPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos données personnelles'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Lire les conditions d\'utilisation'**
  String get settingsTermsSubtitle;

  /// No description provided for @settingsActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get settingsActions;

  /// No description provided for @settingsBackupData.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder mes données'**
  String get settingsBackupData;

  /// No description provided for @settingsBackupDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Favoris, réservations et préférences'**
  String get settingsBackupDataSubtitle;

  /// No description provided for @settingsResetSettings.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer paramètres par défaut'**
  String get settingsResetSettings;

  /// No description provided for @settingsResetSettingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Remettre tous les paramètres à zéro'**
  String get settingsResetSettingsSubtitle;

  /// No description provided for @settingsAllowGeolocation.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser la géolocalisation'**
  String get settingsAllowGeolocation;

  /// No description provided for @settingsGeolocationRequest.
  ///
  /// In fr, this message translates to:
  /// **'Visit Djibouti souhaite accéder à votre position pour vous montrer les points d\'intérêt proches de vous.'**
  String get settingsGeolocationRequest;

  /// No description provided for @settingsAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get settingsAllow;

  /// No description provided for @settingsGeolocationEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Géolocalisation activée'**
  String get settingsGeolocationEnabled;

  /// No description provided for @settingsClearCache.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache'**
  String get settingsClearCache;

  /// No description provided for @settingsCacheClearedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Cache vidé avec succès'**
  String get settingsCacheClearedSuccess;

  /// No description provided for @settingsErrorClearing.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du vidage: {error}'**
  String settingsErrorClearing(String error);

  /// No description provided for @settingsClear.
  ///
  /// In fr, this message translates to:
  /// **'Vider'**
  String get settingsClear;

  /// No description provided for @eventsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un événement...'**
  String get eventsSearchHint;

  /// No description provided for @eventsAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get eventsAll;

  /// No description provided for @eventsNoEventsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement trouvé'**
  String get eventsNoEventsFound;

  /// No description provided for @eventsClearFilters.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get eventsClearFilters;

  /// No description provided for @eventsPopular.
  ///
  /// In fr, this message translates to:
  /// **'Populaire'**
  String get eventsPopular;

  /// No description provided for @eventsRemovedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'{title} retiré des favoris'**
  String eventsRemovedFromFavorites(String title);

  /// No description provided for @eventsAddedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'{title} ajouté aux favoris'**
  String eventsAddedToFavorites(String title);

  /// No description provided for @homeShufflePois.
  ///
  /// In fr, this message translates to:
  /// **'Mélanger les POIs'**
  String get homeShufflePois;

  /// No description provided for @homeNoFeaturedPois.
  ///
  /// In fr, this message translates to:
  /// **'Aucun POI en vedette disponible'**
  String get homeNoFeaturedPois;

  /// No description provided for @homeNoUpcomingEvents.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement à venir'**
  String get homeNoUpcomingEvents;

  /// No description provided for @homeDiscover.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get homeDiscover;

  /// No description provided for @homeTourOperators.
  ///
  /// In fr, this message translates to:
  /// **'Opérateurs Touristiques'**
  String get homeTourOperators;

  /// No description provided for @homeTourOperatorsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Planifiez votre aventure avec des experts'**
  String get homeTourOperatorsSubtitle;

  /// No description provided for @homeEssentialInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos Essentielles'**
  String get homeEssentialInfo;

  /// No description provided for @homeEssentialInfoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Organisation et liens utiles'**
  String get homeEssentialInfoSubtitle;

  /// No description provided for @homeEmbassies.
  ///
  /// In fr, this message translates to:
  /// **'Ambassades'**
  String get homeEmbassies;

  /// No description provided for @homeEmbassiesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Représentations diplomatiques à Djibouti et à l\'étranger'**
  String get homeEmbassiesSubtitle;

  /// No description provided for @mapErrorLoadingPois.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des POIs: {message}'**
  String mapErrorLoadingPois(String message);

  /// No description provided for @mapError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String mapError(String error);

  /// No description provided for @mapUnknownPlace.
  ///
  /// In fr, this message translates to:
  /// **'Lieu inconnu'**
  String get mapUnknownPlace;

  /// No description provided for @authWelcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour !'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à votre compte Visit Djibouti'**
  String get authSignInSubtitle;

  /// No description provided for @authOr.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get authOr;

  /// No description provided for @authSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie !'**
  String get authSuccessTitle;

  /// No description provided for @authErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get authErrorTitle;

  /// No description provided for @authSignUpSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie'**
  String get authSignUpSuccessTitle;

  /// No description provided for @authConversionProblemTitle.
  ///
  /// In fr, this message translates to:
  /// **'Problème de conversion'**
  String get authConversionProblemTitle;

  /// No description provided for @authKeepDiscoveries.
  ///
  /// In fr, this message translates to:
  /// **'Gardez vos découvertes !'**
  String get authKeepDiscoveries;

  /// No description provided for @authWelcomeToApp.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Visit Djibouti'**
  String get authWelcomeToApp;

  /// No description provided for @authCreateAccountDescription.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte pour sauvegarder vos favoris et préférences'**
  String get authCreateAccountDescription;

  /// No description provided for @authDataPreserved.
  ///
  /// In fr, this message translates to:
  /// **'Vos données actuelles seront préservées'**
  String get authDataPreserved;

  /// No description provided for @authKeepingDataInfo.
  ///
  /// In fr, this message translates to:
  /// **'✨ En créant votre compte, vous gardez :'**
  String get authKeepingDataInfo;

  /// No description provided for @authCurrentFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Tous vos favoris actuels'**
  String get authCurrentFavorites;

  /// No description provided for @authPreferences.
  ///
  /// In fr, this message translates to:
  /// **'Vos préférences'**
  String get authPreferences;

  /// No description provided for @authBrowsingHistory.
  ///
  /// In fr, this message translates to:
  /// **'Votre historique de navigation'**
  String get authBrowsingHistory;

  /// No description provided for @authDiscoveredPlaces.
  ///
  /// In fr, this message translates to:
  /// **'Vos lieux découverts'**
  String get authDiscoveredPlaces;

  /// No description provided for @aboutPageDescription.
  ///
  /// In fr, this message translates to:
  /// **'Visit Djibouti est l\'application officielle du tourisme djiboutien. Découvrez les sites exceptionnels, événements culturels et expériences uniques que notre pays a à offrir. Des paysages volcaniques aux fonds marins préservés, en passant par notre riche patrimoine culturel, explorez Djibouti comme jamais auparavant.'**
  String get aboutPageDescription;

  /// No description provided for @aboutPointsOfInterest.
  ///
  /// In fr, this message translates to:
  /// **'Points d\'Intérêt'**
  String get aboutPointsOfInterest;

  /// No description provided for @aboutEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get aboutEvents;

  /// No description provided for @aboutTourismOffice.
  ///
  /// In fr, this message translates to:
  /// **'Office du Tourisme de Djibouti'**
  String get aboutTourismOffice;

  /// No description provided for @aboutTourismOfficeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Organisme officiel de promotion touristique'**
  String get aboutTourismOfficeSubtitle;

  /// No description provided for @aboutMinistry.
  ///
  /// In fr, this message translates to:
  /// **'Ministère du Commerce et du Tourisme'**
  String get aboutMinistry;

  /// No description provided for @aboutMinistrySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'République de Djibouti'**
  String get aboutMinistrySubtitle;

  /// No description provided for @aboutHotelsAssociation.
  ///
  /// In fr, this message translates to:
  /// **'Association des Hôteliers'**
  String get aboutHotelsAssociation;

  /// No description provided for @aboutHotelsAssociationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Secteur privé du tourisme'**
  String get aboutHotelsAssociationSubtitle;

  /// No description provided for @helpHowCanWeHelp.
  ///
  /// In fr, this message translates to:
  /// **'Comment pouvons-nous vous aider ?'**
  String get helpHowCanWeHelp;

  /// No description provided for @helpSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans l\'aide...'**
  String get helpSearchPlaceholder;

  /// No description provided for @helpContactUs.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get helpContactUs;

  /// No description provided for @helpLiveChat.
  ///
  /// In fr, this message translates to:
  /// **'Chat en direct'**
  String get helpLiveChat;

  /// No description provided for @helpConnectingToChat.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au chat en cours...'**
  String get helpConnectingToChat;

  /// No description provided for @helpStartChat.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer le chat'**
  String get helpStartChat;

  /// No description provided for @helpSubject.
  ///
  /// In fr, this message translates to:
  /// **'Sujet'**
  String get helpSubject;

  /// No description provided for @helpMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre message'**
  String get helpMessage;

  /// No description provided for @helpEmailOptional.
  ///
  /// In fr, this message translates to:
  /// **'Votre email (optionnel)'**
  String get helpEmailOptional;

  /// No description provided for @helpProblemTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre du problème'**
  String get helpProblemTitle;

  /// No description provided for @helpMessageSentSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Message envoyé avec succès !'**
  String get helpMessageSentSuccess;

  /// No description provided for @helpHowToUseMap.
  ///
  /// In fr, this message translates to:
  /// **'Comment utiliser la carte'**
  String get helpHowToUseMap;

  /// No description provided for @helpBookEvent.
  ///
  /// In fr, this message translates to:
  /// **'Réserver un événement'**
  String get helpBookEvent;

  /// No description provided for @helpManageFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Gérer ses favoris'**
  String get helpManageFavorites;

  /// No description provided for @helpDescribeProblem.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez le problème rencontré...'**
  String get helpDescribeProblem;

  /// No description provided for @helpDuration3Min.
  ///
  /// In fr, this message translates to:
  /// **'3 min'**
  String get helpDuration3Min;

  /// No description provided for @helpDuration2Min.
  ///
  /// In fr, this message translates to:
  /// **'2 min'**
  String get helpDuration2Min;

  /// No description provided for @helpDuration1Min.
  ///
  /// In fr, this message translates to:
  /// **'1 min'**
  String get helpDuration1Min;

  /// No description provided for @embassiesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ambassades'**
  String get embassiesTitle;

  /// No description provided for @embassiesCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get embassiesCall;

  /// No description provided for @embassiesEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get embassiesEmail;

  /// No description provided for @embassiesWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get embassiesWebsite;

  /// No description provided for @embassiesCannotOpenPhone.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'application téléphone'**
  String get embassiesCannotOpenPhone;

  /// No description provided for @embassiesCannotOpenEmail.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'application email'**
  String get embassiesCannotOpenEmail;

  /// No description provided for @embassiesCannotOpenWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir le site web'**
  String get embassiesCannotOpenWebsite;

  /// No description provided for @essentialsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Infos Essentielles'**
  String get essentialsTitle;

  /// No description provided for @essentialsUnavailableInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations indisponibles'**
  String get essentialsUnavailableInfo;

  /// No description provided for @essentialsNoLinksAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lien disponible'**
  String get essentialsNoLinksAvailable;

  /// No description provided for @eventDetailErrorLoading.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des détails'**
  String get eventDetailErrorLoading;

  /// No description provided for @eventDetailRegistrationConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Inscription confirmée !'**
  String get eventDetailRegistrationConfirmed;

  /// No description provided for @eventDetailReservationNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de réservation: {number}'**
  String eventDetailReservationNumber(String number);

  /// No description provided for @eventDetailParticipantsCount.
  ///
  /// In fr, this message translates to:
  /// **'Participants: {count}'**
  String eventDetailParticipantsCount(String count);

  /// No description provided for @eventDetailSpecialRequirements.
  ///
  /// In fr, this message translates to:
  /// **'Exigences spéciales: {requirements}'**
  String eventDetailSpecialRequirements(String requirements);

  /// No description provided for @eventDetailParticipantsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de participants'**
  String get eventDetailParticipantsLabel;

  /// No description provided for @eventDetailFullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get eventDetailFullNameLabel;

  /// No description provided for @eventDetailEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get eventDetailEmailLabel;

  /// No description provided for @eventDetailPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get eventDetailPhoneLabel;

  /// No description provided for @eventDetailSpecialRequirementsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Exigences spéciales (optionnel)'**
  String get eventDetailSpecialRequirementsLabel;

  /// No description provided for @eventDetailSpecialRequirementsHint.
  ///
  /// In fr, this message translates to:
  /// **'Allergies, besoins d\'accessibilité, etc.'**
  String get eventDetailSpecialRequirementsHint;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @reservationsAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes ({count})'**
  String reservationsAll(int count);

  /// No description provided for @reservationsConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmées ({count})'**
  String reservationsConfirmed(int count);

  /// No description provided for @reservationsPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente ({count})'**
  String reservationsPending(int count);

  /// No description provided for @reservationsCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulées ({count})'**
  String reservationsCancelled(int count);

  /// No description provided for @reservationsNoneAll.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation'**
  String get reservationsNoneAll;

  /// No description provided for @reservationsNoneConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation confirmée'**
  String get reservationsNoneConfirmed;

  /// No description provided for @reservationsNonePending.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation en attente'**
  String get reservationsNonePending;

  /// No description provided for @reservationsNoneCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation annulée'**
  String get reservationsNoneCancelled;

  /// No description provided for @reservationsCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la réservation'**
  String get reservationsCancelTitle;

  /// No description provided for @reservationsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la réservation'**
  String get reservationsDeleteTitle;

  /// No description provided for @tourOperatorsNoneFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun opérateur touristique trouvé'**
  String get tourOperatorsNoneFound;

  /// No description provided for @offlineLoadingSettings.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des paramètres...'**
  String get offlineLoadingSettings;

  /// No description provided for @offlineConnectionStatus.
  ///
  /// In fr, this message translates to:
  /// **'État de la connexion'**
  String get offlineConnectionStatus;

  /// No description provided for @offlineClearCacheTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache'**
  String get offlineClearCacheTitle;

  /// No description provided for @profileUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get profileUser;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogoutTitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get profilePersonalInfo;

  /// No description provided for @profileEditTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get profileEditTooltip;

  /// No description provided for @profileSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get profileSecurity;

  /// No description provided for @apiTestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Test API POIs'**
  String get apiTestTitle;

  /// No description provided for @discoverClearFilters.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get discoverClearFilters;

  /// No description provided for @mapSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher sur la carte...'**
  String get mapSearchHint;

  /// No description provided for @categoryFilterClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get categoryFilterClear;

  /// No description provided for @offlineIndicatorConnectionRestored.
  ///
  /// In fr, this message translates to:
  /// **'Connexion rétablie !'**
  String get offlineIndicatorConnectionRestored;

  /// No description provided for @offlineIndicatorOfflineMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get offlineIndicatorOfflineMode;

  /// No description provided for @offlineIndicatorOfflineModeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get offlineIndicatorOfflineModeTitle;

  /// No description provided for @reservationFormDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date *'**
  String get reservationFormDateLabel;

  /// No description provided for @reservationFormDatePlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get reservationFormDatePlaceholder;

  /// No description provided for @reservationFormTimeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get reservationFormTimeLabel;

  /// No description provided for @reservationFormTimePlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'HH:MM'**
  String get reservationFormTimePlaceholder;

  /// No description provided for @reservationFormParticipantsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes *'**
  String get reservationFormParticipantsLabel;

  /// No description provided for @reservationFormParticipantsPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'1'**
  String get reservationFormParticipantsPlaceholder;

  /// No description provided for @reservationFormNotesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Notes ou demandes spéciales'**
  String get reservationFormNotesLabel;

  /// No description provided for @reservationFormNotesPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Allergies alimentaires, besoins spéciaux...'**
  String get reservationFormNotesPlaceholder;

  /// No description provided for @reservationFormPleaseSelectDate.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une date'**
  String get reservationFormPleaseSelectDate;

  /// No description provided for @reservationFormUnexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inattendue: {error}'**
  String reservationFormUnexpectedError(String error);

  /// No description provided for @tourOperatorDetailsSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Détails de {name}'**
  String tourOperatorDetailsSnackbar(String name);

  /// No description provided for @tourOperatorCallButton.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get tourOperatorCallButton;

  /// No description provided for @tourOperatorWebsiteButton.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get tourOperatorWebsiteButton;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
