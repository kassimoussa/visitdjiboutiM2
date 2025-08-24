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
