// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Clean';

  @override
  String get homeScreenTitle => '主页';

  @override
  String get settings => '设置';

  @override
  String get totalSpaceSaved => '总共节省的空间';

  @override
  String get sortingMessageAnalyzing => '正在分析照片...';

  @override
  String get sortingMessageBlurry => '查找模糊的照片...';

  @override
  String get sortingMessageScreenshots => '识别截图...';

  @override
  String get sortingMessageDuplicates => '检测重复项...';

  @override
  String get sortingMessageScores => '计算分数...';

  @override
  String get sortingMessageCompiling => '正在编译结果...';

  @override
  String get sortingMessageRanking => '正在对您的照片进行排名...';

  @override
  String get sortingMessageFinalizing => '正在完成...';

  @override
  String errorOccurred(Object error) {
    return '发生错误：$error';
  }

  @override
  String get noMorePhotos => '没有更多可整理的照片了！';

  @override
  String get couldNotDelete => '无法删除照片。请稍后再试。';

  @override
  String photosDeleted(num count, Object space) {
    return '$count 张照片已删除，节省了 $space！';
  }

  @override
  String errorDeleting(Object error) {
    return '删除时出错：$error';
  }

  @override
  String get gridTutorialText => '点击可全屏查看照片。长按或双击可保留照片。';

  @override
  String get gridTutorialDismiss => '在任何地方点一下即可继续';

  @override
  String get keep => '保留';

  @override
  String get letsFindPhotos => '让我们查找一些可以安全删除的照片。';

  @override
  String get storageSpaceSaved => '已节省';

  @override
  String get reSort => '重新排序';

  @override
  String delete(Object count) {
    return '删除 $count';
  }

  @override
  String get pass => '跳过';

  @override
  String get analyzePhotos => '分析照片';

  @override
  String get chooseYourLanguage => '选择您的语言';

  @override
  String get grantPermission => '授予权限';

  @override
  String get permissionTitle => '需要照片访问权限';

  @override
  String get permissionDescription => '为了扫描和管理您的照片，此应用程序需要访问您设备存储的权限。';

  @override
  String get permissionWarning => '需要完全的照片访问权限才能查找和删除不需要的照片。请在手机设置中授予访问权限。';

  @override
  String get openSettings => '打开设置';

  @override
  String get permissionLimitedTitle => '需要完全访问权限';

  @override
  String get permissionLimitedDescription =>
      '您已授予有限的访问权限。为了让应用找到所有值得删除的照片，请在设置中允许访问您的整个图库。';

  @override
  String get permissionPermanentlyDeniedTitle => '权限被拒绝';

  @override
  String get permissionPermanentlyDeniedDescription =>
      '您已永久拒绝照片访问。要使用此功能，您必须在设备设置中启用它。';

  @override
  String get storageUsed => '已用存储空间';

  @override
  String fullScreenTitle(Object count, Object total) {
    return '$count / $total';
  }

  @override
  String get kept => '已保留';
}
