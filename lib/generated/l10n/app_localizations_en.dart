// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Visit Djibouti';

  @override
  String get appDescription => 'Discover the wonders of Djibouti';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationDiscover => 'Discover';

  @override
  String get navigationEvents => 'Events';

  @override
  String get navigationMap => 'Map';

  @override
  String get navigationFavorites => 'Favorites';

  @override
  String get homeWelcomeMessage => 'Welcome to Djibouti';

  @override
  String get homeFeaturedPois => 'Places to discover';

  @override
  String get homeUpcomingEvents => 'Upcoming events';

  @override
  String get homeExploreMore => 'Explore more';

  @override
  String get discoverTitle => 'Discover Djibouti';

  @override
  String get discoverCategories => 'Categories';

  @override
  String get discoverAllPois => 'All places';

  @override
  String get discoverSearchHint => 'Search for a place...';

  @override
  String get discoverNearbyPois => 'Nearby places';

  @override
  String get discoverNoResults => 'No results found';

  @override
  String get eventsTitle => 'Events';

  @override
  String get eventsUpcoming => 'Upcoming';

  @override
  String get eventsOngoing => 'Ongoing';

  @override
  String get eventsPast => 'Past';

  @override
  String get eventsRegister => 'Register';

  @override
  String get eventsRegistered => 'Registered';

  @override
  String get eventsSoldOut => 'Sold out';

  @override
  String get eventsFree => 'Free';

  @override
  String eventsPrice(String price) {
    return '$price DJF';
  }

  @override
  String eventsParticipants(int count) {
    return '$count participants';
  }

  @override
  String get favoritesTitle => 'My Favorites';

  @override
  String get favoritesEmpty => 'No favorites';

  @override
  String get favoritesEmptyDescription =>
      'Explore Djibouti and add your favorite\\nplaces to your collection';

  @override
  String get favoritesAddedToFavorites => 'Added to favorites';

  @override
  String get favoritesRemovedFromFavorites => 'Removed from favorites';

  @override
  String get favoritesPoisTab => 'Places';

  @override
  String get favoritesEventsTab => 'Events';

  @override
  String get favoritesAllTab => 'All';

  @override
  String get favoritesSortRecent => 'Recent';

  @override
  String get favoritesSortAlphabetical => 'Alphabetical';

  @override
  String get favoritesSortRating => 'Rating';

  @override
  String get mapTitle => 'Map';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapSearchLocation => 'Search for a location...';

  @override
  String get mapRouteTo => 'Route to';

  @override
  String mapDistance(String distance) {
    return '$distance km';
  }

  @override
  String get authLogin => 'Login';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authLogout => 'Logout';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authName => 'Full name';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authDontHaveAccount => 'Don\'t have an account?';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authSignInWithGoogle => 'Continue with Google';

  @override
  String get authSignInWithFacebook => 'Continue with Facebook';

  @override
  String get authOrContinueWith => 'Or continue with';

  @override
  String get authTermsAndConditions => 'Terms and Conditions';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileAboutApp => 'About';

  @override
  String get profileContactSupport => 'Support';

  @override
  String get conversionAfterFavoritesTitle => 'Save your discoveries!';

  @override
  String get conversionAfterFavoritesDescription =>
      'Create your account to sync your favorites across all your devices';

  @override
  String get conversionAfterFavoritesButton => 'Save my favorites';

  @override
  String get conversionBeforeReservationTitle => 'Complete your registration';

  @override
  String get conversionBeforeReservationDescription =>
      'An account is required to finalize your event reservation';

  @override
  String get conversionBeforeReservationButton => 'Create an account';

  @override
  String get conversionBeforeExportTitle => 'Receive your itinerary by email';

  @override
  String get conversionBeforeExportDescription =>
      'Create your account to receive your personalized itinerary by email';

  @override
  String get conversionBeforeExportButton => 'Receive by email';

  @override
  String get conversionAfterWeekUsageTitle => 'Create your traveler profile';

  @override
  String get conversionAfterWeekUsageDescription =>
      'After a week of exploration, create your profile for a personalized experience';

  @override
  String get conversionAfterWeekUsageButton => 'Create my profile';

  @override
  String get conversionBenefits => 'With an account, you can:';

  @override
  String get conversionBenefitSync =>
      'Sync your favorites across all your devices';

  @override
  String get conversionBenefitNotifications =>
      'Receive notifications for your favorite places';

  @override
  String get conversionBenefitItineraries => 'Create personalized itineraries';

  @override
  String get conversionBenefitReservations =>
      'Manage all your reservations in one place';

  @override
  String get conversionBenefitHistory => 'Access your reservation history';

  @override
  String get conversionBenefitEmail => 'Receive your itineraries by email';

  @override
  String get conversionBenefitShare => 'Share your discoveries with friends';

  @override
  String get conversionBenefitRecommendations =>
      'Get personalized recommendations';

  @override
  String get conversionBenefitOffers => 'Access exclusive offers';

  @override
  String get conversionBenefitCommunity => 'Join the traveler community';

  @override
  String get conversionLaterButton => 'Later';

  @override
  String get conversionContinueWithoutAccount => 'Continue without account';

  @override
  String get conversionNotNowButton => 'Not now';

  @override
  String get conversionMaybeLaterButton => 'Maybe later';

  @override
  String get conversionCancelButton => 'Cancel';

  @override
  String get drawerGuest => 'Guest';

  @override
  String get drawerViewProfile => 'View my profile →';

  @override
  String get drawerSettingsSection => 'Settings';

  @override
  String get drawerTestApi => 'API Test';

  @override
  String get drawerTestApiSubtitle => 'Test endpoints';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerLanguage => 'Language';

  @override
  String get drawerNotifications => 'Notifications';

  @override
  String get drawerHelpSection => 'Help & Support';

  @override
  String get drawerHelp => 'Help';

  @override
  String get drawerFeedback => 'Feedback';

  @override
  String get drawerAbout => 'About';

  @override
  String get drawerUsefulLinks => 'Useful links';

  @override
  String get drawerTourismOffice => 'Tourism Office';

  @override
  String get drawerEmbassies => 'Embassies';

  @override
  String get drawerEmergencyNumbers => 'Emergency numbers';

  @override
  String get drawerVersion => 'Version 1.0.0';

  @override
  String get drawerChooseLanguage => 'Choose language';

  @override
  String drawerLanguageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get drawerSendFeedback => 'Send feedback';

  @override
  String get drawerFeedbackHint =>
      'Share your experience with Visit Djibouti...';

  @override
  String get drawerFeedbackThanks => 'Thank you for your feedback!';

  @override
  String get drawerPolice => '🚨 Police: 17';

  @override
  String get drawerFire => '🚒 Fire department: 18';

  @override
  String get drawerSamu => '🏥 SAMU: 351351';

  @override
  String get drawerMedical => '🚑 Medical emergency: 35 35 35';

  @override
  String get drawerInfo => '📞 Information: 12';

  @override
  String get drawerTourismOfficeSnackbar => 'Opening Tourism Office website';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonShare => 'Share';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNext => 'Next';

  @override
  String get commonPrevious => 'Previous';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonShowMore => 'Show more';

  @override
  String get commonShowLess => 'Show less';

  @override
  String get commonSend => 'Send';
}
