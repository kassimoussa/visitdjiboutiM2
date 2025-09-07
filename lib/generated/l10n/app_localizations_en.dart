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
  String get homeDiscoverByRegion => 'Discover by region';

  @override
  String get homeDiscoverByRegionSubtitle => 'Tap to explore';

  @override
  String get homeEssentials => 'Essentials';

  @override
  String get homeDiscover => 'Discover';

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
  String get eventsEnded => 'Ended';

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
  String get drawerProfile => 'Profile';

  @override
  String get drawerReservations => 'My Reservations';

  @override
  String get drawerReservationsSubtitle => 'Manage your bookings';

  @override
  String get drawerOfflineMode => 'Offline mode';

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
  String get drawerAnonymousUser => 'Anonymous explorer';

  @override
  String get drawerCreateAccount => 'Create account';

  @override
  String get drawerLogin => 'Login';

  @override
  String get drawerConnected => 'Connected';

  @override
  String get drawerLogoutTitle => 'Logout';

  @override
  String get drawerLogoutMessage =>
      'Are you sure you want to logout? You will become an anonymous user again.';

  @override
  String get drawerLogoutSuccess => 'Successfully logged out';

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
  String get commonErrorUnknown => 'Unknown error';

  @override
  String get commonErrorSync => 'Synchronization error';

  @override
  String get commonErrorDownload => 'Download error';

  @override
  String get commonErrorCache => 'Error clearing cache';

  @override
  String get commonErrorFavorites => 'Error updating favorites';

  @override
  String get commonErrorLoading => 'Loading error';

  @override
  String get commonErrorUnexpected => 'An unexpected error occurred';

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

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsPreferredRegion => 'Preferred region';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsDarkModeSubtitle => 'Dark interface to save battery';

  @override
  String get settingsDarkModeActivated => 'Dark mode activated';

  @override
  String get settingsDarkModeDeactivated => 'Dark mode deactivated';

  @override
  String get settingsPushNotifications => 'Push notifications';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Receive alerts about new events';

  @override
  String get settingsEventReminders => 'Event reminders';

  @override
  String get settingsEventRemindersSubtitle =>
      'Notifications before your booked events';

  @override
  String get settingsNewPois => 'New POIs';

  @override
  String get settingsNewPoisSubtitle => 'Be informed of new discovered places';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsLocationServices => 'Location services';

  @override
  String get settingsLocationServicesSubtitle =>
      'Allow geolocation for nearby POIs';

  @override
  String get settingsDefaultZoom => 'Default zoom level';

  @override
  String get settingsDefaultZoomSubtitle => 'Initial zoom on map';

  @override
  String get settingsDataStorage => 'Data & Storage';

  @override
  String get settingsOfflineModeSubtitle =>
      'Manage downloads and synchronization';

  @override
  String get settingsManageCache => 'Manage cache';

  @override
  String settingsImageCache(String size) {
    return 'Image cache: $size';
  }

  @override
  String get settingsOfflineMaps => 'Offline maps';

  @override
  String get settingsOfflineMapsSubtitle => 'Download maps of Djibouti';

  @override
  String get settingsSecurityPrivacy => 'Security & Privacy';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacySubtitle => 'Manage your personal data';

  @override
  String get settingsTermsSubtitle => 'Read terms of use';

  @override
  String get settingsActions => 'Actions';

  @override
  String get settingsBackupData => 'Backup my data';

  @override
  String get settingsBackupDataSubtitle =>
      'Favorites, reservations and preferences';

  @override
  String get settingsResetSettings => 'Reset to default settings';

  @override
  String get settingsResetSettingsSubtitle => 'Reset all settings to zero';

  @override
  String get settingsAllowGeolocation => 'Allow geolocation';

  @override
  String get settingsGeolocationRequest =>
      'Visit Djibouti wants to access your location to show you nearby points of interest.';

  @override
  String get settingsAllow => 'Allow';

  @override
  String get settingsGeolocationEnabled => 'Geolocation enabled';

  @override
  String get settingsClearCache => 'Clear cache';

  @override
  String get settingsCacheClearedSuccess => 'Cache cleared successfully';

  @override
  String settingsErrorClearing(String error) {
    return 'Error while clearing: $error';
  }

  @override
  String get settingsClear => 'Clear';

  @override
  String get eventsSearchHint => 'Search for an event...';

  @override
  String get eventsAll => 'All';

  @override
  String get eventsNoEventsFound => 'No events found';

  @override
  String get eventsClearFilters => 'Clear filters';

  @override
  String get eventsPopular => 'Popular';

  @override
  String eventsRemovedFromFavorites(String title) {
    return '$title removed from favorites';
  }

  @override
  String eventsAddedToFavorites(String title) {
    return '$title added to favorites';
  }

  @override
  String get homeShufflePois => 'Shuffle POIs';

  @override
  String get homeNoFeaturedPois => 'No featured POIs available';

  @override
  String get homeNoUpcomingEvents => 'No upcoming events';

  @override
  String get homeTourOperators => 'Tour Operators';

  @override
  String get homeTourOperatorsSubtitle => 'Plan your adventure with experts';

  @override
  String get homeEssentialInfo => 'Essential Info';

  @override
  String get homeEssentialInfoSubtitle => 'Organization and useful links';

  @override
  String get homeEmbassies => 'Embassies';

  @override
  String get homeEmbassiesSubtitle =>
      'Diplomatic representations in Djibouti and abroad';

  @override
  String mapErrorLoadingPois(String message) {
    return 'Error loading POIs: $message';
  }

  @override
  String mapError(String error) {
    return 'Error: $error';
  }

  @override
  String get mapUnknownPlace => 'Unknown place';

  @override
  String get authWelcomeBack => 'Welcome back!';

  @override
  String get authSignInSubtitle => 'Sign in to your Visit Djibouti account';

  @override
  String get authOr => 'or';

  @override
  String get authSuccessTitle => 'Login successful!';

  @override
  String get authErrorTitle => 'Error';

  @override
  String get authSignUpSuccessTitle => 'Registration successful';

  @override
  String get authConversionProblemTitle => 'Conversion problem';

  @override
  String get authKeepDiscoveries => 'Keep your discoveries!';

  @override
  String get authWelcomeToApp => 'Welcome to Visit Djibouti';

  @override
  String get authCreateAccountDescription =>
      'Create your account to save your favorites and preferences';

  @override
  String get authDataPreserved => 'Your current data will be preserved';

  @override
  String get authKeepingDataInfo => '✨ By creating your account, you keep:';

  @override
  String get authCurrentFavorites => 'All your current favorites';

  @override
  String get authPreferences => 'Your preferences';

  @override
  String get authBrowsingHistory => 'Your browsing history';

  @override
  String get authDiscoveredPlaces => 'Your discovered places';

  @override
  String get aboutPageDescription =>
      'Visit Djibouti is the official tourism application of Djibouti. Discover exceptional sites, cultural events and unique experiences that our country has to offer. From volcanic landscapes to pristine seabeds, including our rich cultural heritage, explore Djibouti like never before.';

  @override
  String get aboutPointsOfInterest => 'Points of Interest';

  @override
  String get aboutEvents => 'Events';

  @override
  String get aboutTourismOffice => 'Djibouti Tourism Office';

  @override
  String get aboutTourismOfficeSubtitle =>
      'Official tourism promotion organization';

  @override
  String get aboutMinistry => 'Ministry of Commerce and Tourism';

  @override
  String get aboutMinistrySubtitle => 'Republic of Djibouti';

  @override
  String get aboutHotelsAssociation => 'Hotels Association';

  @override
  String get aboutHotelsAssociationSubtitle => 'Private tourism sector';

  @override
  String get helpHowCanWeHelp => 'How can we help you?';

  @override
  String get helpSearchPlaceholder => 'Search in help...';

  @override
  String get helpContactUs => 'Contact us';

  @override
  String get helpLiveChat => 'Live chat';

  @override
  String get helpConnectingToChat => 'Connecting to chat...';

  @override
  String get helpStartChat => 'Start chat';

  @override
  String get helpSubject => 'Subject';

  @override
  String get helpMessage => 'Your message';

  @override
  String get helpEmailOptional => 'Your email (optional)';

  @override
  String get helpProblemTitle => 'Problem title';

  @override
  String get helpMessageSentSuccess => 'Message sent successfully!';

  @override
  String get helpHowToUseMap => 'How to use the map';

  @override
  String get helpBookEvent => 'Book an event';

  @override
  String get helpManageFavorites => 'Manage favorites';

  @override
  String get helpDescribeProblem => 'Describe the problem encountered...';

  @override
  String get helpDuration3Min => '3 min';

  @override
  String get helpDuration2Min => '2 min';

  @override
  String get helpDuration1Min => '1 min';

  @override
  String get embassiesTitle => 'Embassies';

  @override
  String get embassiesCall => 'Call';

  @override
  String get embassiesEmail => 'Email';

  @override
  String get embassiesWebsite => 'Website';

  @override
  String get embassiesCannotOpenPhone => 'Cannot open phone application';

  @override
  String get embassiesCannotOpenEmail => 'Cannot open email application';

  @override
  String get embassiesCannotOpenWebsite => 'Cannot open website';

  @override
  String get essentialsTitle => 'Essential Info';

  @override
  String get essentialsUnavailableInfo => 'Information unavailable';

  @override
  String get essentialsNoLinksAvailable => 'No links available';

  @override
  String get eventDetailErrorLoading => 'Error loading details';

  @override
  String get eventDetailRegistrationConfirmed => 'Registration confirmed!';

  @override
  String eventDetailReservationNumber(String number) {
    return 'Reservation number: $number';
  }

  @override
  String eventDetailParticipantsCount(String count) {
    return 'Participants: $count';
  }

  @override
  String eventDetailSpecialRequirements(String requirements) {
    return 'Special requirements: $requirements';
  }

  @override
  String get eventDetailParticipantsLabel => 'Number of participants';

  @override
  String get eventDetailFullNameLabel => 'Full name';

  @override
  String get eventDetailEmailLabel => 'Email';

  @override
  String get eventDetailPhoneLabel => 'Phone';

  @override
  String get eventDetailSpecialRequirementsLabel =>
      'Special requirements (optional)';

  @override
  String get eventDetailSpecialRequirementsHint =>
      'Allergies, accessibility needs, etc.';

  @override
  String get commonOk => 'OK';

  @override
  String reservationsAll(int count) {
    return 'All ($count)';
  }

  @override
  String reservationsConfirmed(int count) {
    return 'Confirmed ($count)';
  }

  @override
  String reservationsPending(int count) {
    return 'Pending ($count)';
  }

  @override
  String reservationsCancelled(int count) {
    return 'Cancelled ($count)';
  }

  @override
  String get reservationsNoneAll => 'No reservations';

  @override
  String get reservationsNoneConfirmed => 'No confirmed reservations';

  @override
  String get reservationsNonePending => 'No pending reservations';

  @override
  String get reservationsNoneCancelled => 'No cancelled reservations';

  @override
  String get reservationsCancelTitle => 'Cancel reservation';

  @override
  String get reservationsDeleteTitle => 'Delete reservation';

  @override
  String get tourOperatorsNoneFound => 'No tour operators found';

  @override
  String get offlineLoadingSettings => 'Loading settings...';

  @override
  String get offlineConnectionStatus => 'Connection status';

  @override
  String get offlineClearCacheTitle => 'Clear cache';

  @override
  String get profileUser => 'User';

  @override
  String get profileLogoutTitle => 'Logout';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get profileEditTooltip => 'Edit';

  @override
  String get profileSecurity => 'Security';

  @override
  String get apiTestTitle => 'API POIs Test';

  @override
  String get discoverClearFilters => 'Clear filters';

  @override
  String get mapSearchHint => 'Search on map...';

  @override
  String get categoryFilterClear => 'Clear';

  @override
  String get offlineIndicatorConnectionRestored => 'Connection restored!';

  @override
  String get offlineIndicatorOfflineMode => 'Offline mode';

  @override
  String get offlineIndicatorOfflineModeTitle => 'Offline mode';

  @override
  String get reservationFormDateLabel => 'Date *';

  @override
  String get reservationFormDatePlaceholder => 'Select a date';

  @override
  String get reservationFormTimeLabel => 'Time';

  @override
  String get reservationFormTimePlaceholder => 'HH:MM';

  @override
  String get reservationFormParticipantsLabel => 'Number of people *';

  @override
  String get reservationFormParticipantsPlaceholder => '1';

  @override
  String get reservationFormNotesLabel => 'Notes or special requests';

  @override
  String get reservationFormNotesPlaceholder =>
      'Food allergies, special needs...';

  @override
  String get reservationFormPleaseSelectDate => 'Please select a date';

  @override
  String reservationFormUnexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String tourOperatorDetailsSnackbar(String name) {
    return 'Details of $name';
  }

  @override
  String get tourOperatorCallButton => 'Call';

  @override
  String get tourOperatorWebsiteButton => 'Website';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';
}
