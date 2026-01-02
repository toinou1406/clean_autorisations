// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Nettoyeur de Photos';

  @override
  String get homeScreenTitle => 'Tableau de Bord';

  @override
  String get settings => 'Paramètres';

  @override
  String get totalSpaceSaved => 'Espace total économisé';

  @override
  String get sortingMessageAnalyzing =>
      'Analyse des caractéristiques des photos...';

  @override
  String get sortingMessageBlurry => 'Identification des photos floues...';

  @override
  String get sortingMessageScreenshots => 'Recherche de captures d\'écran...';

  @override
  String get sortingMessageDuplicates => 'Recherche de doublons...';

  @override
  String get sortingMessageScores => 'Calcul des scores des photos...';

  @override
  String get sortingMessageCompiling => 'Compilation des résultats...';

  @override
  String get sortingMessageRanking => 'Classement des suggestions...';

  @override
  String get sortingMessageFinalizing => 'Finalisation du lot...';

  @override
  String errorOccurred(Object error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String get noMorePhotos => 'Plus de photos à trier pour le moment !';

  @override
  String get couldNotDelete =>
      'Impossible de supprimer les photos. Vous devrez peut-être accorder à nouveau la permission.';

  @override
  String photosDeleted(num count, Object space) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos supprimées',
      one: '1 photo supprimée',
    );
    return '$_temp0 ($space économisés)';
  }

  @override
  String errorDeleting(Object error) {
    return 'Erreur lors de la suppression des photos : $error';
  }

  @override
  String get gridTutorialText =>
      'Appuyez deux fois ou longuement sur une photo pour la marquer à conserver.';

  @override
  String get gridTutorialDismiss => 'Appuyez n\'importe où pour fermer';

  @override
  String get keep => 'Garder';

  @override
  String get letsFindPhotos => 'Trouvons des photos à nettoyer !';

  @override
  String get storageSpaceSaved => 'Espace de stockage économisé';

  @override
  String get reSort => 'Nouveau tri';

  @override
  String delete(Object count) {
    return 'Supprimer $count';
  }

  @override
  String get pass => 'Passer';

  @override
  String get analyzePhotos => 'Analyser les photos';

  @override
  String get chooseYourLanguage => 'Choisissez votre langue';

  @override
  String get grantPermission => 'Accorder la permission';

  @override
  String get permissionTitle => 'Accès Requis';

  @override
  String get permissionDescription =>
      'Pour vous aider à nettoyer votre galerie, cette application a besoin de la permission d\'accéder à vos photos.';

  @override
  String get permissionWarning =>
      'Un accès complet est requis pour analyser toutes les photos. Veuillez accorder un accès complet à l\'étape suivante.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get permissionLimitedTitle => 'Accès Complet Requis';

  @override
  String get permissionLimitedDescription =>
      'Vous avez accordé un accès limité. Pour que l\'application puisse trouver toutes les photos à supprimer, veuillez autoriser l\'accès à toute votre bibliothèque dans les paramètres.';

  @override
  String get permissionPermanentlyDeniedTitle => 'Permission Refusée';

  @override
  String get permissionPermanentlyDeniedDescription =>
      'Vous avez refusé définitivement l\'accès aux photos. Pour utiliser cette fonctionnalité, vous devez l\'activer dans les paramètres de votre appareil.';

  @override
  String get storageUsed => 'Storage Used';

  @override
  String fullScreenTitle(Object count, Object total) {
    return '$count of $total';
  }

  @override
  String get kept => 'Kept';
}
