// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Clean';

  @override
  String get homeScreenTitle => 'Clean';

  @override
  String get settings => 'Ajustes';

  @override
  String get totalSpaceSaved => 'Espacio total ahorrado';

  @override
  String get sortingMessageAnalyzing => 'Analizando metadatos de fotos...';

  @override
  String get sortingMessageBlurry => 'Detectando imágenes borrosas...';

  @override
  String get sortingMessageScreenshots =>
      'Buscando capturas de pantalla malas...';

  @override
  String get sortingMessageDuplicates => 'Comprobando duplicados...';

  @override
  String get sortingMessageScores => 'Calculando puntuaciones de fotos...';

  @override
  String get sortingMessageCompiling => 'Compilando resultados...';

  @override
  String get sortingMessageRanking => 'Clasificando fotos por \'maldad\'...';

  @override
  String get sortingMessageFinalizing => 'Finalizando la selección de fotos...';

  @override
  String errorOccurred(Object error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String get noMorePhotos =>
      '¡No se encontraron más fotos que se puedan eliminar!';

  @override
  String get couldNotDelete =>
      'No se pudieron eliminar las fotos. Por favor, inténtalo de nuevo.';

  @override
  String photosDeleted(num count, Object space) {
    return '$count fotos eliminadas y $space ahorrados';
  }

  @override
  String errorDeleting(Object error) {
    return 'Error al eliminar fotos: $error';
  }

  @override
  String get gridTutorialText =>
      'Toca para ver en pantalla completa. Mantén presionado o toca dos veces para conservar.';

  @override
  String get gridTutorialDismiss => 'Toca en cualquier lugar para continuar';

  @override
  String get keep => 'Guardar';

  @override
  String get letsFindPhotos =>
      'Busquemos algunas fotos que puedas eliminar de forma segura.';

  @override
  String get storageSpaceSaved => 'Ahorrado';

  @override
  String get reSort => 'Reordenar';

  @override
  String delete(Object count) {
    return 'Eliminar ($count)';
  }

  @override
  String get pass => 'Pasar';

  @override
  String get analyzePhotos => 'Analizar fotos';

  @override
  String get chooseYourLanguage => 'Elige tu idioma';

  @override
  String get grantPermission => 'Conceder permiso';

  @override
  String get permissionTitle => 'Acceso a fotos requerido';

  @override
  String get permissionDescription =>
      'Clean necesita acceso a tus fotos para ayudarte a limpiarlas.';

  @override
  String get permissionWarning =>
      'Se requiere acceso completo a las fotos para encontrar y eliminar fotos no deseadas. Por favor, concede acceso en la configuración de tu teléfono.';

  @override
  String get openSettings => 'Abrir la configuración';

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
  String get storageUsed => 'Almacenamiento usado';

  @override
  String fullScreenTitle(Object count, Object total) {
    return '$count de $total';
  }

  @override
  String get kept => 'Guardada';
}
