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
  String get commonSeeAll => 'Voir tout';

  @override
  String get commonShowMore => 'Voir plus';

  @override
  String get commonShowLess => 'Voir moins';

  @override
  String get commonSend => 'Envoyer';
}
