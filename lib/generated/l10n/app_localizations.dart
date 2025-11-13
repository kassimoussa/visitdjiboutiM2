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
  /// **'Annulées ({count})'**
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
