// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Visit Djibouti';

  @override
  String get appDescription => 'Découvrez les merveilles de Djibouti';

  @override
  String get navigationHome => 'Accueil';

  @override
  String get navigationDiscover => 'Découvrir';

  @override
  String get navigationEvents => 'Événements';

  @override
  String get navigationMap => 'Carte';

  @override
  String get navigationFavorites => 'Favoris';

  @override
  String get homeWelcomeMessage => 'Bienvenue à Djibouti';

  @override
  String get homeFeaturedPois => 'Lieux à découvrir';

  @override
  String get homeUpcomingEvents => 'Événements à venir';

  @override
  String get homeExploreMore => 'Explorer plus';

  @override
  String get homeDiscoverByRegion => 'Découvrir par région';

  @override
  String get homeDiscoverByRegionSubtitle => 'Appuyez pour explorer';

  @override
  String get homeEssentials => 'Essentiels';

  @override
  String get homeDiscover => 'Découvrir';

  @override
  String get discoverTitle => 'Découvrir Djibouti';

  @override
  String get discoverCategories => 'Catégories';

  @override
  String get discoverAllPois => 'Tous les lieux';

  @override
  String get discoverSearchHint => 'Rechercher un lieu...';

  @override
  String get discoverNearbyPois => 'Lieux à proximité';

  @override
  String get discoverNoResults => 'Aucun résultat trouvé';

  @override
  String get eventsTitle => 'Événements';

  @override
  String get eventsUpcoming => 'À venir';

  @override
  String get eventsOngoing => 'En cours';

  @override
  String get eventsPast => 'Terminés';

  @override
  String get eventsRegister => 'S\'inscrire';

  @override
  String get eventsRegistered => 'Inscrit';

  @override
  String get eventsSoldOut => 'Complet';

  @override
  String get eventsEnded => 'Terminé';

  @override
  String get eventsFree => 'Gratuit';

  @override
  String eventsPrice(String price) {
    return '$price DJF';
  }

  @override
  String eventsParticipants(int count) {
    return '$count participants';
  }

  @override
  String get favoritesTitle => 'Mes Favoris';

  @override
  String get favoritesEmpty => 'Aucun favori';

  @override
  String get favoritesEmptyDescription =>
      'Explorez Djibouti et ajoutez vos lieux\\npréférés à votre collection';

  @override
  String get favoritesAddedToFavorites => 'Ajouté aux favoris';

  @override
  String get favoritesRemovedFromFavorites => 'Supprimé des favoris';

  @override
  String get favoritesPoisTab => 'Lieux';

  @override
  String get favoritesEventsTab => 'Événements';

  @override
  String get favoritesAllTab => 'Tous';

  @override
  String get favoritesSortRecent => 'Récent';

  @override
  String get favoritesSortAlphabetical => 'Alphabétique';

  @override
  String get favoritesSortRating => 'Note';

  @override
  String get mapTitle => 'Carte';

  @override
  String get mapMyLocation => 'Ma position';

  @override
  String get mapSearchLocation => 'Rechercher un lieu...';

  @override
  String get mapRouteTo => 'Itinéraire vers';

  @override
  String mapDistance(String distance) {
    return '$distance km';
  }

  @override
  String get authLogin => 'Connexion';

  @override
  String get authRegister => 'S\'inscrire';

  @override
  String get authLogout => 'Déconnexion';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authName => 'Nom complet';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authDontHaveAccount => 'Pas de compte ?';

  @override
  String get authAlreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get authSignInWithGoogle => 'Continuer avec Google';

  @override
  String get authSignInWithFacebook => 'Continuer avec Facebook';

  @override
  String get authOrContinueWith => 'Ou continuer avec';

  @override
  String get authTermsAndConditions => 'Conditions d\'utilisation';

  @override
  String get authPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get authAcceptTerms => 'J\'accepte les';

  @override
  String get authAcceptTermsAnd => 'et la';

  @override
  String get authCreateAccount => 'Créer mon compte';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authNoAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get authResetPassword => 'Réinitialiser le mot de passe';

  @override
  String get authResetPasswordTitle => 'Mot de passe oublié';

  @override
  String get authResetPasswordSubtitle =>
      'Entrez votre email pour recevoir un lien de réinitialisation';

  @override
  String get authSendResetLink => 'Envoyer le lien';

  @override
  String get authResetEmailSent => 'Email de réinitialisation envoyé';

  @override
  String get authResetEmailSentMessage =>
      'Vérifiez votre boîte mail pour réinitialiser votre mot de passe';

  @override
  String get authBackToLogin => 'Retour à la connexion';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileAboutApp => 'À propos';

  @override
  String get profileContactSupport => 'Support';

  @override
  String get conversionAfterFavoritesTitle => 'Sauvegardez vos découvertes !';

  @override
  String get conversionAfterFavoritesDescription =>
      'Créez votre compte pour synchroniser vos favoris sur tous vos appareils';

  @override
  String get conversionAfterFavoritesButton => 'Sauvegarder mes favoris';

  @override
  String get conversionBeforeReservationTitle => 'Finalisez votre inscription';

  @override
  String get conversionBeforeReservationDescription =>
      'Un compte est requis pour finaliser votre réservation d\'événement';

  @override
  String get conversionBeforeReservationButton => 'Créer un compte';

  @override
  String get conversionBeforeExportTitle =>
      'Recevez votre itinéraire par email';

  @override
  String get conversionBeforeExportDescription =>
      'Créez votre compte pour recevoir votre itinéraire personnalisé par email';

  @override
  String get conversionBeforeExportButton => 'Recevoir par email';

  @override
  String get conversionAfterWeekUsageTitle => 'Créez votre profil voyageur';

  @override
  String get conversionAfterWeekUsageDescription =>
      'Après une semaine d\'exploration, créez votre profil pour une expérience personnalisée';

  @override
  String get conversionAfterWeekUsageButton => 'Créer mon profil';

  @override
  String get conversionBenefits => 'Avec un compte, vous pourrez :';

  @override
  String get conversionBenefitSync =>
      'Synchroniser vos favoris sur tous vos appareils';

  @override
  String get conversionBenefitNotifications =>
      'Recevoir des notifications pour vos lieux préférés';

  @override
  String get conversionBenefitItineraries =>
      'Créer des itinéraires personnalisés';

  @override
  String get conversionBenefitReservations =>
      'Gérer toutes vos réservations en un endroit';

  @override
  String get conversionBenefitHistory =>
      'Accéder à votre historique de réservations';

  @override
  String get conversionBenefitEmail => 'Recevoir vos itinéraires par email';

  @override
  String get conversionBenefitShare => 'Partager vos découvertes avec vos amis';

  @override
  String get conversionBenefitRecommendations =>
      'Obtenir des recommandations personnalisées';

  @override
  String get conversionBenefitOffers => 'Accéder à des offres exclusives';

  @override
  String get conversionBenefitCommunity =>
      'Participer à la communauté de voyageurs';

  @override
  String get conversionLaterButton => 'Plus tard';

  @override
  String get conversionContinueWithoutAccount => 'Continuer sans compte';

  @override
  String get conversionNotNowButton => 'Pas maintenant';

  @override
  String get conversionMaybeLaterButton => 'Peut-être plus tard';

  @override
  String get conversionCancelButton => 'Annuler';

  @override
  String get drawerGuest => 'Invité';

  @override
  String get drawerViewProfile => 'Voir mon profil →';

  @override
  String get drawerProfile => 'Profil';

  @override
  String get drawerReservations => 'Mes Réservations';

  @override
  String get drawerReservationsSubtitle => 'Gérer vos réservations';

  @override
  String get drawerOfflineMode => 'Mode hors ligne';

  @override
  String get drawerSettingsSection => 'Paramètres';

  @override
  String get drawerTestApi => 'Test API';

  @override
  String get drawerTestApiSubtitle => 'Test des endpoints';

  @override
  String get drawerSettings => 'Paramètres';

  @override
  String get drawerLanguage => 'Langue';

  @override
  String get drawerNotifications => 'Notifications';

  @override
  String get drawerHelpSection => 'Aide & Support';

  @override
  String get drawerHelp => 'Aide';

  @override
  String get drawerFeedback => 'Commentaires';

  @override
  String get drawerAbout => 'À propos';

  @override
  String get drawerUsefulLinks => 'Liens utiles';

  @override
  String get drawerTourismOffice => 'Office du Tourisme';

  @override
  String get drawerEmbassies => 'Ambassades';

  @override
  String get drawerEmergencyNumbers => 'Numéros d\'urgence';

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
  String get drawerVersion => 'Version 1.0.0';

  @override
  String get drawerChooseLanguage => 'Choisir la langue';

  @override
  String drawerLanguageChanged(String language) {
    return 'Langue changée vers $language';
  }

  @override
  String get drawerSendFeedback => 'Envoyer un commentaire';

  @override
  String get drawerFeedbackHint =>
      'Partagez votre expérience avec Visit Djibouti...';

  @override
  String get drawerFeedbackThanks => 'Merci pour vos commentaires !';

  @override
  String get drawerPolice => '🚨 Police: 17';

  @override
  String get drawerFire => '🚒 Pompiers: 18';

  @override
  String get drawerSamu => '🏥 SAMU: 351351';

  @override
  String get drawerMedical => '🚑 Urgences médicales: 35 35 35';

  @override
  String get drawerInfo => '📞 Renseignements: 12';

  @override
  String get drawerTourismOfficeSnackbar =>
      'Ouverture du site web de l\'Office du Tourisme';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonError => 'Erreur';

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
  String get commonRetry => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonSave => 'Sauvegarder';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonPrevious => 'Précédent';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonAll => 'Tout';

  @override
  String get commonSeeAll => 'Voir tout';

  @override
  String get commonShowMore => 'Voir plus';

  @override
  String get commonShowLess => 'Voir moins';

  @override
  String get commonSend => 'Envoyer';

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
  String get authSuccessTitle => 'Connexion réussie !';

  @override
  String get authErrorTitle => 'Erreur';

  @override
  String get authSignUpSuccessTitle => 'Inscription réussie';

  @override
  String get authConversionProblemTitle => 'Problème de conversion';

  @override
  String get authKeepDiscoveries => 'Créez votre compte Visit Djibouti';

  @override
  String get authWelcomeToApp => 'Créez votre compte Visit Djibouti';

  @override
  String get authCreateAccountDescription =>
      'Découvrez tout ce que Djibouti a à offrir avec votre compte personnalisé';

  @override
  String get authDataPreserved => 'Vos données actuelles seront préservées';

  @override
  String get authKeepingDataInfo => '✨ En créant votre compte, vous gardez :';

  @override
  String get authCurrentFavorites => 'Tous vos favoris actuels';

  @override
  String get authPreferences => 'Vos préférences';

  @override
  String get authBrowsingHistory => 'Votre historique de navigation';

  @override
  String get authDiscoveredPlaces => 'Vos lieux découverts';

  @override
  String get aboutPageDescription =>
      'Visit Djibouti est l\'application officielle du tourisme djiboutien. Découvrez les sites exceptionnels, événements culturels et expériences uniques que notre pays a à offrir. Des paysages volcaniques aux fonds marins préservés, en passant par notre riche patrimoine culturel, explorez Djibouti comme jamais auparavant.';

  @override
  String get aboutPointsOfInterest => 'Points d\'Intérêt';

  @override
  String get aboutEvents => 'Événements';

  @override
  String get aboutTourismOffice => 'Office du Tourisme de Djibouti';

  @override
  String get aboutTourismOfficeSubtitle =>
      'Organisme officiel de promotion touristique';

  @override
  String get aboutMinistry => 'Ministère du Commerce et du Tourisme';

  @override
  String get aboutMinistrySubtitle => 'République de Djibouti';

  @override
  String get aboutHotelsAssociation => 'Association des Hôteliers';

  @override
  String get aboutHotelsAssociationSubtitle => 'Secteur privé du tourisme';

  @override
  String get helpHowCanWeHelp => 'Comment pouvons-nous vous aider ?';

  @override
  String get helpSearchPlaceholder => 'Rechercher dans l\'aide...';

  @override
  String get helpContactUs => 'Nous contacter';

  @override
  String get helpLiveChat => 'Chat en direct';

  @override
  String get helpConnectingToChat => 'Connexion au chat en cours...';

  @override
  String get helpStartChat => 'Démarrer le chat';

  @override
  String get helpSubject => 'Sujet';

  @override
  String get helpMessage => 'Votre message';

  @override
  String get helpEmailOptional => 'Votre email (optionnel)';

  @override
  String get helpProblemTitle => 'Titre du problème';

  @override
  String get helpMessageSentSuccess => 'Message envoyé avec succès !';

  @override
  String get helpHowToUseMap => 'Comment utiliser la carte';

  @override
  String get helpBookEvent => 'Réserver un événement';

  @override
  String get helpManageFavorites => 'Gérer ses favoris';

  @override
  String get helpDescribeProblem => 'Décrivez le problème rencontré...';

  @override
  String get helpDuration3Min => '3 min';

  @override
  String get helpDuration2Min => '2 min';

  @override
  String get helpDuration1Min => '1 min';

  @override
  String get embassiesTitle => 'Ambassades';

  @override
  String get embassiesCall => 'Appeler';

  @override
  String get embassiesEmail => 'Email';

  @override
  String get embassiesWebsite => 'Site web';

  @override
  String get embassiesCannotOpenPhone =>
      'Impossible d\'ouvrir l\'application téléphone';

  @override
  String get embassiesCannotOpenEmail =>
      'Impossible d\'ouvrir l\'application email';

  @override
  String get embassiesCannotOpenWebsite => 'Impossible d\'ouvrir le site web';

  @override
  String get embassiesNoForeignFound => 'Aucune ambassade étrangère trouvée';

  @override
  String get embassiesNoForeignSubtitle =>
      'Les informations des ambassades ne sont pas encore disponibles';

  @override
  String get embassiesNoDjiboutianFound =>
      'Aucune ambassade djiboutienne trouvée';

  @override
  String get embassiesNoDjiboutianSubtitle =>
      'Les informations des ambassades djiboutiennes ne sont pas encore disponibles';

  @override
  String get essentialsTitle => 'Infos Essentielles';

  @override
  String get essentialsUnavailableInfo => 'Informations indisponibles';

  @override
  String get essentialsNoLinksAvailable => 'Aucun lien disponible';

  @override
  String get eventDetailErrorLoading => 'Erreur lors du chargement des détails';

  @override
  String get eventDetailRegistrationConfirmed => 'Inscription confirmée !';

  @override
  String eventDetailReservationNumber(String number) {
    return 'Numéro de réservation: $number';
  }

  @override
  String eventDetailSpecialRequirements(String requirements) {
    return 'Exigences spéciales';
  }

  @override
  String get eventDetailParticipantsLabel => 'participants';

  @override
  String get eventDetailFullNameLabel => 'Nom complet';

  @override
  String get eventDetailEmailLabel => 'Email';

  @override
  String get eventDetailPhoneLabel => 'Téléphone';

  @override
  String get eventDetailSpecialRequirementsLabel =>
      'Exigences spéciales (optionnel)';

  @override
  String get eventDetailSpecialRequirementsHint =>
      'Allergies, besoins d\'accessibilité, etc.';

  @override
  String get commonOk => 'OK';

  @override
  String get commonConnectionError => 'Erreur de connexion';

  @override
  String get commonNoNavigationApp =>
      'Aucune application de navigation trouvée';

  @override
  String get commonUnknownPlace => 'Lieu inconnu';

  @override
  String get commonUnknown => 'Inconnue';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonOverview => 'Aperçu';

  @override
  String get commonDiscoverPlace => 'Découvrez ce lieu unique à';

  @override
  String get commonExploreOnSite =>
      'Explorez ses particularités en visitant sur place.';

  @override
  String get commonLocation => 'Localisation';

  @override
  String get commonAddress => 'Adresse';

  @override
  String get commonCoordinates => 'Coordonnées';

  @override
  String get commonPracticalInfo => 'Informations pratiques';

  @override
  String get commonOpeningHours => 'Horaires';

  @override
  String get commonEntryPrice => 'Prix d\'entrée';

  @override
  String get commonWebsite => 'Site web';

  @override
  String get commonReservationsAccepted => 'Réservations acceptées';

  @override
  String get commonCategories => 'Catégories';

  @override
  String get commonCategory => 'Catégorie';

  @override
  String get commonVisitorTips => 'Conseils aux visiteurs';

  @override
  String get commonContact => 'Contact';

  @override
  String get commonReservePlace => 'Réserver ce lieu';

  @override
  String get commonSharePlace => 'Partager ce lieu';

  @override
  String get commonSharedFrom => 'Partagé depuis Visit Djibouti';

  @override
  String get commonCopiedToClipboard =>
      'Informations copiées dans le presse-papier !';

  @override
  String get commonPhone => 'Téléphone';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonEvent => 'Événement';

  @override
  String get commonUnknownEvent => 'Événement inconnu';

  @override
  String get commonInformations => 'Informations';

  @override
  String get commonDate => 'Date';

  @override
  String get commonFieldRequired => 'Ce champ est requis';

  @override
  String get eventDetailRegistrationNumber => 'Numéro de réservation';

  @override
  String get eventDetailParticipants => 'Participants';

  @override
  String get eventDetailEventEnded => 'Cet événement est terminé';

  @override
  String get eventDetailEventFull => 'Événement complet';

  @override
  String get eventDetailSpotsRemaining => 'places restantes';

  @override
  String get eventDetailReserveEvent => 'Réserver pour cet événement';

  @override
  String get eventDetailReservationsClosed => 'Réservations fermées';

  @override
  String get eventDetailDetailsUnavailable =>
      'Certains détails peuvent être indisponibles';

  @override
  String get eventDetailPopular => 'Populaire';

  @override
  String get eventDetailFree => 'Gratuit';

  @override
  String get eventDetailEndDate => 'Date de fin';

  @override
  String get eventDetailVenue => 'Lieu';

  @override
  String get eventDetailPrice => 'Prix';

  @override
  String get eventDetailRegistration => 'Inscription';

  @override
  String get eventDetailParticipantsCount => 'Nombre de participants';

  @override
  String get eventDetailInvalidNumber => 'Nombre invalide';

  @override
  String get eventDetailMaxParticipants => 'Maximum';

  @override
  String get eventDetailContactInfo => 'Informations de contact';

  @override
  String get eventDetailFullName => 'Nom complet';

  @override
  String get eventDetailSpecialRequirementsOptional =>
      'Exigences spéciales (optionnel)';

  @override
  String get eventDetailInvalidEmail => 'Email invalide';

  @override
  String get eventDetailTotalToPay => 'Total à payer';

  @override
  String get eventDetailConfirmRegistration => 'Confirmer l\'inscription';

  @override
  String reservationsAll(int count) {
    return 'Toutes ($count)';
  }

  @override
  String reservationsConfirmed(int count) {
    return 'Confirmées ($count)';
  }

  @override
  String reservationsPending(int count) {
    return 'En attente ($count)';
  }

  @override
  String reservationsCancelled(int count) {
    return 'Annulées ($count)';
  }

  @override
  String get reservationsNoneAll => 'Aucune réservation';

  @override
  String get reservationsNoneConfirmed => 'Aucune réservation confirmée';

  @override
  String get reservationsNonePending => 'Aucune réservation en attente';

  @override
  String get reservationsNoneCancelled => 'Aucune réservation annulée';

  @override
  String get reservationsCancelTitle => 'Annuler la réservation';

  @override
  String get reservationsDeleteTitle => 'Supprimer la réservation';

  @override
  String get tourOperatorsNoneFound => 'Aucun opérateur touristique trouvé';

  @override
  String get offlineLoadingSettings => 'Chargement des paramètres...';

  @override
  String get offlineConnectionStatus => 'État de la connexion';

  @override
  String get offlineClearCacheTitle => 'Vider le cache';

  @override
  String get profileUser => 'Utilisateur';

  @override
  String get profileLogoutTitle => 'Déconnexion';

  @override
  String get profilePersonalInfo => 'Informations personnelles';

  @override
  String get profileEditTooltip => 'Modifier';

  @override
  String get profileSecurity => 'Sécurité';

  @override
  String get apiTestTitle => 'Test API POIs';

  @override
  String get discoverClearFilters => 'Effacer les filtres';

  @override
  String get mapSearchHint => 'Rechercher sur la carte...';

  @override
  String get categoryFilterClear => 'Effacer';

  @override
  String get offlineIndicatorConnectionRestored => 'Connexion rétablie !';

  @override
  String get offlineIndicatorOfflineMode => 'Mode hors ligne';

  @override
  String get offlineIndicatorOfflineModeTitle => 'Mode hors ligne';

  @override
  String get reservationFormDateLabel => 'Date *';

  @override
  String get reservationFormDatePlaceholder => 'Sélectionner une date';

  @override
  String get reservationFormTimeLabel => 'Heure';

  @override
  String get reservationFormTimePlaceholder => 'HH:MM';

  @override
  String get reservationFormParticipantsLabel => 'Nombre de personnes *';

  @override
  String get reservationFormParticipantsPlaceholder => '1';

  @override
  String get reservationFormNotesLabel => 'Notes ou demandes spéciales';

  @override
  String get reservationFormNotesPlaceholder =>
      'Allergies alimentaires, besoins spéciaux...';

  @override
  String get reservationFormPleaseSelectDate =>
      'Veuillez sélectionner une date';

  @override
  String reservationFormUnexpectedError(String error) {
    return 'Erreur inattendue: $error';
  }

  @override
  String tourOperatorDetailsSnackbar(String name) {
    return 'Détails de $name';
  }

  @override
  String get tourOperatorCallButton => 'Appeler';

  @override
  String get tourOperatorWebsiteButton => 'Site web';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get eventDetailRegistrationError => 'Erreur lors de l\'inscription';

  @override
  String get commonUnexpectedError => 'Une erreur inattendue s\'est produite';

  @override
  String get operatorFeatured => 'Recommandé';

  @override
  String get operatorLabel => 'Opérateur Touristique';

  @override
  String get operatorAddress => 'Adresse';

  @override
  String get operatorDescription => 'Description';

  @override
  String get operatorContact => 'Contact';

  @override
  String get operatorPhone => 'Téléphone';

  @override
  String get operatorEmail => 'Email';

  @override
  String get operatorWebsite => 'Site web';

  @override
  String get operatorCall => 'Appeler';

  @override
  String get operatorTours => 'Tours proposés';

  @override
  String get operatorSeeAll => 'Voir tout';

  @override
  String get operatorNoTours => 'Aucun tour disponible';

  @override
  String get operatorNoToursMessage =>
      'Cet opérateur n\'a pas encore publié de tours.';

  @override
  String get operatorPoisServed => 'Lieux desservis';

  @override
  String get operatorNoPois => 'Aucun lieu desservi';

  @override
  String get operatorNoPoisMessage =>
      'Cet opérateur ne dessert aucun lieu pour le moment';

  @override
  String get operatorTourAddedToFavorites => 'Tour ajouté aux favoris';

  @override
  String get operatorTourRemovedFromFavorites => 'Tour retiré des favoris';

  @override
  String get operatorPoiAddedToFavorites => 'POI ajouté aux favoris';

  @override
  String get operatorPoiRemovedFromFavorites => 'POI retiré des favoris';

  @override
  String get operatorViews => 'vues';

  @override
  String get operatorPlace => 'Lieu';

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
  String get tourDescription => 'Description';

  @override
  String get tourItinerary => 'Itinéraire';

  @override
  String get tourHighlights => 'Points forts';

  @override
  String get tourWhatToBring => 'À apporter';

  @override
  String get tourPhotoGallery => 'Galerie photos';

  @override
  String get tourRetry => 'Réessayer';

  @override
  String get tourViewOnMap => 'Voir sur la carte';

  @override
  String get tourCall => 'Appeler';

  @override
  String get tourEmail => 'Email';

  @override
  String poiCannotCall(String phone) {
    return 'Impossible d\'appeler $phone';
  }

  @override
  String poiCallError(String error) {
    return 'Erreur lors de l\'appel: $error';
  }

  @override
  String get poiCannotOpenEmail => 'Impossible d\'ouvrir l\'email';

  @override
  String poiEmailError(String error) {
    return 'Erreur lors de l\'ouverture de l\'email: $error';
  }

  @override
  String get profileAnonymousExplorer => 'Explorateur Anonyme';

  @override
  String get profileDiscoverDjibouti => 'Découvrez Djibouti sans contraintes';

  @override
  String get profileKeepDiscoveries => 'Gardez vos découvertes !';

  @override
  String get profileCreateAccountBenefits =>
      'Créez votre compte pour sauvegarder vos favoris et accéder à des fonctionnalités exclusives.';

  @override
  String get profileFavorites => 'Favoris';

  @override
  String get profileEvents => 'Événements';

  @override
  String get profileDiscoveries => 'Découvertes';

  @override
  String get profileTimeSpent => 'Temps passé';

  @override
  String get profilePersonalInfoSubtitle => 'Gérer vos données de profil';

  @override
  String get profileSecuritySubtitle => 'Mot de passe et authentification';

  @override
  String get profileNotificationsSubtitle => 'Préférences de notification';

  @override
  String get profileLogoutSubtitle => 'Se déconnecter du compte';

  @override
  String get profileLogoutConfirm =>
      'Êtes-vous sûr de vouloir vous déconnecter ? Vous redeviendrez un utilisateur anonyme.';

  @override
  String get profileSettingsSubtitle => 'Préférences générales';

  @override
  String get profileHelp => 'Aide';

  @override
  String get profileHelpSubtitle => 'Support et FAQ';

  @override
  String get profileComingSoon => 'sera bientôt disponible !';

  @override
  String get profileComingSoonMessage =>
      'Nous travaillons dur pour vous apporter cette fonctionnalité.';

  @override
  String profileLanguageChanged(String language) {
    return 'Langue changée vers $language';
  }
}
