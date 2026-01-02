// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get privacyFirst => 'Конфіденційність перш за все';

  @override
  String get permissionScreenBody =>
      'Clean аналізує ваші фотографії безпосередньо на вашому пристрої. Нічого ніколи не завантажується на сервер.';

  @override
  String get grantAccessContinue => 'Надати доступ і продовжити';

  @override
  String get homeScreenTitle => 'Clean';

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
  String get noMorePhotos => 'Більше не знайдено фотографій для видалення!';

  @override
  String errorOccurred(String error) {
    return 'Сталася помилка: $error';
  }

  @override
  String photosDeleted(int count, String space) {
    return 'Видалено $count фотографій і збережено $space';
  }

  @override
  String errorDeleting(String error) {
    return 'Помилка під час видалення фотографій: $error';
  }

  @override
  String get reSort => 'Повторне сортування';

  @override
  String delete(int count) {
    return 'Видалити ($count)';
  }

  @override
  String get pass => 'Пропустити';

  @override
  String get analyzePhotos => 'Аналізувати фотографії';

  @override
  String fullScreenTitle(int count, int total) {
    return '$count з $total';
  }

  @override
  String get kept => 'Збережено';

  @override
  String get keep => 'Зберегти';

  @override
  String get failedToLoadImage => 'Не вдалося завантажити зображення';

  @override
  String get couldNotDelete =>
      'Не вдалося видалити фотографії. Будь ласка спробуйте ще раз.';

  @override
  String get photoAccessRequired =>
      'Потрібен повний дозвіл на доступ до фотографій.';

  @override
  String get settings => 'Налаштування';

  @override
  String get storageUsed => 'Використано сховище';

  @override
  String get spaceSavedThisMonth => 'Збережено місця (цього місяця)';

  @override
  String get appTitle => 'Clean';

  @override
  String get chooseYourLanguage => 'Виберіть свою мову';

  @override
  String get permissionTitle => 'Потрібен доступ до фотографій';

  @override
  String get permissionDescription =>
      'Clean потребує доступу до ваших фотографій, щоб допомогти вам їх очистити.';

  @override
  String get grantPermission => 'Надати дозвіл';

  @override
  String get permissionRequired => 'Потрібен дозвіл';

  @override
  String get permissionPermanentlyDenied =>
      'Доступ до фотографій було назавжди заборонено. Щоб продовжити, ви повинні ввімкнути його в налаштуваннях свого пристрою.';

  @override
  String get permissionWarning =>
      'Для пошуку та видалення небажаних фотографій потрібен повний доступ до фотографій. Будь ласка, надайте доступ у налаштуваннях телефону.';

  @override
  String get permissionLimitedWarning =>
      'Цій програмі потрібен повний доступ до ваших фотографій, щоб працювати належним чином. Будь ласка, надайте повний доступ у налаштуваннях телефону.';

  @override
  String get permissionDeniedWarning =>
      'У доступі до фотографій було відмовлено. Цій програмі потрібен доступ до ваших фотографій, щоб працювати. Будь ласка, надайте доступ у налаштуваннях телефону.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get openSettings => 'Відкрити налаштування';

  @override
  String get totalSpaceSaved => 'Загалом заощаджено місця';

  @override
  String get readyToClean => 'Готові до очищення?';

  @override
  String get letsFindPhotos =>
      'Давайте знайдемо фотографії, які можна безпечно видалити.';

  @override
  String get storageSpaceSaved => 'Зекономлено';

  @override
  String get gridTutorialText =>
      'Торкніться, щоб переглянути на весь екран. Натисніть і утримуйте або двічі торкніться, щоб зберегти.';

  @override
  String get gridTutorialDismiss => 'Торкніться будь-де, щоб продовжити';
}
