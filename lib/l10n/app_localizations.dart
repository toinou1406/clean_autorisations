import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('uk'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Cleaner'**
  String get appTitle;

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeScreenTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalSpaceSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Space Saved'**
  String get totalSpaceSaved;

  /// No description provided for @sortingMessageAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing photo characteristics...'**
  String get sortingMessageAnalyzing;

  /// No description provided for @sortingMessageBlurry.
  ///
  /// In en, this message translates to:
  /// **'Identifying blurry photos...'**
  String get sortingMessageBlurry;

  /// No description provided for @sortingMessageScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Looking for screenshots...'**
  String get sortingMessageScreenshots;

  /// No description provided for @sortingMessageDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Searching for duplicates...'**
  String get sortingMessageDuplicates;

  /// No description provided for @sortingMessageScores.
  ///
  /// In en, this message translates to:
  /// **'Calculating photo scores...'**
  String get sortingMessageScores;

  /// No description provided for @sortingMessageCompiling.
  ///
  /// In en, this message translates to:
  /// **'Compiling results...'**
  String get sortingMessageCompiling;

  /// No description provided for @sortingMessageRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking suggestions...'**
  String get sortingMessageRanking;

  /// No description provided for @sortingMessageFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing batch...'**
  String get sortingMessageFinalizing;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @noMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'No more photos to sort for now!'**
  String get noMorePhotos;

  /// No description provided for @couldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete photos. You may need to grant permission again.'**
  String get couldNotDelete;

  /// No description provided for @photosDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 photo deleted} other{{count} photos deleted}} ({space} saved)'**
  String photosDeleted(num count, Object space);

  /// No description provided for @errorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting photos: {error}'**
  String errorDeleting(Object error);

  /// No description provided for @gridTutorialText.
  ///
  /// In en, this message translates to:
  /// **'Double tap or long press on a photo to mark it to be kept.'**
  String get gridTutorialText;

  /// No description provided for @gridTutorialDismiss.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to dismiss'**
  String get gridTutorialDismiss;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @letsFindPhotos.
  ///
  /// In en, this message translates to:
  /// **'Let\'s find some photos to clean!'**
  String get letsFindPhotos;

  /// No description provided for @storageSpaceSaved.
  ///
  /// In en, this message translates to:
  /// **'Storage Space Saved'**
  String get storageSpaceSaved;

  /// No description provided for @reSort.
  ///
  /// In en, this message translates to:
  /// **'Re-sort'**
  String get reSort;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete {count}'**
  String delete(Object count);

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get pass;

  /// No description provided for @analyzePhotos.
  ///
  /// In en, this message translates to:
  /// **'Analyze Photos'**
  String get analyzePhotos;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Required'**
  String get permissionTitle;

  /// No description provided for @permissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To help you clean up your gallery, this app needs permission to access your photos.'**
  String get permissionDescription;

  /// No description provided for @permissionWarning.
  ///
  /// In en, this message translates to:
  /// **'Full access is required to analyze all photos. Please grant full access in the next prompt.'**
  String get permissionWarning;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @permissionLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Access Required'**
  String get permissionLimitedTitle;

  /// No description provided for @permissionLimitedDescription.
  ///
  /// In en, this message translates to:
  /// **'You have granted limited access. For the app to find all photos worth deleting, please allow access to your entire library in the settings.'**
  String get permissionLimitedDescription;

  /// No description provided for @permissionPermanentlyDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionPermanentlyDeniedTitle;

  /// No description provided for @permissionPermanentlyDeniedDescription.
  ///
  /// In en, this message translates to:
  /// **'You have permanently denied photo access. To use this feature, you must enable it in your device settings.'**
  String get permissionPermanentlyDeniedDescription;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get storageUsed;

  /// No description provided for @fullScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total}'**
  String fullScreenTitle(Object count, Object total);

  /// No description provided for @kept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get kept;
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
      <String>['en', 'es', 'fr', 'uk', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
