// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Clean';

  @override
  String get homeScreenTitle => 'Clean';

  @override
  String get settings => 'Налаштування';

  @override
  String get totalSpaceSaved => 'Загалом заощаджено місця';

  @override
  String get sortingMessageAnalyzing => 'Аналіз метаданих фото...';

  @override
  String get sortingMessageBlurry => 'Виявлення розмитих зображень...';

  @override
  String get sortingMessageScreenshots => 'Пошук поганих знімків екрана...';

  @override
  String get sortingMessageDuplicates => 'Перевірка наявності дублікатів...';

  @override
  String get sortingMessageScores => 'Обчислення оцінок фотографій...';

  @override
  String get sortingMessageCompiling => 'Збір результатів...';

  @override
  String get sortingMessageRanking => 'Ранжування фотографій за «поганістю»...';

  @override
  String get sortingMessageFinalizing => 'Завершення вибору фотографій...';

  @override
  String errorOccurred(Object error) {
    return 'Сталася помилка: $error';
  }

  @override
  String get noMorePhotos => 'Більше не знайдено фотографій для видалення!';

  @override
  String get couldNotDelete =>
      'Не вдалося видалити фотографії. Будь ласка спробуйте ще раз.';

  @override
  String photosDeleted(num count, Object space) {
    return 'Видалено $count фотографій і збережено $space';
  }

  @override
  String errorDeleting(Object error) {
    return 'Помилка під час видалення фотографій: $error';
  }

  @override
  String get gridTutorialText =>
      'Торкніться, щоб переглянути на весь екран. Натисніть і утримуйте або двічі торкніться, щоб зберегти.';

  @override
  String get gridTutorialDismiss => 'Торкніться будь-де, щоб продовжити';

  @override
  String get keep => 'Зберегти';

  @override
  String get letsFindPhotos =>
      'Давайте знайдемо фотографії, які можна безпечно видалити.';

  @override
  String get storageSpaceSaved => 'Зекономлено';

  @override
  String get reSort => 'Повторне сортування';

  @override
  String delete(Object count) {
    return 'Видалити ($count)';
  }

  @override
  String get pass => 'Пропустити';

  @override
  String get analyzePhotos => 'Аналізувати фотографії';

  @override
  String get chooseYourLanguage => 'Виберіть свою мову';

  @override
  String get grantPermission => 'Надати дозвіл';

  @override
  String get permissionTitle => 'Потрібен доступ до фотографій';

  @override
  String get permissionDescription =>
      'Clean потребує доступу до ваших фотографій, щоб допомогти вам їх очистити.';

  @override
  String get permissionWarning =>
      'Для пошуку та видалення небажаних фотографій потрібен повний доступ до фотографій. Будь ласка, надайте доступ у налаштуваннях телефону.';

  @override
  String get openSettings => 'Відкрити налаштування';

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
  String get storageUsed => 'Використано сховище';

  @override
  String fullScreenTitle(Object count, Object total) {
    return '$count з $total';
  }

  @override
  String get kept => 'Збережено';
}
