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
  /// **'Découvrez la beauté de Djibouti'**
  String get appDescription;

  /// No description provided for @authAcceptTerms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les'**
  String get authAcceptTerms;

  /// No description provided for @authAcceptTermsAnd.
  ///
  /// In fr, this message translates to:
  /// **'et'**
  String get authAcceptTermsAnd;

  /// No description provided for @authBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get authBackToLogin;

  /// No description provided for @authConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get authConfirmPassword;

  /// No description provided for @authConversionProblemTitle.
  ///
  /// In fr, this message translates to:
  /// **'Problème de conversion'**
  String get authConversionProblemTitle;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccount;

  /// No description provided for @authCreateAccountDescription.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez-nous pour découvrir Djibouti'**
  String get authCreateAccountDescription;

  /// No description provided for @authEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get authErrorTitle;

  /// No description provided for @authForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié?'**
  String get authForgotPassword;

  /// No description provided for @authKeepDiscoveries.
  ///
  /// In fr, this message translates to:
  /// **'Conserver mes découvertes'**
  String get authKeepDiscoveries;

  /// No description provided for @authLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLogin;

  /// No description provided for @authLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get authLogout;

  /// No description provided for @authName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get authName;

  /// No description provided for @authNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte?'**
  String get authNoAccount;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get authPrivacyPolicy;

  /// No description provided for @authRegister.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get authRegister;

  /// No description provided for @authResetEmailSent.
  ///
  /// In fr, this message translates to:
  /// **'Email envoyé'**
  String get authResetEmailSent;

  /// No description provided for @authResetEmailSentMessage.
  ///
  /// In fr, this message translates to:
  /// **'Un lien de réinitialisation a été envoyé à votre email'**
  String get authResetEmailSentMessage;

  /// No description provided for @authResetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get authResetPassword;

  /// No description provided for @authResetPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre email pour recevoir un lien'**
  String get authResetPasswordSubtitle;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get authResetPasswordTitle;

  /// No description provided for @authSendResetLink.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get authSendResetLink;

  /// No description provided for @authSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authSignIn;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer'**
  String get authSignInSubtitle;

  /// No description provided for @authSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get authSuccessTitle;

  /// No description provided for @authTermsAndConditions.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get authTermsAndConditions;

  /// No description provided for @authWelcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour'**
  String get authWelcomeBack;

  /// No description provided for @authWelcomeToApp.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Visit Djibouti'**
  String get authWelcomeToApp;

  /// No description provided for @categoryFilterClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get categoryFilterClear;

  /// No description provided for @commonAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get commonAddress;

  /// No description provided for @commonAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get commonAll;

  /// No description provided for @commonAllFeminine.
  ///
  /// In fr, this message translates to:
  /// **'Toute'**
  String get commonAllFeminine;

  /// No description provided for @commonApplyFilters.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer les filtres'**
  String get commonApplyFilters;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get commonCategories;

  /// No description provided for @commonCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get commonCategory;

  /// No description provided for @commonClearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get commonClearAll;

  /// No description provided for @commonConnectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get commonConnectionError;

  /// No description provided for @commonContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get commonContact;

  /// No description provided for @commonCoordinates.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées'**
  String get commonCoordinates;

  /// No description provided for @commonCopiedToClipboard.
  ///
  /// In fr, this message translates to:
  /// **'Copié dans le presse-papiers'**
  String get commonCopiedToClipboard;

  /// No description provided for @commonCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get commonCopy;

  /// No description provided for @commonDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get commonDescription;

  /// No description provided for @commonDiscoverPlace.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir ce lieu'**
  String get commonDiscoverPlace;

  /// No description provided for @commonEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;

  /// No description provided for @commonEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonEntryPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'entrée'**
  String get commonEntryPrice;

  /// No description provided for @commonError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get commonError;

  /// No description provided for @commonErrorFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la gestion des favoris'**
  String get commonErrorFavorites;

  /// No description provided for @commonErrorLoading.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get commonErrorLoading;

  /// No description provided for @commonErrorUnexpected.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inattendue'**
  String get commonErrorUnexpected;

  /// No description provided for @commonEvent.
  ///
  /// In fr, this message translates to:
  /// **'Événement'**
  String get commonEvent;

  /// No description provided for @commonFieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get commonFieldRequired;

  /// No description provided for @commonFilters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get commonFilters;

  /// No description provided for @commonExploreOnSite.
  ///
  /// In fr, this message translates to:
  /// **'Explorer sur place'**
  String get commonExploreOnSite;

  /// No description provided for @commonInformations.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get commonInformations;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get commonLoading;

  /// No description provided for @commonLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get commonLocation;

  /// No description provided for @commonNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get commonNext;

  /// No description provided for @commonNoNavigationApp.
  ///
  /// In fr, this message translates to:
  /// **'Aucune application de navigation disponible'**
  String get commonNoNavigationApp;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonOpeningHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires d\'ouverture'**
  String get commonOpeningHours;

  /// No description provided for @commonOverview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get commonOverview;

  /// No description provided for @commonPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get commonPhone;

  /// No description provided for @commonPracticalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations pratiques'**
  String get commonPracticalInfo;

  /// No description provided for @commonReservationsAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Réservations acceptées'**
  String get commonReservationsAccepted;

  /// No description provided for @commonReservePlace.
  ///
  /// In fr, this message translates to:
  /// **'Réserver'**
  String get commonReservePlace;

  /// No description provided for @commonReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get commonReset;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get commonSeeAll;

  /// No description provided for @commonSharedFrom.
  ///
  /// In fr, this message translates to:
  /// **'Partagé depuis Visit Djibouti'**
  String get commonSharedFrom;

  /// No description provided for @commonSharePlace.
  ///
  /// In fr, this message translates to:
  /// **'Partager ce lieu'**
  String get commonSharePlace;

  /// No description provided for @commonUnexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inattendue'**
  String get commonUnexpectedError;

  /// No description provided for @commonUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get commonUnknown;

  /// No description provided for @commonUnknownEvent.
  ///
  /// In fr, this message translates to:
  /// **'Événement inconnu'**
  String get commonUnknownEvent;

  /// No description provided for @commonUnknownPlace.
  ///
  /// In fr, this message translates to:
  /// **'Lieu inconnu'**
  String get commonUnknownPlace;

  /// No description provided for @commonVisitorTips.
  ///
  /// In fr, this message translates to:
  /// **'Conseils aux visiteurs'**
  String get commonVisitorTips;

  /// No description provided for @commonWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get commonWebsite;

  /// No description provided for @discoverSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des lieux...'**
  String get discoverSearchHint;

  /// No description provided for @discoverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get discoverTitle;

  /// No description provided for @drawerAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get drawerAbout;

  /// No description provided for @drawerChooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get drawerChooseLanguage;

  /// No description provided for @drawerConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get drawerConnected;

  /// No description provided for @drawerGuest.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get drawerGuest;

  /// No description provided for @drawerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get drawerHelp;

  /// No description provided for @drawerLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get drawerLanguage;

  /// No description provided for @drawerLogoutMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter?'**
  String get drawerLogoutMessage;

  /// No description provided for @drawerLogoutSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion réussie'**
  String get drawerLogoutSuccess;

  /// No description provided for @drawerNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get drawerNotifications;

  /// No description provided for @drawerOfflineMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get drawerOfflineMode;

  /// No description provided for @drawerReservations.
  ///
  /// In fr, this message translates to:
  /// **'Mes réservations'**
  String get drawerReservations;

  /// No description provided for @drawerReservationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos réservations'**
  String get drawerReservationsSubtitle;

  /// No description provided for @drawerSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get drawerSettings;

  /// No description provided for @drawerVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get drawerVersion;

  /// No description provided for @embassiesCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get embassiesCall;

  /// No description provided for @embassiesCannotOpenEmail.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'email'**
  String get embassiesCannotOpenEmail;

  /// No description provided for @embassiesCannotOpenPhone.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir le téléphone'**
  String get embassiesCannotOpenPhone;

  /// No description provided for @embassiesCannotOpenWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir le site web'**
  String get embassiesCannotOpenWebsite;

  /// No description provided for @embassiesEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get embassiesEmail;

  /// No description provided for @embassiesNoDjiboutianFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ambassade djiboutienne trouvée'**
  String get embassiesNoDjiboutianFound;

  /// No description provided for @embassiesNoDjiboutianSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations non disponibles'**
  String get embassiesNoDjiboutianSubtitle;

  /// No description provided for @embassiesNoForeignFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ambassade étrangère trouvée'**
  String get embassiesNoForeignFound;

  /// No description provided for @embassiesNoForeignSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations non disponibles'**
  String get embassiesNoForeignSubtitle;

  /// No description provided for @embassiesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ambassades'**
  String get embassiesTitle;

  /// No description provided for @embassiesWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get embassiesWebsite;

  /// No description provided for @essentialsNoLinksAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lien disponible'**
  String get essentialsNoLinksAvailable;

  /// No description provided for @essentialsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations essentielles'**
  String get essentialsTitle;

  /// No description provided for @essentialsUnavailableInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations non disponibles'**
  String get essentialsUnavailableInfo;

  /// No description provided for @eventDetailDetailsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Détails non disponibles'**
  String get eventDetailDetailsUnavailable;

  /// No description provided for @eventDetailEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get eventDetailEndDate;

  /// No description provided for @eventDetailEventEnded.
  ///
  /// In fr, this message translates to:
  /// **'Événement terminé'**
  String get eventDetailEventEnded;

  /// No description provided for @eventDetailEventFull.
  ///
  /// In fr, this message translates to:
  /// **'Événement complet'**
  String get eventDetailEventFull;

  /// No description provided for @eventDetailFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get eventDetailFree;

  /// No description provided for @eventDetailInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get eventDetailInvalidEmail;

  /// No description provided for @eventDetailParticipants.
  ///
  /// In fr, this message translates to:
  /// **'Participants'**
  String get eventDetailParticipants;

  /// No description provided for @eventDetailParticipantsLabel.
  ///
  /// In fr, this message translates to:
  /// **'participants'**
  String get eventDetailParticipantsLabel;

  /// No description provided for @eventDetailPopular.
  ///
  /// In fr, this message translates to:
  /// **'Populaire'**
  String get eventDetailPopular;

  /// No description provided for @eventDetailPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get eventDetailPrice;

  /// No description provided for @eventDetailRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get eventDetailRegistration;

  /// No description provided for @eventDetailRegistrationConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Inscription confirmée'**
  String get eventDetailRegistrationConfirmed;

  /// No description provided for @eventDetailRegistrationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'inscription'**
  String get eventDetailRegistrationError;

  /// No description provided for @eventDetailRegistrationNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro d\'inscription'**
  String get eventDetailRegistrationNumber;

  /// No description provided for @eventDetailReservationsClosed.
  ///
  /// In fr, this message translates to:
  /// **'Inscriptions fermées'**
  String get eventDetailReservationsClosed;

  /// No description provided for @eventDetailReserveEvent.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire à l\'événement'**
  String get eventDetailReserveEvent;

  /// No description provided for @eventDetailSpecialRequirements.
  ///
  /// In fr, this message translates to:
  /// **'Demandes spéciales'**
  String get eventDetailSpecialRequirements;

  /// No description provided for @eventDetailSpotsRemaining.
  ///
  /// In fr, this message translates to:
  /// **'places restantes'**
  String get eventDetailSpotsRemaining;

  /// No description provided for @eventDetailVenue.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get eventDetailVenue;

  /// No description provided for @eventDetailConfirmRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'inscription'**
  String get eventDetailConfirmRegistration;

  /// No description provided for @eventDetailContactInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations de contact'**
  String get eventDetailContactInfo;

  /// No description provided for @eventDetailEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get eventDetailEmailLabel;

  /// No description provided for @eventDetailFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get eventDetailFullName;

  /// No description provided for @eventDetailInvalidNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide'**
  String get eventDetailInvalidNumber;

  /// No description provided for @eventDetailMaxParticipants.
  ///
  /// In fr, this message translates to:
  /// **'participants maximum'**
  String get eventDetailMaxParticipants;

  /// No description provided for @eventDetailParticipantsCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de participants'**
  String get eventDetailParticipantsCount;

  /// No description provided for @eventDetailPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get eventDetailPhoneLabel;

  /// No description provided for @eventDetailSpecialRequirementsHint.
  ///
  /// In fr, this message translates to:
  /// **'Allergies, besoins spéciaux, etc.'**
  String get eventDetailSpecialRequirementsHint;

  /// No description provided for @eventDetailSpecialRequirementsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Demandes spéciales (optionnel)'**
  String get eventDetailSpecialRequirementsLabel;

  /// No description provided for @eventDetailTotalToPay.
  ///
  /// In fr, this message translates to:
  /// **'Total à payer'**
  String get eventDetailTotalToPay;

  /// Message when an event is added to favorites
  ///
  /// In fr, this message translates to:
  /// **'{eventName} ajouté aux favoris'**
  String eventsAddedToFavorites(String eventName);

  /// No description provided for @eventsAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get eventsAll;

  /// No description provided for @eventsClearFilters.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get eventsClearFilters;

  /// No description provided for @eventsFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get eventsFree;

  /// No description provided for @eventsNoEventsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement trouvé'**
  String get eventsNoEventsFound;

  /// No description provided for @eventsOngoing.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get eventsOngoing;

  /// No description provided for @eventsPast.
  ///
  /// In fr, this message translates to:
  /// **'Passés'**
  String get eventsPast;

  /// No description provided for @eventsPopular.
  ///
  /// In fr, this message translates to:
  /// **'Événements populaires'**
  String get eventsPopular;

  /// Message when an event is removed from favorites
  ///
  /// In fr, this message translates to:
  /// **'{eventName} retiré des favoris'**
  String eventsRemovedFromFavorites(String eventName);

  /// No description provided for @eventsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des événements...'**
  String get eventsSearchHint;

  /// No description provided for @eventsSoldOut.
  ///
  /// In fr, this message translates to:
  /// **'Complet'**
  String get eventsSoldOut;

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

  /// No description provided for @favoritesAddedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté aux favoris'**
  String get favoritesAddedToFavorites;

  /// No description provided for @favoritesAllTab.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get favoritesAllTab;

  /// No description provided for @favoritesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore de favoris. Explorez et ajoutez vos lieux préférés!'**
  String get favoritesEmptyDescription;

  /// No description provided for @favoritesEventsTab.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get favoritesEventsTab;

  /// No description provided for @favoritesPoisTab.
  ///
  /// In fr, this message translates to:
  /// **'Lieux'**
  String get favoritesPoisTab;

  /// No description provided for @favoritesRemovedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Retiré des favoris'**
  String get favoritesRemovedFromFavorites;

  /// No description provided for @favoritesSortAlphabetical.
  ///
  /// In fr, this message translates to:
  /// **'Alphabétique'**
  String get favoritesSortAlphabetical;

  /// No description provided for @favoritesSortRating.
  ///
  /// In fr, this message translates to:
  /// **'Évaluation'**
  String get favoritesSortRating;

  /// No description provided for @favoritesSortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get favoritesSortRecent;

  /// No description provided for @favoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favoritesTitle;

  /// No description provided for @featuredBadge.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé'**
  String get featuredBadge;

  /// No description provided for @homeDiscover.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get homeDiscover;

  /// No description provided for @homeDiscoverByRegion.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir par région'**
  String get homeDiscoverByRegion;

  /// No description provided for @homeDiscoverByRegionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Explorez les 6 régions de Djibouti'**
  String get homeDiscoverByRegionSubtitle;

  /// No description provided for @homeEmbassies.
  ///
  /// In fr, this message translates to:
  /// **'Ambassades'**
  String get homeEmbassies;

  /// No description provided for @homeEmbassiesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacts des ambassades'**
  String get homeEmbassiesSubtitle;

  /// No description provided for @homeEssentialInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos essentielles'**
  String get homeEssentialInfo;

  /// No description provided for @homeEssentialInfoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations utiles'**
  String get homeEssentialInfoSubtitle;

  /// No description provided for @homeEssentials.
  ///
  /// In fr, this message translates to:
  /// **'Essentiels'**
  String get homeEssentials;

  /// No description provided for @homeFeaturedPois.
  ///
  /// In fr, this message translates to:
  /// **'Lieux recommandés'**
  String get homeFeaturedPois;

  /// No description provided for @homeFeaturedTours.
  ///
  /// In fr, this message translates to:
  /// **'Circuits recommandés'**
  String get homeFeaturedTours;

  /// No description provided for @homeNoFeaturedPois.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lieu recommandé'**
  String get homeNoFeaturedPois;

  /// No description provided for @homeNoFeaturedTours.
  ///
  /// In fr, this message translates to:
  /// **'Aucun circuit recommandé'**
  String get homeNoFeaturedTours;

  /// No description provided for @homeNoUpcomingEvents.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement à venir'**
  String get homeNoUpcomingEvents;

  /// No description provided for @homeShufflePois.
  ///
  /// In fr, this message translates to:
  /// **'Mélanger'**
  String get homeShufflePois;

  /// No description provided for @homeTourOperators.
  ///
  /// In fr, this message translates to:
  /// **'Tour opérateurs'**
  String get homeTourOperators;

  /// No description provided for @homeTourOperatorsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Opérateurs agréés'**
  String get homeTourOperatorsSubtitle;

  /// No description provided for @homeUpcomingEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements à venir'**
  String get homeUpcomingEvents;

  /// Titre de la section des activités populaires sur la page d'accueil
  ///
  /// In fr, this message translates to:
  /// **'Activités populaires'**
  String get homePopularActivities;

  /// Message affiché lorsqu'il n'y a aucune activité à montrer
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité disponible'**
  String get homeNoActivities;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Map error message
  ///
  /// In fr, this message translates to:
  /// **'Erreur de carte: {error}'**
  String mapError(String error);

  /// Error loading POIs message
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement des lieux: {error}'**
  String mapErrorLoadingPois(String error);

  /// No description provided for @mapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get mapTitle;

  /// No description provided for @mapUnknownPlace.
  ///
  /// In fr, this message translates to:
  /// **'Lieu inconnu'**
  String get mapUnknownPlace;

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

  /// No description provided for @operatorAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get operatorAddress;

  /// No description provided for @operatorCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get operatorCall;

  /// No description provided for @operatorContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get operatorContact;

  /// No description provided for @operatorDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get operatorDescription;

  /// No description provided for @operatorEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get operatorEmail;

  /// No description provided for @operatorFeatured.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé'**
  String get operatorFeatured;

  /// No description provided for @operatorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur'**
  String get operatorLabel;

  /// No description provided for @operatorNoPois.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lieu'**
  String get operatorNoPois;

  /// No description provided for @operatorNoPoisMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cet opérateur n\'a pas encore de lieux'**
  String get operatorNoPoisMessage;

  /// No description provided for @operatorNoTours.
  ///
  /// In fr, this message translates to:
  /// **'Aucun circuit'**
  String get operatorNoTours;

  /// No description provided for @operatorNoToursMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cet opérateur n\'a pas encore de circuits'**
  String get operatorNoToursMessage;

  /// No description provided for @operatorPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get operatorPhone;

  /// No description provided for @operatorPlace.
  ///
  /// In fr, this message translates to:
  /// **'lieu'**
  String get operatorPlace;

  /// No description provided for @operatorPoiAddedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Lieu ajouté aux favoris'**
  String get operatorPoiAddedToFavorites;

  /// No description provided for @operatorPoiRemovedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Lieu retiré des favoris'**
  String get operatorPoiRemovedFromFavorites;

  /// No description provided for @operatorPoisServed.
  ///
  /// In fr, this message translates to:
  /// **'Lieux desservis'**
  String get operatorPoisServed;

  /// No description provided for @operatorSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get operatorSeeAll;

  /// No description provided for @operatorTourAddedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Circuit ajouté aux favoris'**
  String get operatorTourAddedToFavorites;

  /// No description provided for @operatorTourRemovedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Circuit retiré des favoris'**
  String get operatorTourRemovedFromFavorites;

  /// No description provided for @operatorTours.
  ///
  /// In fr, this message translates to:
  /// **'Circuits'**
  String get operatorTours;

  /// No description provided for @operatorViews.
  ///
  /// In fr, this message translates to:
  /// **'vues'**
  String get operatorViews;

  /// No description provided for @operatorWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get operatorWebsite;

  /// Call error message
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'appel: {error}'**
  String poiCallError(String error);

  /// Cannot make call message
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'appeler {phone}'**
  String poiCannotCall(String phone);

  /// No description provided for @poiCannotOpenEmail.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'email'**
  String get poiCannotOpenEmail;

  /// Email error message
  ///
  /// In fr, this message translates to:
  /// **'Erreur email: {error}'**
  String poiEmailError(String error);

  /// No description provided for @poiNoContact.
  ///
  /// In fr, this message translates to:
  /// **'Aucune information de contact disponible'**
  String get poiNoContact;

  /// No description provided for @poiTourOperatorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Opérateurs touristiques'**
  String get poiTourOperatorsTitle;

  /// No description provided for @poiLicensedOperator.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur agréé'**
  String get poiLicensedOperator;

  /// No description provided for @profileAboutApp.
  ///
  /// In fr, this message translates to:
  /// **'À propos de l\'application'**
  String get profileAboutApp;

  /// No description provided for @profileComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get profileComingSoon;

  /// No description provided for @profileComingSoonMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette fonctionnalité sera bientôt disponible'**
  String get profileComingSoonMessage;

  /// No description provided for @profileCreateAccountBenefits.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte pour profiter de tous les avantages'**
  String get profileCreateAccountBenefits;

  /// No description provided for @profileDiscoverDjibouti.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir Djibouti'**
  String get profileDiscoverDjibouti;

  /// No description provided for @profileEditTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEditTooltip;

  /// No description provided for @profileEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get profileEvents;

  /// No description provided for @profileFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get profileFavorites;

  /// No description provided for @profileHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get profileHelp;

  /// No description provided for @profileHelpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Besoin d\'assistance?'**
  String get profileHelpSubtitle;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// Language changed confirmation
  ///
  /// In fr, this message translates to:
  /// **'Langue changée en {language}'**
  String profileLanguageChanged(String language);

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la déconnexion'**
  String get profileLogoutConfirm;

  /// No description provided for @profileLogoutSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnectez-vous de votre compte'**
  String get profileLogoutSubtitle;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogoutTitle;

  /// No description provided for @profileNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileNotificationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les notifications'**
  String get profileNotificationsSubtitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get profilePersonalInfo;

  /// No description provided for @profilePersonalInfoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos informations'**
  String get profilePersonalInfoSubtitle;

  /// No description provided for @profileSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get profileSecurity;

  /// No description provided for @profileSecuritySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de sécurité'**
  String get profileSecuritySubtitle;

  /// No description provided for @profileSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get profileSettings;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos préférences'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get profileUser;

  /// All reservations tab
  ///
  /// In fr, this message translates to:
  /// **'Toutes ({count})'**
  String reservationsAll(int count);

  /// Cancelled reservations tab
  ///
  /// In fr, this message translates to:
  /// **'Réservation annulée'**
  String reservationsCancelled(int count);

  /// No description provided for @reservationsCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la réservation'**
  String get reservationsCancelTitle;

  /// Confirmed reservations tab
  ///
  /// In fr, this message translates to:
  /// **'Confirmées ({count})'**
  String reservationsConfirmed(int count);

  /// No description provided for @reservationsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la réservation'**
  String get reservationsDeleteTitle;

  /// No description provided for @reservationsNoneAll.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation'**
  String get reservationsNoneAll;

  /// No description provided for @reservationsNoneCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation annulée'**
  String get reservationsNoneCancelled;

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

  /// No description provided for @reservationsTabAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get reservationsTabAll;

  /// No description provided for @reservationsTabConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmées'**
  String get reservationsTabConfirmed;

  /// No description provided for @reservationsTabPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get reservationsTabPending;

  /// No description provided for @reservationsTabCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulées'**
  String get reservationsTabCancelled;

  /// Pending reservations tab
  ///
  /// In fr, this message translates to:
  /// **'En attente ({count})'**
  String reservationsPending(int count);

  /// No description provided for @settingsActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get settingsActions;

  /// No description provided for @settingsBackupData.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder les données'**
  String get settingsBackupData;

  /// No description provided for @settingsBackupDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde automatique'**
  String get settingsBackupDataSubtitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get settingsDarkMode;

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

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Apparence de l\'application'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsDataStorage.
  ///
  /// In fr, this message translates to:
  /// **'Stockage de données'**
  String get settingsDataStorage;

  /// No description provided for @settingsDefaultZoom.
  ///
  /// In fr, this message translates to:
  /// **'Zoom par défaut'**
  String get settingsDefaultZoom;

  /// No description provided for @settingsDefaultZoomSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Niveau de zoom de la carte'**
  String get settingsDefaultZoomSubtitle;

  /// No description provided for @settingsEventReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels d\'événements'**
  String get settingsEventReminders;

  /// No description provided for @settingsEventRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir des rappels'**
  String get settingsEventRemindersSubtitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get settingsGeneral;

  /// Image cache size
  ///
  /// In fr, this message translates to:
  /// **'{size} en cache'**
  String settingsImageCache(String size);

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
  /// **'Activer la localisation'**
  String get settingsLocationServicesSubtitle;

  /// No description provided for @settingsManageCache.
  ///
  /// In fr, this message translates to:
  /// **'Gérer le cache'**
  String get settingsManageCache;

  /// No description provided for @settingsNewPois.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux lieux'**
  String get settingsNewPois;

  /// No description provided for @settingsNewPoisSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications de nouveaux lieux'**
  String get settingsNewPoisSubtitle;

  /// No description provided for @settingsOfflineMaps.
  ///
  /// In fr, this message translates to:
  /// **'Cartes hors ligne'**
  String get settingsOfflineMaps;

  /// No description provided for @settingsOfflineMapsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les cartes'**
  String get settingsOfflineMapsSubtitle;

  /// No description provided for @settingsOfflineModeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les données hors ligne'**
  String get settingsOfflineModeSubtitle;

  /// No description provided for @settingsPreferredRegion.
  ///
  /// In fr, this message translates to:
  /// **'Région préférée'**
  String get settingsPreferredRegion;

  /// No description provided for @settingsPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer la confidentialité'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications push'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications'**
  String get settingsPushNotificationsSubtitle;

  /// No description provided for @settingsResetSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les paramètres'**
  String get settingsResetSettings;

  /// No description provided for @settingsResetSettingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer les paramètres par défaut'**
  String get settingsResetSettingsSubtitle;

  /// No description provided for @settingsSecurityPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité et confidentialité'**
  String get settingsSecurityPrivacy;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get settingsTermsSubtitle;

  /// No description provided for @tourCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get tourCall;

  /// No description provided for @tourDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get tourDescription;

  /// No description provided for @tourEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get tourEmail;

  /// No description provided for @tourFeatured.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé'**
  String get tourFeatured;

  /// No description provided for @tourHighlights.
  ///
  /// In fr, this message translates to:
  /// **'Points forts'**
  String get tourHighlights;

  /// No description provided for @tourPhotoGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie photos'**
  String get tourPhotoGallery;

  /// No description provided for @tourRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get tourRetry;

  /// No description provided for @tourViewOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get tourViewOnMap;

  /// No description provided for @tourWhatToBring.
  ///
  /// In fr, this message translates to:
  /// **'Quoi apporter'**
  String get tourWhatToBring;

  /// No description provided for @tourUnknownOperator.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur inconnu'**
  String get tourUnknownOperator;

  /// No description provided for @tourWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get tourWebsite;

  /// No description provided for @toursSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un tour...'**
  String get toursSearchHint;

  /// No description provided for @toursNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun tour trouvé pour \"{query}\"'**
  String toursNotFound(String query);

  /// No description provided for @toursTourType.
  ///
  /// In fr, this message translates to:
  /// **'Type de tour'**
  String get toursTourType;

  /// No description provided for @toursSelectType.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un type'**
  String get toursSelectType;

  /// No description provided for @toursDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get toursDifficulty;

  /// No description provided for @toursTourOperator.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur touristique'**
  String get toursTourOperator;

  /// No description provided for @toursSelectOperator.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un opérateur'**
  String get toursSelectOperator;

  /// No description provided for @homeRegionDjibouti.
  ///
  /// In fr, this message translates to:
  /// **'Djibouti'**
  String get homeRegionDjibouti;

  /// No description provided for @homeRegionTadjourah.
  ///
  /// In fr, this message translates to:
  /// **'Tadjourah'**
  String get homeRegionTadjourah;

  /// No description provided for @homeRegionAliSabieh.
  ///
  /// In fr, this message translates to:
  /// **'Ali Sabieh'**
  String get homeRegionAliSabieh;

  /// No description provided for @homeRegionDikhil.
  ///
  /// In fr, this message translates to:
  /// **'Dikhil'**
  String get homeRegionDikhil;

  /// No description provided for @homeRegionObock.
  ///
  /// In fr, this message translates to:
  /// **'Obock'**
  String get homeRegionObock;

  /// No description provided for @homeRegionArta.
  ///
  /// In fr, this message translates to:
  /// **'Arta'**
  String get homeRegionArta;

  /// No description provided for @activityDetailErrorLoading.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement: {error}'**
  String activityDetailErrorLoading(Object error);

  /// No description provided for @activityDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get activityDetailTitle;

  /// No description provided for @activityDetailRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get activityDetailRetry;

  /// No description provided for @activityDetailDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get activityDetailDescription;

  /// No description provided for @activityDetailPracticalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations pratiques'**
  String get activityDetailPracticalInfo;

  /// No description provided for @activityDetailWhatIsIncluded.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui est inclus'**
  String get activityDetailWhatIsIncluded;

  /// No description provided for @activityDetailWhatToBring.
  ///
  /// In fr, this message translates to:
  /// **'À apporter'**
  String get activityDetailWhatToBring;

  /// No description provided for @activityDetailEquipment.
  ///
  /// In fr, this message translates to:
  /// **'Équipement'**
  String get activityDetailEquipment;

  /// No description provided for @activityDetailProvided.
  ///
  /// In fr, this message translates to:
  /// **'Fourni'**
  String get activityDetailProvided;

  /// No description provided for @activityDetailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get activityDetailRequired;

  /// No description provided for @activityDetailPrerequisites.
  ///
  /// In fr, this message translates to:
  /// **'Prérequis'**
  String get activityDetailPrerequisites;

  /// No description provided for @activityDetailPhysicalCondition.
  ///
  /// In fr, this message translates to:
  /// **'Condition physique'**
  String get activityDetailPhysicalCondition;

  /// No description provided for @activityDetailRequiredCertifications.
  ///
  /// In fr, this message translates to:
  /// **'Certifications requises'**
  String get activityDetailRequiredCertifications;

  /// No description provided for @activityDetailPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get activityDetailPrice;

  /// No description provided for @activityDetailDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get activityDetailDuration;

  /// No description provided for @activityDetailDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get activityDetailDifficulty;

  /// No description provided for @activityDetailLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get activityDetailLocation;

  /// No description provided for @activityDetailIncluded.
  ///
  /// In fr, this message translates to:
  /// **'Inclus'**
  String get activityDetailIncluded;

  /// No description provided for @activityDetailProvidedWithColon.
  ///
  /// In fr, this message translates to:
  /// **'Fourni :'**
  String get activityDetailProvidedWithColon;

  /// No description provided for @activityDetailRequiredWithColon.
  ///
  /// In fr, this message translates to:
  /// **'À apporter :'**
  String get activityDetailRequiredWithColon;

  /// No description provided for @activityDetailPhysicalConditionWithColon.
  ///
  /// In fr, this message translates to:
  /// **'Condition physique :'**
  String get activityDetailPhysicalConditionWithColon;

  /// No description provided for @activityDetailCertificationsWithColon.
  ///
  /// In fr, this message translates to:
  /// **'Certifications :'**
  String get activityDetailCertificationsWithColon;

  /// No description provided for @activityDetailAgeRestrictions.
  ///
  /// In fr, this message translates to:
  /// **'Restrictions d\'âge'**
  String get activityDetailAgeRestrictions;

  /// No description provided for @activityDetailWeatherDependent.
  ///
  /// In fr, this message translates to:
  /// **'Cette activité est dépendante des conditions météorologiques'**
  String get activityDetailWeatherDependent;

  /// No description provided for @activityDetailMeetingPoint.
  ///
  /// In fr, this message translates to:
  /// **'Point de rendez-vous'**
  String get activityDetailMeetingPoint;

  /// No description provided for @activityDetailAdditionalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations supplémentaires'**
  String get activityDetailAdditionalInfo;

  /// No description provided for @activityDetailOrganizedBy.
  ///
  /// In fr, this message translates to:
  /// **'Organisé par'**
  String get activityDetailOrganizedBy;

  /// No description provided for @activityDetailCertifiedOperator.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur agréé'**
  String get activityDetailCertifiedOperator;

  /// No description provided for @activityDetailCancellationPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique d\'annulation'**
  String get activityDetailCancellationPolicy;

  /// No description provided for @activityDetailLinks.
  ///
  /// In fr, this message translates to:
  /// **'Links'**
  String get activityDetailLinks;

  /// No description provided for @activityDetailFrom.
  ///
  /// In fr, this message translates to:
  /// **'À partir de'**
  String get activityDetailFrom;

  /// No description provided for @activityDetailBookNow.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire maintenant'**
  String get activityDetailBookNow;

  /// No description provided for @activityDetailSoldOut.
  ///
  /// In fr, this message translates to:
  /// **'Places épuisées'**
  String get activityDetailSoldOut;

  /// No description provided for @activityDetailRegistrationSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Inscription enregistrée avec succès !'**
  String get activityDetailRegistrationSuccess;

  /// No description provided for @activityRegistrationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String activityRegistrationError(Object error);

  /// No description provided for @activityRegistrationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get activityRegistrationTitle;

  /// No description provided for @activityRegistrationNumberOfParticipants.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de participants'**
  String get activityRegistrationNumberOfParticipants;

  /// No description provided for @activityRegistrationTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total: {totalPrice} DJF'**
  String activityRegistrationTotal(String totalPrice);

  /// No description provided for @activityRegistrationPreferredDate.
  ///
  /// In fr, this message translates to:
  /// **'Date préférée (optionnel)'**
  String get activityRegistrationPreferredDate;

  /// No description provided for @activityRegistrationSelectDate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get activityRegistrationSelectDate;

  /// No description provided for @activityRegistrationYourInformation.
  ///
  /// In fr, this message translates to:
  /// **'Vos informations'**
  String get activityRegistrationYourInformation;

  /// No description provided for @activityRegistrationFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet *'**
  String get activityRegistrationFullName;

  /// No description provided for @activityRegistrationEnterYourName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get activityRegistrationEnterYourName;

  /// No description provided for @activityRegistrationEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email *'**
  String get activityRegistrationEmail;

  /// No description provided for @activityRegistrationEnterYourEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get activityRegistrationEnterYourEmail;

  /// No description provided for @activityRegistrationInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get activityRegistrationInvalidEmail;

  /// No description provided for @activityRegistrationPhoneOptional.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (optionnel)'**
  String get activityRegistrationPhoneOptional;

  /// No description provided for @activityRegistrationSpecialRequirementsOptional.
  ///
  /// In fr, this message translates to:
  /// **'Exigences spéciales (optionnel)'**
  String get activityRegistrationSpecialRequirementsOptional;

  /// No description provided for @activityRegistrationDietAllergiesEtc.
  ///
  /// In fr, this message translates to:
  /// **'Régime alimentaire, allergies, etc.'**
  String get activityRegistrationDietAllergiesEtc;

  /// No description provided for @activityRegistrationMedicalConditionsOptional.
  ///
  /// In fr, this message translates to:
  /// **'Conditions médicales (optionnel)'**
  String get activityRegistrationMedicalConditionsOptional;

  /// No description provided for @activityRegistrationImportantSafetyInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations importantes pour votre sécurité'**
  String get activityRegistrationImportantSafetyInfo;

  /// No description provided for @activityRegistrationConfirmRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'inscription'**
  String get activityRegistrationConfirmRegistration;

  /// No description provided for @tourErrorLoading.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement: {error}'**
  String tourErrorLoading(Object error);

  /// No description provided for @tourAddedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Tour ajouté aux favoris'**
  String get tourAddedToFavorites;

  /// No description provided for @tourRemovedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Tour retiré des favoris'**
  String get tourRemovedFromFavorites;

  /// No description provided for @tourPracticalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations pratiques'**
  String get tourPracticalInfo;

  /// No description provided for @tourDates.
  ///
  /// In fr, this message translates to:
  /// **'Dates'**
  String get tourDates;

  /// No description provided for @tourDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get tourDuration;

  /// No description provided for @tourAvailableSpots.
  ///
  /// In fr, this message translates to:
  /// **'Places disponibles'**
  String get tourAvailableSpots;

  /// No description provided for @tourSpots.
  ///
  /// In fr, this message translates to:
  /// **'{spots} places'**
  String tourSpots(Object spots);

  /// No description provided for @tourAgeRestrictions.
  ///
  /// In fr, this message translates to:
  /// **'Restrictions d\'âge'**
  String get tourAgeRestrictions;

  /// No description provided for @tourWeatherDependent.
  ///
  /// In fr, this message translates to:
  /// **'Ce tour est dépendant des conditions météorologiques'**
  String get tourWeatherDependent;

  /// No description provided for @tourMeetingPoint.
  ///
  /// In fr, this message translates to:
  /// **'Point de rendez-vous'**
  String get tourMeetingPoint;

  /// No description provided for @tourOrganizedBy.
  ///
  /// In fr, this message translates to:
  /// **'Organisé par'**
  String get tourOrganizedBy;

  /// No description provided for @tourOperatorCertified.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur agréé'**
  String get tourOperatorCertified;

  /// No description provided for @tourCannotOpenLink.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir le lien'**
  String get tourCannotOpenLink;

  /// No description provided for @tourOperatorTour.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur de tour'**
  String get tourOperatorTour;

  /// No description provided for @tourOperatorCertifiedTour.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur touristique agréé'**
  String get tourOperatorCertifiedTour;

  /// No description provided for @tourFrom.
  ///
  /// In fr, this message translates to:
  /// **'À partir de'**
  String get tourFrom;

  /// No description provided for @tourRegistrationConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Inscription confirmée'**
  String get tourRegistrationConfirmed;

  /// No description provided for @tourPendingConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'En attente de confirmation'**
  String get tourPendingConfirmation;

  /// No description provided for @tourRegisterNow.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire maintenant'**
  String get tourRegisterNow;

  /// No description provided for @tourSpotsSoldOut.
  ///
  /// In fr, this message translates to:
  /// **'Places épuisées'**
  String get tourSpotsSoldOut;

  /// No description provided for @tourShareTodo.
  ///
  /// In fr, this message translates to:
  /// **'TODO: Implémenter le partage'**
  String get tourShareTodo;

  /// No description provided for @tourRegistrationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription au tour'**
  String get tourRegistrationTitle;

  /// No description provided for @tourRegistrationNumberOfParticipants.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de participants *'**
  String get tourRegistrationNumberOfParticipants;

  /// No description provided for @tourRegistrationMinParticipants.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 1 personne'**
  String get tourRegistrationMinParticipants;

  /// No description provided for @tourRegistrationMaxParticipants.
  ///
  /// In fr, this message translates to:
  /// **'Maximum {maxParticipants} places'**
  String tourRegistrationMaxParticipants(String maxParticipants);

  /// No description provided for @tourRegistrationContactInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations de contact *'**
  String get tourRegistrationContactInfo;

  /// No description provided for @tourRegistrationFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get tourRegistrationFullName;

  /// No description provided for @tourRegistrationNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get tourRegistrationNameRequired;

  /// No description provided for @tourRegistrationEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get tourRegistrationEmail;

  /// No description provided for @tourRegistrationEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Email requis'**
  String get tourRegistrationEmailRequired;

  /// No description provided for @tourRegistrationInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get tourRegistrationInvalidEmail;

  /// No description provided for @tourRegistrationPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get tourRegistrationPhone;

  /// No description provided for @tourRegistrationPhoneRequired.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone requis'**
  String get tourRegistrationPhoneRequired;

  /// No description provided for @tourRegistrationNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes ou demandes spéciales'**
  String get tourRegistrationNotes;

  /// No description provided for @tourRegistrationNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Allergies alimentaires, besoins spéciaux...'**
  String get tourRegistrationNotesHint;

  /// No description provided for @tourRegistrationTotalToPay.
  ///
  /// In fr, this message translates to:
  /// **'Total à payer'**
  String get tourRegistrationTotalToPay;

  /// No description provided for @tourRegistrationAvailableSpots.
  ///
  /// In fr, this message translates to:
  /// **'{availableSpots} places disponibles'**
  String tourRegistrationAvailableSpots(String availableSpots);

  /// No description provided for @tourRegistrationConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'inscription'**
  String get tourRegistrationConfirm;

  /// No description provided for @tourRegistrationSuccessMessage.
  ///
  /// In fr, this message translates to:
  /// **'Inscription confirmée avec succès!'**
  String get tourRegistrationSuccessMessage;

  /// No description provided for @tourRegistrationErrorMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'inscription'**
  String get tourRegistrationErrorMessage;

  /// No description provided for @helpFaqQuestion1.
  ///
  /// In fr, this message translates to:
  /// **'Comment réserver un événement ?'**
  String get helpFaqQuestion1;

  /// No description provided for @helpFaqAnswer1.
  ///
  /// In fr, this message translates to:
  /// **'Allez dans l\'onglet Événements, sélectionnez un événement qui vous intéresse, puis appuyez sur \"S\'inscrire\". Vous pouvez gérer vos réservations dans votre profil.'**
  String get helpFaqAnswer1;

  /// No description provided for @helpFaqQuestion2.
  ///
  /// In fr, this message translates to:
  /// **'Puis-je utiliser l\'app sans connexion Internet ?'**
  String get helpFaqQuestion2;

  /// No description provided for @helpFaqAnswer2.
  ///
  /// In fr, this message translates to:
  /// **'Oui ! Activez le mode hors ligne dans les paramètres pour télécharger les données essentielles. Les cartes peuvent également être téléchargées pour une utilisation offline.'**
  String get helpFaqAnswer2;

  /// No description provided for @helpFaqQuestion3.
  ///
  /// In fr, this message translates to:
  /// **'Comment ajouter un lieu en favoris ?'**
  String get helpFaqQuestion3;

  /// No description provided for @helpFaqAnswer3.
  ///
  /// In fr, this message translates to:
  /// **'Sur la page de détail d\'un POI, appuyez sur l\'icône cœur. Vous retrouverez tous vos favoris dans votre profil.'**
  String get helpFaqAnswer3;

  /// No description provided for @helpFaqQuestion4.
  ///
  /// In fr, this message translates to:
  /// **'L\'app est-elle gratuite ?'**
  String get helpFaqQuestion4;

  /// No description provided for @helpFaqAnswer4.
  ///
  /// In fr, this message translates to:
  /// **'Oui, Visit Djibouti est entièrement gratuite. Certains événements peuvent avoir un coût, mais l\'application elle-même ne nécessite aucun paiement.'**
  String get helpFaqAnswer4;

  /// No description provided for @helpFaqQuestion5.
  ///
  /// In fr, this message translates to:
  /// **'Comment changer la langue de l\'interface ?'**
  String get helpFaqQuestion5;

  /// No description provided for @helpFaqAnswer5.
  ///
  /// In fr, this message translates to:
  /// **'Allez dans Paramètres > Langue et sélectionnez votre langue préférée (Français, English, العربية).'**
  String get helpFaqAnswer5;

  /// No description provided for @helpFaqQuestion6.
  ///
  /// In fr, this message translates to:
  /// **'Les informations sont-elles mises à jour ?'**
  String get helpFaqQuestion6;

  /// No description provided for @helpFaqAnswer6.
  ///
  /// In fr, this message translates to:
  /// **'Oui, notre équipe met à jour régulièrement les informations sur les POIs et événements. Assurez-vous d\'avoir une connexion Internet pour recevoir les dernières données.'**
  String get helpFaqAnswer6;

  /// No description provided for @helpFaqQuestion7.
  ///
  /// In fr, this message translates to:
  /// **'Comment signaler un problème avec un lieu ?'**
  String get helpFaqQuestion7;

  /// No description provided for @helpFaqAnswer7.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez la fonction \"Commentaires\" dans le menu principal pour nous signaler tout problème. Votre feedback nous aide à améliorer l\'application.'**
  String get helpFaqAnswer7;

  /// No description provided for @helpCategoryAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get helpCategoryAll;

  /// No description provided for @helpCategoryNavigation.
  ///
  /// In fr, this message translates to:
  /// **'Navigation'**
  String get helpCategoryNavigation;

  /// No description provided for @helpCategoryEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get helpCategoryEvents;

  /// No description provided for @helpCategoryUsage.
  ///
  /// In fr, this message translates to:
  /// **'Utilisation'**
  String get helpCategoryUsage;

  /// No description provided for @helpCategoryFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get helpCategoryFavorites;

  /// No description provided for @helpCategoryGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get helpCategoryGeneral;

  /// No description provided for @helpCategorySettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get helpCategorySettings;

  /// No description provided for @helpCategoryContent.
  ///
  /// In fr, this message translates to:
  /// **'Contenu'**
  String get helpCategoryContent;

  /// No description provided for @helpCategorySupport.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get helpCategorySupport;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment pouvons-nous vous aider ?'**
  String get helpTitle;

  /// No description provided for @helpSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans l\'aide...'**
  String get helpSearchPlaceholder;

  /// No description provided for @helpLiveChat.
  ///
  /// In fr, this message translates to:
  /// **'Chat en direct'**
  String get helpLiveChat;

  /// No description provided for @helpContactUs.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get helpContactUs;

  /// No description provided for @helpTutorials.
  ///
  /// In fr, this message translates to:
  /// **'Tutoriels'**
  String get helpTutorials;

  /// No description provided for @helpReportBug.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un bug'**
  String get helpReportBug;

  /// No description provided for @helpCantFindAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne trouvez pas la réponse ?'**
  String get helpCantFindAnswer;

  /// No description provided for @helpLiveChatTitle.
  ///
  /// In fr, this message translates to:
  /// **'Chat en direct'**
  String get helpLiveChatTitle;

  /// No description provided for @helpLiveChatInfo.
  ///
  /// In fr, this message translates to:
  /// **'Notre équipe est disponible de 8h à 18h\npour répondre à vos questions en temps réel.'**
  String get helpLiveChatInfo;

  /// No description provided for @helpLiveChatConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au chat en cours...'**
  String get helpLiveChatConnecting;

  /// No description provided for @helpStartChat.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer le chat'**
  String get helpStartChat;

  /// No description provided for @helpContactUsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get helpContactUsTitle;

  /// No description provided for @helpContactSubject.
  ///
  /// In fr, this message translates to:
  /// **'Sujet'**
  String get helpContactSubject;

  /// No description provided for @helpContactMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre message'**
  String get helpContactMessage;

  /// No description provided for @helpContactEmail.
  ///
  /// In fr, this message translates to:
  /// **'Votre email (optionnel)'**
  String get helpContactEmail;

  /// No description provided for @helpMessageSent.
  ///
  /// In fr, this message translates to:
  /// **'Message envoyé avec succès !'**
  String get helpMessageSent;

  /// No description provided for @helpSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get helpSend;

  /// No description provided for @helpTutorialsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tutoriels vidéo'**
  String get helpTutorialsTitle;

  /// No description provided for @helpTutorialMap.
  ///
  /// In fr, this message translates to:
  /// **'Comment utiliser la carte'**
  String get helpTutorialMap;

  /// No description provided for @helpTutorialMapDuration.
  ///
  /// In fr, this message translates to:
  /// **'3 min'**
  String get helpTutorialMapDuration;

  /// No description provided for @helpTutorialReserve.
  ///
  /// In fr, this message translates to:
  /// **'Réserver un événement'**
  String get helpTutorialReserve;

  /// No description provided for @helpTutorialReserveDuration.
  ///
  /// In fr, this message translates to:
  /// **'2 min'**
  String get helpTutorialReserveDuration;

  /// No description provided for @helpTutorialFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Gérer ses favoris'**
  String get helpTutorialFavorites;

  /// No description provided for @helpTutorialFavoritesDuration.
  ///
  /// In fr, this message translates to:
  /// **'1 min'**
  String get helpTutorialFavoritesDuration;

  /// No description provided for @helpReportBugTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un problème'**
  String get helpReportBugTitle;

  /// No description provided for @helpBugTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre du problème'**
  String get helpBugTitle;

  /// No description provided for @helpBugDescription.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez le problème rencontré...'**
  String get helpBugDescription;

  /// No description provided for @helpBugReported.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de bug envoyé !'**
  String get helpBugReported;

  /// No description provided for @helpReport.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get helpReport;

  /// No description provided for @reservationsEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Explorez nos lieux et événements pour faire votre première réservation!'**
  String get reservationsEmptyMessage;

  /// No description provided for @reservationsDetailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détails de la réservation'**
  String get reservationsDetailsTitle;

  /// No description provided for @reservationsCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir annuler la réservation n°{confirmationNumber}?'**
  String reservationsCancelConfirm(String confirmationNumber);

  /// No description provided for @reservationsNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get reservationsNo;

  /// No description provided for @reservationsYesCancel.
  ///
  /// In fr, this message translates to:
  /// **'Oui, annuler'**
  String get reservationsYesCancel;

  /// No description provided for @reservationsCancelError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'annulation'**
  String get reservationsCancelError;

  /// No description provided for @reservationsDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer définitivement la réservation n°{confirmationNumber}?\n\nCette action est irréversible.'**
  String reservationsDeleteConfirm(String confirmationNumber);

  /// No description provided for @reservationsYesDelete.
  ///
  /// In fr, this message translates to:
  /// **'Oui, supprimer'**
  String get reservationsYesDelete;

  /// No description provided for @reservationsDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Réservation supprimée'**
  String get reservationsDeleted;

  /// No description provided for @reservationsDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get reservationsDeleteError;

  /// No description provided for @reservationsRegistrationDetailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détails de l\'inscription'**
  String get reservationsRegistrationDetailsTitle;

  /// No description provided for @reservationsRegistrationCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'inscription'**
  String get reservationsRegistrationCancelTitle;

  /// No description provided for @reservationsRegistrationCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir annuler cette inscription ? Son statut passera à \"Annulé\".'**
  String get reservationsRegistrationCancelConfirm;

  /// No description provided for @reservationsRegistrationDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer définitivement l\'inscription #{id}? Cette action est irréversible.'**
  String reservationsRegistrationDeleteConfirm(String id);

  /// No description provided for @reservationsRegistrationCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Inscription annulée'**
  String get reservationsRegistrationCancelled;

  /// No description provided for @reservationsRegistrationDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Inscription supprimée'**
  String get reservationsRegistrationDeleted;

  /// No description provided for @reservationsRegistrationCancelError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'annulation'**
  String get reservationsRegistrationCancelError;

  /// No description provided for @reservationsRegistrationDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get reservationsRegistrationDeleteError;

  /// No description provided for @reservationsNameNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Nom non disponible'**
  String get reservationsNameNotAvailable;

  /// No description provided for @reservationsTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get reservationsTime;

  /// No description provided for @reservationsPeople.
  ///
  /// In fr, this message translates to:
  /// **'Personnes'**
  String get reservationsPeople;

  /// No description provided for @reservationsLocation.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get reservationsLocation;

  /// No description provided for @reservationsTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total:'**
  String get reservationsTotal;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @reservationsTour.
  ///
  /// In fr, this message translates to:
  /// **'Tour'**
  String get reservationsTour;

  /// No description provided for @reservationsNumber.
  ///
  /// In fr, this message translates to:
  /// **'Réservation #'**
  String get reservationsNumber;

  /// No description provided for @reservationsDates.
  ///
  /// In fr, this message translates to:
  /// **'Dates'**
  String get reservationsDates;

  /// No description provided for @reservationsParticipants.
  ///
  /// In fr, this message translates to:
  /// **'Participants'**
  String get reservationsParticipants;

  /// No description provided for @reservationsNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get reservationsNotes;

  /// No description provided for @reservationsActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get reservationsActivity;

  /// No description provided for @reservationsRegistrationNumber.
  ///
  /// In fr, this message translates to:
  /// **'Inscription #'**
  String get reservationsRegistrationNumber;

  /// No description provided for @reservationsPreferredDate.
  ///
  /// In fr, this message translates to:
  /// **'Date préférée'**
  String get reservationsPreferredDate;

  /// No description provided for @reservationsRequirements.
  ///
  /// In fr, this message translates to:
  /// **'Exigences'**
  String get reservationsRequirements;

  /// No description provided for @reservationsConfirmationNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro'**
  String get reservationsConfirmationNumber;

  /// No description provided for @reservationsPlaceOrEvent.
  ///
  /// In fr, this message translates to:
  /// **'Lieu/Événement'**
  String get reservationsPlaceOrEvent;

  /// No description provided for @reservationsType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get reservationsType;

  /// No description provided for @reservationsStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get reservationsStatus;

  /// No description provided for @reservationsCancelThisReservation.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette réservation'**
  String get reservationsCancelThisReservation;

  /// No description provided for @reservationsDeleteThisReservation.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette réservation'**
  String get reservationsDeleteThisReservation;

  /// No description provided for @reservationsCreatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Créée le'**
  String get reservationsCreatedAt;

  /// No description provided for @reservationsUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour'**
  String get reservationsUpdatedAt;

  /// No description provided for @reservationsCancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la réservation'**
  String get reservationsCancelButton;

  /// No description provided for @reservationsDeleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la réservation'**
  String get reservationsDeleteButton;

  /// No description provided for @reservationsMedicalConditions.
  ///
  /// In fr, this message translates to:
  /// **'Conditions médicales'**
  String get reservationsMedicalConditions;

  /// No description provided for @reservationsTotalPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix total'**
  String get reservationsTotalPrice;

  /// No description provided for @reservationsConfirmedAt.
  ///
  /// In fr, this message translates to:
  /// **'Confirmée le'**
  String get reservationsConfirmedAt;

  /// No description provided for @reservationsCancelledAt.
  ///
  /// In fr, this message translates to:
  /// **'Annulée le'**
  String get reservationsCancelledAt;

  /// No description provided for @reservationsRegistrationCancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'inscription'**
  String get reservationsRegistrationCancelButton;

  /// No description provided for @reservationsRegistrationDeleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'inscription'**
  String get reservationsRegistrationDeleteButton;

  /// No description provided for @reservationsRegistrationDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'inscription'**
  String get reservationsRegistrationDeleteTitle;

  /// No description provided for @reservationsName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get reservationsName;

  /// No description provided for @reservationsError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String reservationsError(String error);

  /// No description provided for @reservationsStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get reservationsStatusPending;

  /// No description provided for @reservationsStatusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get reservationsStatusConfirmed;

  /// No description provided for @reservationsStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get reservationsStatusCancelled;

  /// No description provided for @reservationsStatusUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnue'**
  String get reservationsStatusUnknown;

  /// No description provided for @reservationsTypePoi.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get reservationsTypePoi;

  /// No description provided for @reservationsTypeEvent.
  ///
  /// In fr, this message translates to:
  /// **'Événement'**
  String get reservationsTypeEvent;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsRegionAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les régions'**
  String get settingsRegionAll;

  /// No description provided for @settingsCacheSizeCalculating.
  ///
  /// In fr, this message translates to:
  /// **'Calcul en cours...'**
  String get settingsCacheSizeCalculating;

  /// No description provided for @settingsChooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get settingsChooseLanguage;

  /// No description provided for @settingsLanguageFrenchFlag.
  ///
  /// In fr, this message translates to:
  /// **'🇫🇷'**
  String get settingsLanguageFrenchFlag;

  /// No description provided for @settingsLanguageEnglishFlag.
  ///
  /// In fr, this message translates to:
  /// **'🇬🇧'**
  String get settingsLanguageEnglishFlag;

  /// No description provided for @settingsLanguageArabicFlag.
  ///
  /// In fr, this message translates to:
  /// **'🇸🇦'**
  String get settingsLanguageArabicFlag;

  /// No description provided for @settingsPreferredRegionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Région préférée'**
  String get settingsPreferredRegionTitle;

  /// No description provided for @settingsRegionDjibouti.
  ///
  /// In fr, this message translates to:
  /// **'Djibouti'**
  String get settingsRegionDjibouti;

  /// No description provided for @settingsRegionTadjourah.
  ///
  /// In fr, this message translates to:
  /// **'Tadjourah'**
  String get settingsRegionTadjourah;

  /// No description provided for @settingsRegionAliSabieh.
  ///
  /// In fr, this message translates to:
  /// **'Ali Sabieh'**
  String get settingsRegionAliSabieh;

  /// No description provided for @settingsRegionDikhil.
  ///
  /// In fr, this message translates to:
  /// **'Dikhil'**
  String get settingsRegionDikhil;

  /// No description provided for @settingsRegionObock.
  ///
  /// In fr, this message translates to:
  /// **'Obock'**
  String get settingsRegionObock;

  /// No description provided for @settingsRegionArta.
  ///
  /// In fr, this message translates to:
  /// **'Arta'**
  String get settingsRegionArta;

  /// No description provided for @settingsLocationPermissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser la géolocalisation'**
  String get settingsLocationPermissionTitle;

  /// No description provided for @settingsLocationPermissionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Visit Djibouti souhaite accéder à votre position pour vous montrer les points d\'intérêt proches de vous.'**
  String get settingsLocationPermissionMessage;

  /// No description provided for @settingsLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get settingsLater;

  /// No description provided for @settingsAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get settingsAllow;

  /// No description provided for @settingsLocationEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Géolocalisation activée'**
  String get settingsLocationEnabled;

  /// No description provided for @settingsOfflineModeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get settingsOfflineModeTitle;

  /// No description provided for @settingsOfflineModeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le téléchargement des données pour le mode hors ligne consommera environ 50 MB. Voulez-vous continuer ?'**
  String get settingsOfflineModeMessage;

  /// No description provided for @settingsDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement des données en cours...'**
  String get settingsDownloading;

  /// No description provided for @settingsDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get settingsDownload;

  /// No description provided for @settingsClearCacheTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache'**
  String get settingsClearCacheTitle;

  /// No description provided for @settingsClearCacheMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action supprimera toutes les images en cache ({size}). Elles seront retéléchargées lors du prochain usage.'**
  String settingsClearCacheMessage(String size);

  /// No description provided for @settingsCacheCleared.
  ///
  /// In fr, this message translates to:
  /// **'Cache vidé avec succès'**
  String get settingsCacheCleared;

  /// No description provided for @settingsClearCacheError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du vidage: {error}'**
  String settingsClearCacheError(String error);

  /// No description provided for @settingsClear.
  ///
  /// In fr, this message translates to:
  /// **'Vider'**
  String get settingsClear;

  /// No description provided for @settingsOfflineMapsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cartes hors ligne'**
  String get settingsOfflineMapsTitle;

  /// No description provided for @settingsOfflineMapsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les cartes de Djibouti pour les utiliser sans connexion Internet (200 MB).'**
  String get settingsOfflineMapsMessage;

  /// No description provided for @settingsMapsDownloadStarted.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement des cartes démarré'**
  String get settingsMapsDownloadStarted;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Visit Djibouti respecte votre vie privée. Nous collectons uniquement les données nécessaires au fonctionnement de l\'application : localisation pour les POIs proches, préférences utilisateur, et données de réservation.\n\nVos données ne sont jamais partagées avec des tiers sans votre consentement.'**
  String get settingsPrivacyMessage;

  /// No description provided for @settingsUnderstood.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get settingsUnderstood;

  /// No description provided for @settingsTermsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get settingsTermsTitle;

  /// No description provided for @settingsTermsMessage.
  ///
  /// In fr, this message translates to:
  /// **'En utilisant Visit Djibouti, vous acceptez nos conditions d\'utilisation. Cette application est fournie par l\'Office du Tourisme de Djibouti pour promouvoir le tourisme local.\n\nL\'utilisation est gratuite et les informations sont mises à jour régulièrement.'**
  String get settingsTermsMessage;

  /// No description provided for @settingsClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get settingsClose;

  /// No description provided for @settingsBackupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get settingsBackupTitle;

  /// No description provided for @settingsBackupMessage.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder vos favoris, réservations et préférences dans le cloud ?'**
  String get settingsBackupMessage;

  /// No description provided for @settingsBackupSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde réussie'**
  String get settingsBackupSuccess;

  /// No description provided for @settingsSave.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get settingsSave;

  /// No description provided for @settingsResetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer paramètres'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action remettra tous les paramètres par défaut. Vos favoris et réservations seront conservés.'**
  String get settingsResetMessage;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres restaurés'**
  String get settingsResetSuccess;

  /// No description provided for @settingsRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get settingsRestore;

  /// No description provided for @offlineStatusOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne - Toutes les fonctionnalités disponibles'**
  String get offlineStatusOnline;

  /// No description provided for @offlineStatusOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne - Mode cache activé'**
  String get offlineStatusOffline;

  /// No description provided for @offlineDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données hors ligne'**
  String get offlineDataTitle;

  /// No description provided for @offlineTotalItems.
  ///
  /// In fr, this message translates to:
  /// **'Éléments total'**
  String get offlineTotalItems;

  /// No description provided for @offlinePois.
  ///
  /// In fr, this message translates to:
  /// **'Points d\'intérêt'**
  String get offlinePois;

  /// No description provided for @offlineEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get offlineEvents;

  /// No description provided for @offlineFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get offlineFavorites;

  /// No description provided for @offlineCacheSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille du cache'**
  String get offlineCacheSize;

  /// No description provided for @offlineActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get offlineActionsTitle;

  /// No description provided for @offlineSyncNow.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser maintenant'**
  String get offlineSyncNow;

  /// No description provided for @offlineSyncNowSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour les données depuis le serveur'**
  String get offlineSyncNowSubtitle;

  /// No description provided for @offlineDownloadForOffline.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger pour hors ligne'**
  String get offlineDownloadForOffline;

  /// No description provided for @offlineDownloadForOfflineSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger toutes les données importantes'**
  String get offlineDownloadForOfflineSubtitle;

  /// No description provided for @offlineClearCache.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache'**
  String get offlineClearCache;

  /// No description provided for @offlineClearCacheSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer toutes les données mises en cache'**
  String get offlineClearCacheSubtitle;

  /// No description provided for @reviewFormPleaseRate.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une note'**
  String get reviewFormPleaseRate;

  /// No description provided for @reviewFormUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Avis modifié avec succès'**
  String get reviewFormUpdated;

  /// No description provided for @reviewFormPublished.
  ///
  /// In fr, this message translates to:
  /// **'Avis publié avec succès'**
  String get reviewFormPublished;

  /// No description provided for @reviewFormError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String reviewFormError(String error);

  /// No description provided for @reviewFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier votre avis'**
  String get reviewFormEditTitle;

  /// No description provided for @reviewFormWriteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un avis'**
  String get reviewFormWriteTitle;

  /// No description provided for @reviewFormYourRating.
  ///
  /// In fr, this message translates to:
  /// **'Votre note *'**
  String get reviewFormYourRating;

  /// No description provided for @reviewFormTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre (optionnel)'**
  String get reviewFormTitle;

  /// No description provided for @reviewFormTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Résumez votre expérience'**
  String get reviewFormTitleHint;

  /// No description provided for @reviewFormComment.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis (optionnel)'**
  String get reviewFormComment;

  /// No description provided for @reviewFormCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre expérience en détail...'**
  String get reviewFormCommentHint;

  /// No description provided for @reviewFormUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get reviewFormUpdate;

  /// No description provided for @reviewFormPublish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get reviewFormPublish;

  /// No description provided for @reviewsBeFirst.
  ///
  /// In fr, this message translates to:
  /// **'Soyez le premier à donner votre avis'**
  String get reviewsBeFirst;

  /// No description provided for @reviewsNoReviewsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun avis pour le moment'**
  String get reviewsNoReviewsYet;

  /// No description provided for @reviewsClickToReview.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez pour laisser un avis'**
  String get reviewsClickToReview;

  /// No description provided for @reviewsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get reviewsTitle;

  /// No description provided for @reviewsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} avis'**
  String reviewsCount(int count);

  /// No description provided for @reviewsLoadMore.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus d\'avis'**
  String get reviewsLoadMore;

  /// No description provided for @reviewsOperatorResponse.
  ///
  /// In fr, this message translates to:
  /// **'Réponse de l\'établissement'**
  String get reviewsOperatorResponse;

  /// No description provided for @reviewsHelpful.
  ///
  /// In fr, this message translates to:
  /// **'Utile'**
  String get reviewsHelpful;

  /// No description provided for @reviewsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement avis: {error}'**
  String reviewsLoadError(String error);

  /// No description provided for @reviewsVotedHelpful.
  ///
  /// In fr, this message translates to:
  /// **'Merci pour votre vote !'**
  String get reviewsVotedHelpful;

  /// No description provided for @reviewsVoteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String reviewsVoteError(String error);

  /// No description provided for @reviewsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'avis'**
  String get reviewsDeleteTitle;

  /// No description provided for @reviewsDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer cet avis ?'**
  String get reviewsDeleteConfirm;

  /// No description provided for @reviewsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get reviewsDelete;

  /// No description provided for @reviewsDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Avis supprimé'**
  String get reviewsDeleted;

  /// No description provided for @reviewsDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String reviewsDeleteError(String error);

  /// No description provided for @reviewsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get reviewsSectionTitle;

  /// No description provided for @reviewsWriteReview.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un avis'**
  String get reviewsWriteReview;

  /// No description provided for @reservationFormTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réserver {type}'**
  String reservationFormTitle(String type);

  /// No description provided for @reservationFormTitlePoi.
  ///
  /// In fr, this message translates to:
  /// **'ce lieu'**
  String get reservationFormTitlePoi;

  /// No description provided for @reservationFormTitleEvent.
  ///
  /// In fr, this message translates to:
  /// **'cet événement'**
  String get reservationFormTitleEvent;

  /// No description provided for @reservationFormNumberOfPeople.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes *'**
  String get reservationFormNumberOfPeople;

  /// No description provided for @reservationFormNumberOfPeopleHint.
  ///
  /// In fr, this message translates to:
  /// **'1'**
  String get reservationFormNumberOfPeopleHint;

  /// No description provided for @reservationFormNumberRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes requis'**
  String get reservationFormNumberRequired;

  /// No description provided for @reservationFormMinOnePerson.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 1 personne'**
  String get reservationFormMinOnePerson;

  /// No description provided for @reservationFormMaxPeople.
  ///
  /// In fr, this message translates to:
  /// **'Maximum {available} places disponibles'**
  String reservationFormMaxPeople(String available);

  /// No description provided for @reservationFormContactInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations de contact (optionnel)'**
  String get reservationFormContactInfo;

  /// No description provided for @reservationFormFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get reservationFormFullName;

  /// No description provided for @reservationFormEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get reservationFormEmailInvalid;

  /// No description provided for @reservationFormPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get reservationFormPhone;

  /// No description provided for @reservationFormNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes ou demandes spéciales'**
  String get reservationFormNotes;

  /// No description provided for @reservationFormNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Allergies alimentaires, besoins spéciaux...'**
  String get reservationFormNotesHint;

  /// No description provided for @reservationFormConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la réservation'**
  String get reservationFormConfirm;

  /// No description provided for @reservationFormSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Réservation créée avec succès!'**
  String get reservationFormSuccess;

  /// No description provided for @reservationFormError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la réservation'**
  String get reservationFormError;

  /// No description provided for @contactOperatorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacter {name}'**
  String contactOperatorTitle(String name);

  /// No description provided for @contactOperatorTitleDefault.
  ///
  /// In fr, this message translates to:
  /// **'l\'opérateur'**
  String get contactOperatorTitleDefault;

  /// No description provided for @contactOperatorMessageType.
  ///
  /// In fr, this message translates to:
  /// **'Type de message'**
  String get contactOperatorMessageType;

  /// No description provided for @contactOperatorYourMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre message'**
  String get contactOperatorYourMessage;

  /// No description provided for @contactOperatorMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez votre message ici...'**
  String get contactOperatorMessageHint;

  /// No description provided for @contactOperatorMessageRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez écrire un message'**
  String get contactOperatorMessageRequired;

  /// No description provided for @contactOperatorMessageTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le message doit contenir au moins 3 caractères'**
  String get contactOperatorMessageTooShort;

  /// No description provided for @contactOperatorTypeQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Question'**
  String get contactOperatorTypeQuestion;

  /// No description provided for @contactOperatorTypeReport.
  ///
  /// In fr, this message translates to:
  /// **'Signalement'**
  String get contactOperatorTypeReport;

  /// No description provided for @contactOperatorTypeSuggestion.
  ///
  /// In fr, this message translates to:
  /// **'Suggestion'**
  String get contactOperatorTypeSuggestion;

  /// No description provided for @contactOperatorPrefixQuestion.
  ///
  /// In fr, this message translates to:
  /// **'❓ Question: '**
  String get contactOperatorPrefixQuestion;

  /// No description provided for @contactOperatorPrefixReport.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ Signalement: '**
  String get contactOperatorPrefixReport;

  /// No description provided for @contactOperatorPrefixSuggestion.
  ///
  /// In fr, this message translates to:
  /// **'💡 Suggestion: '**
  String get contactOperatorPrefixSuggestion;

  /// No description provided for @contactOperatorMessageSent.
  ///
  /// In fr, this message translates to:
  /// **'Message envoyé avec succès à {name}'**
  String contactOperatorMessageSent(String name);

  /// No description provided for @contactOperatorMessageSentDefault.
  ///
  /// In fr, this message translates to:
  /// **'l\'opérateur'**
  String get contactOperatorMessageSentDefault;

  /// No description provided for @contactOperatorSendError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'envoi: {error}'**
  String contactOperatorSendError(String error);

  /// No description provided for @tourOperatorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur inconnu'**
  String get tourOperatorUnknown;

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

  /// No description provided for @poiOperatorsServingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Opérateurs desservant ce lieu'**
  String get poiOperatorsServingTitle;

  /// No description provided for @activitiesSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une activité...'**
  String get activitiesSearchHint;

  /// No description provided for @toursSelectDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une difficulté'**
  String get toursSelectDifficulty;

  /// No description provided for @termsLastUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour : 23 octobre 2025'**
  String get termsLastUpdated;

  /// No description provided for @termsSection1Title.
  ///
  /// In fr, this message translates to:
  /// **'1. Acceptation des conditions'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Content.
  ///
  /// In fr, this message translates to:
  /// **'En utilisant l\'application Visit Djibouti (ci-après \"l\'Application\"), vous acceptez d\'être lié par les présentes conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'Application.'**
  String get termsSection1Content;

  /// No description provided for @termsSection2Title.
  ///
  /// In fr, this message translates to:
  /// **'2. Description des services'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Content.
  ///
  /// In fr, this message translates to:
  /// **'Visit Djibouti est une application mobile dédiée à la promotion du tourisme à Djibouti. L\'Application fournit:\n\n• Des informations sur les points d\'intérêt touristiques\n• Un calendrier d\'événements culturels et touristiques\n• Un système de réservation pour certains services\n• Des fonctionnalités de favoris et de planification de voyage\n• Des cartes interactives et des outils de navigation\n• Des informations pratiques sur le pays'**
  String get termsSection2Content;

  /// No description provided for @termsSection3Title.
  ///
  /// In fr, this message translates to:
  /// **'3. Compte utilisateur'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Content.
  ///
  /// In fr, this message translates to:
  /// **'L\'utilisation de certaines fonctionnalités nécessite la création d\'un compte. Vous êtes responsable:\n\n• De la confidentialité de vos identifiants\n• De toutes les activités effectuées via votre compte\n• De l\'exactitude des informations fournies\n• De nous informer immédiatement en cas d\'utilisation non autorisée'**
  String get termsSection3Content;

  /// No description provided for @termsSection4Title.
  ///
  /// In fr, this message translates to:
  /// **'4. Utilisation acceptable'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Content.
  ///
  /// In fr, this message translates to:
  /// **'Vous vous engagez à:\n\n• Utiliser l\'Application uniquement à des fins légales\n• Ne pas publier de contenu offensant ou illégal\n• Respecter les droits d\'autrui\n• Ne pas tenter de perturber le fonctionnement de l\'Application\n• Ne pas utiliser de robots ou de scripts automatisés\n• Ne pas collecter les données d\'autres utilisateurs'**
  String get termsSection4Content;

  /// No description provided for @termsSection5Title.
  ///
  /// In fr, this message translates to:
  /// **'5. Propriété intellectuelle'**
  String get termsSection5Title;

  /// No description provided for @termsSection5Content.
  ///
  /// In fr, this message translates to:
  /// **'Tous les contenus de l\'Application (textes, images, logos, graphiques) sont protégés par les lois sur la propriété intellectuelle et appartiennent à l\'Office du Tourisme de Djibouti ou à ses partenaires.'**
  String get termsSection5Content;

  /// No description provided for @termsSection6Title.
  ///
  /// In fr, this message translates to:
  /// **'6. Réservations et paiements'**
  String get termsSection6Title;

  /// No description provided for @termsSection6Content.
  ///
  /// In fr, this message translates to:
  /// **'L\'Application permet de réserver certains services touristiques:\n\n• Les réservations sont soumises à disponibilité\n• Les prix affichés sont indicatifs et peuvent varier\n• Les conditions d\'annulation varient selon le prestataire\n• L\'Office du Tourisme agit comme intermédiaire\n• Nous ne sommes pas responsables des services fournis par des tiers'**
  String get termsSection6Content;

  /// No description provided for @termsSection7Title.
  ///
  /// In fr, this message translates to:
  /// **'7. Limitation de responsabilité'**
  String get termsSection7Title;

  /// No description provided for @termsSection7Content.
  ///
  /// In fr, this message translates to:
  /// **'L\'Office du Tourisme de Djibouti:\n\n• S\'efforce de fournir des informations exactes mais ne garantit pas leur exhaustivité\n• N\'est pas responsable des services fournis par des tiers\n• Ne peut être tenu responsable des dommages indirects\n• Se réserve le droit de modifier ou interrompre les services sans préavis\n• N\'est pas responsable des problèmes techniques ou de connexion'**
  String get termsSection7Content;

  /// No description provided for @termsSection8Title.
  ///
  /// In fr, this message translates to:
  /// **'8. Contenu utilisateur'**
  String get termsSection8Title;

  /// No description provided for @termsSection8Content.
  ///
  /// In fr, this message translates to:
  /// **'En publiant du contenu (avis, commentaires, photos):\n\n• Vous conservez vos droits de propriété intellectuelle\n• Vous nous accordez une licence d\'utilisation gratuite et mondiale\n• Vous garantissez que le contenu ne viole aucun droit\n• Nous nous réservons le droit de modérer ou supprimer tout contenu inapproprié'**
  String get termsSection8Content;

  /// No description provided for @termsSection9Title.
  ///
  /// In fr, this message translates to:
  /// **'9. Liens vers des sites tiers'**
  String get termsSection9Title;

  /// No description provided for @termsSection9Content.
  ///
  /// In fr, this message translates to:
  /// **'L\'Application peut contenir des liens vers des sites web tiers. Ces liens sont fournis pour votre commodité, mais nous n\'avons aucun contrôle sur ces sites et n\'assumons aucune responsabilité quant à leur contenu.'**
  String get termsSection9Content;

  /// No description provided for @termsSection10Title.
  ///
  /// In fr, this message translates to:
  /// **'10. Modifications du service'**
  String get termsSection10Title;

  /// No description provided for @termsSection10Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous nous réservons le droit de:\n\n• Modifier ou interrompre tout ou partie de l\'Application\n• Ajouter ou retirer des fonctionnalités\n• Changer les prix ou conditions d\'accès'**
  String get termsSection10Content;

  /// No description provided for @termsSection11Title.
  ///
  /// In fr, this message translates to:
  /// **'11. Résiliation'**
  String get termsSection11Title;

  /// No description provided for @termsSection11Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous pouvons suspendre ou résilier votre accès à l\'Application en cas de:\n\n• Violation des présentes conditions\n• Comportement frauduleux ou abusif\n• Demande des autorités compétentes\n• Inactivité prolongée'**
  String get termsSection11Content;

  /// No description provided for @termsSection12Title.
  ///
  /// In fr, this message translates to:
  /// **'12. Droit applicable'**
  String get termsSection12Title;

  /// No description provided for @termsSection12Content.
  ///
  /// In fr, this message translates to:
  /// **'Ces conditions sont régies par le droit djiboutien. Tout litige sera soumis à la compétence exclusive des tribunaux de Djibouti.'**
  String get termsSection12Content;

  /// No description provided for @termsSection13Title.
  ///
  /// In fr, this message translates to:
  /// **'13. Modifications des conditions'**
  String get termsSection13Title;

  /// No description provided for @termsSection13Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous pouvons modifier ces conditions à tout moment. Les modifications seront publiées dans l\'Application et prendront effet immédiatement. Votre utilisation continue de l\'Application constitue votre acceptation des conditions modifiées.'**
  String get termsSection13Content;

  /// No description provided for @termsSection14Title.
  ///
  /// In fr, this message translates to:
  /// **'14. Contact'**
  String get termsSection14Title;

  /// No description provided for @termsSection14Content.
  ///
  /// In fr, this message translates to:
  /// **'Pour toute question concernant ces conditions d\'utilisation, contactez-nous:\n\nOffice du Tourisme de Djibouti\nEmail: info@visitdjibouti.dj\nTéléphone: +253 XXX XXX'**
  String get termsSection14Content;

  /// No description provided for @activitiesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activités'**
  String get activitiesTitle;

  /// No description provided for @activitiesPopular.
  ///
  /// In fr, this message translates to:
  /// **'Activités populaires'**
  String get activitiesPopular;

  /// No description provided for @activitiesDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get activitiesDifficulty;

  /// No description provided for @activitiesRegion.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get activitiesRegion;

  /// No description provided for @activitiesAvailableSpotsOnly.
  ///
  /// In fr, this message translates to:
  /// **'Seulement avec places disponibles'**
  String get activitiesAvailableSpotsOnly;

  /// No description provided for @activitiesAvailableSpots.
  ///
  /// In fr, this message translates to:
  /// **'Places disponibles'**
  String get activitiesAvailableSpots;

  /// No description provided for @activitiesNoActivitiesFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité trouvée'**
  String get activitiesNoActivitiesFound;

  /// No description provided for @activitiesTryModifyingFilters.
  ///
  /// In fr, this message translates to:
  /// **'Essayez de modifier vos filtres'**
  String get activitiesTryModifyingFilters;
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
