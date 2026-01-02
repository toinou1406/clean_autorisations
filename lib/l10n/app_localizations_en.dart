// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Photo Cleaner';

  @override
  String get homeScreenTitle => 'Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get totalSpaceSaved => 'Total Space Saved';

  @override
  String get sortingMessageAnalyzing => 'Analyzing photo characteristics...';

  @override
  String get sortingMessageBlurry => 'Identifying blurry photos...';

  @override
  String get sortingMessageScreenshots => 'Looking for screenshots...';

  @override
  String get sortingMessageDuplicates => 'Searching for duplicates...';

  @override
  String get sortingMessageScores => 'Calculating photo scores...';

  @override
  String get sortingMessageCompiling => 'Compiling results...';

  @override
  String get sortingMessageRanking => 'Ranking suggestions...';

  @override
  String get sortingMessageFinalizing => 'Finalizing batch...';

  @override
  String errorOccurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get noMorePhotos => 'No more photos to sort for now!';

  @override
  String get couldNotDelete =>
      'Could not delete photos. You may need to grant permission again.';

  @override
  String photosDeleted(num count, Object space) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos deleted',
      one: '1 photo deleted',
    );
    return '$_temp0 ($space saved)';
  }

  @override
  String errorDeleting(Object error) {
    return 'Error deleting photos: $error';
  }

  @override
  String get gridTutorialText =>
      'Double tap or long press on a photo to mark it to be kept.';

  @override
  String get gridTutorialDismiss => 'Tap anywhere to dismiss';

  @override
  String get keep => 'Keep';

  @override
  String get letsFindPhotos => 'Let\'s find some photos to clean!';

  @override
  String get storageSpaceSaved => 'Storage Space Saved';

  @override
  String get reSort => 'Re-sort';

  @override
  String delete(Object count) {
    return 'Delete $count';
  }

  @override
  String get pass => 'Pass';

  @override
  String get analyzePhotos => 'Analyze Photos';

  @override
  String get chooseYourLanguage => 'Choose your language';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get permissionTitle => 'Access Required';

  @override
  String get permissionDescription =>
      'To help you clean up your gallery, this app needs permission to access your photos.';

  @override
  String get permissionWarning =>
      'Full access is required to analyze all photos. Please grant full access in the next prompt.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get permissionLimitedTitle => 'Full Access Required';

  @override
  String get permissionLimitedDescription =>
      'You have granted limited access. For the app to find all photos worth deleting, please allow access to your entire library in the settings.';

  @override
  String get permissionPermanentlyDeniedTitle => 'Permission Denied';

  @override
  String get permissionPermanentlyDeniedDescription =>
      'You have permanently denied photo access. To use this feature, you must enable it in your device settings.';

  @override
  String get storageUsed => 'Storage Used';

  @override
  String fullScreenTitle(Object count, Object total) {
    return '$count of $total';
  }

  @override
  String get kept => 'Kept';
}
