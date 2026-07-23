// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navComingUp => 'Истекающие';

  @override
  String get navSettings => 'Настройки';

  @override
  String get newCategoryTooltip => 'Новая категория';

  @override
  String get searchHint => 'Поиск документов и описаний';

  @override
  String get allDocuments => 'Все документы';

  @override
  String fileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файлов',
      many: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$_temp0';
  }

  @override
  String get sortTooltip => 'Сортировка';

  @override
  String get sortRecent => 'Недавние';

  @override
  String get sortNameAz => 'По названию А–Я';

  @override
  String get sortLargest => 'Самые большие';

  @override
  String get categoryAll => 'Все';

  @override
  String get emptyNoDocuments =>
      'Пока нет документов. Нажмите +, чтобы загрузить первый документ.';

  @override
  String get emptyNoMatch => 'Ничего не найдено.';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String selectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано: $count',
      many: 'Выбрано: $count',
      few: 'Выбрано: $count',
      one: 'Выбрано: $count',
    );
    return '$_temp0';
  }

  @override
  String get moveToEllipsis => 'Переместить в…';

  @override
  String get delete => 'Удалить';

  @override
  String get clear => 'Очистить';

  @override
  String deleteDocumentsConfirmTitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count документов?',
      many: 'Удалить $count документов?',
      few: 'Удалить $count документа?',
      one: 'Удалить $count документ?',
    );
    return '$_temp0';
  }

  @override
  String get deleteDocumentsConfirmMessage =>
      'Выбранные файлы будут удалены. Это действие нельзя отменить.';

  @override
  String failedToLoad(String error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get noFileAttached => 'К этому документу не прикреплён файл.';

  @override
  String get fileMissingFromDisk => 'Файл отсутствует на диске.';

  @override
  String get fileMissingFromDiskDetailed =>
      'Файл отсутствует на диске — возможно, он был перемещён или удалён вне приложения.';

  @override
  String get openNotSupportedWeb =>
      'Открытие файлов пока не поддерживается в веб-версии — попробуйте Android, iOS или приложение для Windows.';

  @override
  String deleteDocumentConfirmTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get deleteDocumentConfirmMessage =>
      'Документ и его файл будут удалены. Это действие нельзя отменить.';

  @override
  String get renameDocumentTitle => 'Переименовать документ';

  @override
  String get deleteDocumentTooltip => 'Удалить документ';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get uncategorized => 'Без категории';

  @override
  String sizeAddedOn(String size, String date) {
    return '$size · добавлено $date';
  }

  @override
  String documentPreviewLabel(String type) {
    return 'просмотр документа · $type';
  }

  @override
  String expiresOn(String date) {
    return 'Истекает $date';
  }

  @override
  String remindMeDaysBeforeChange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Напомнить за $count дней · изменить',
      many: 'Напомнить за $count дней · изменить',
      few: 'Напомнить за $count дня · изменить',
      one: 'Напомнить за $count день · изменить',
    );
    return '$_temp0';
  }

  @override
  String get edit => 'Изменить';

  @override
  String get notTrackingExpiration => 'Срок действия не отслеживается';

  @override
  String get setDate => 'Указать дату';

  @override
  String get remindBeforeExpiresTitle => 'Напомнить перед истечением срока';

  @override
  String daysBeforeOption(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count дней',
      many: 'За $count дней',
      few: 'За $count дня',
      one: 'За $count день',
    );
    return '$_temp0';
  }

  @override
  String get aiSummaryLabel => 'ИИ-СВОДКА';

  @override
  String readingAndExtracting(String type) {
    return 'Чтение $type и выделение ключевых моментов…';
  }

  @override
  String get keyPointsLabel => 'КЛЮЧЕВЫЕ МОМЕНТЫ';

  @override
  String get aiDisabledLong =>
      'Сводки ИИ пока отключены. Включите сервис ИИ, чтобы он прочитал файл и выделил ключевые моменты.';

  @override
  String get aiNoSummaryYet =>
      'Сводки пока нет. Включите ИИ, чтобы прочитать файл и выделить важные моменты.';

  @override
  String get summarizeWithAi => 'Создать сводку с ИИ';

  @override
  String get aiDisabledSnackbar => 'Сводки ИИ пока отключены.';

  @override
  String get openFile => 'Открыть файл';

  @override
  String get share => 'Поделиться';

  @override
  String get chooseFiles => 'Выбрать файлы';

  @override
  String get chooseFilesSubtitle => 'Выберите один или несколько документов';

  @override
  String get scanDocument => 'Сканировать документ';

  @override
  String get scanDocumentSubtitle =>
      'Снимите страницы камерой, чтобы создать PDF';

  @override
  String scanFailed(String error) {
    return 'Не удалось отсканировать документ: $error';
  }

  @override
  String get scanFilePrefix => 'Скан';

  @override
  String get addDocumentTitle => 'Добавить документ';

  @override
  String get fileNameLabel => 'Имя файла';

  @override
  String get typeLabel => 'Тип';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get aiOptionalSubtitle => 'Необязательно — выделить ключевые моменты';

  @override
  String addDocumentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавить $count документов',
      many: 'Добавить $count документов',
      few: 'Добавить $count документа',
      one: 'Добавить $count документ',
    );
    return '$_temp0';
  }

  @override
  String get batchSameCategoryNote =>
      'Все они будут добавлены в одну категорию с сохранением имён файлов.';

  @override
  String deleteCategoryConfirmTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get deleteCategoryConfirmMessageEmpty =>
      'В этой категории нет документов. Это действие нельзя отменить.';

  @override
  String deleteCategoryConfirmMessageWithDocs(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count документов в этой категории станут без категории, а не будут удалены. Это действие нельзя отменить.',
      many:
          '$count документов в этой категории станут без категории, а не будут удалены. Это действие нельзя отменить.',
      few:
          '$count документа в этой категории станут без категории, а не будут удалены. Это действие нельзя отменить.',
      one:
          '$count документ в этой категории станет без категории, а не будет удалён. Это действие нельзя отменить.',
    );
    return '$_temp0';
  }

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get newCategoryButton => 'Новая';

  @override
  String get noCategoriesYet => 'Категорий пока нет.';

  @override
  String get deleteCategoryTooltip => 'Удалить категорию';

  @override
  String get newCategoryTitle => 'Новая категория';

  @override
  String get categoryNamePlaceholder => 'Название категории';

  @override
  String get nameLabel => 'Название';

  @override
  String get categoryNameHint => 'например, Гарантии';

  @override
  String get colorLabel => 'Цвет';

  @override
  String get previewLabel => 'предпросмотр';

  @override
  String get createCategoryButton => 'Создать категорию';

  @override
  String moveToCount(num count) {
    return 'Переместить $count в…';
  }

  @override
  String get siftLocked => 'Sift заблокирован';

  @override
  String get enterPinToContinue => 'Введите PIN-код, чтобы продолжить';

  @override
  String get incorrectPin => 'Неверный PIN-код';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get useBiometricUnlock => 'Разблокировать по биометрии';

  @override
  String get biometricUnlockReason => 'Разблокировать Sift';

  @override
  String pinMinLength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'PIN-код должен содержать минимум $count цифр',
      many: 'PIN-код должен содержать минимум $count цифр',
      few: 'PIN-код должен содержать минимум $count цифры',
      one: 'PIN-код должен содержать минимум $count цифру',
    );
    return '$_temp0';
  }

  @override
  String get confirmYourPin => 'Подтвердите PIN-код';

  @override
  String get setAPin => 'Установите PIN-код';

  @override
  String get enterItOneMoreTime => 'Введите его ещё раз';

  @override
  String get youllUseThisToUnlock => 'Он понадобится для разблокировки Sift';

  @override
  String get pinsDontMatch => 'PIN-коды не совпадают';

  @override
  String get savePin => 'Сохранить PIN-код';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get generalSectionLabel => 'Общие';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get aiSectionLabel => 'ИИ';

  @override
  String get summarizeNewUploads => 'Создавать сводки для новых файлов';

  @override
  String get summarizeNewUploadsSubtitle =>
      'Включать ИИ по умолчанию при загрузке';

  @override
  String get summariesCreatedTitle => 'Создано сводок';

  @override
  String get summariesCreatedSubtitle => 'По всей библиотеке';

  @override
  String get storageSectionLabel => 'Хранилище';

  @override
  String get filesFolderTitle => 'Папка с файлами';

  @override
  String get movingFiles => 'Перемещение файлов…';

  @override
  String get couldNotReadFolder => 'Не удалось прочитать текущую папку';

  @override
  String get changeEllipsis => 'Изменить…';

  @override
  String get reset => 'Сбросить';

  @override
  String get chooseFolderDialogTitle =>
      'Выберите папку для хранения файлов Sift';

  @override
  String filesMovedBackTo(String path) {
    return 'Файлы перемещены обратно в $path';
  }

  @override
  String get librarySectionLabel => 'Библиотека';

  @override
  String get categoriesSubtitle => 'Добавление и удаление категорий';

  @override
  String get defaultSortTitle => 'Сортировка по умолчанию';

  @override
  String get securitySectionLabel => 'Безопасность';

  @override
  String get appLockTitle => 'Блокировка приложения';

  @override
  String get appLockSubtitle =>
      'Требовать PIN-код или биометрию для открытия Sift';

  @override
  String get changePinTitle => 'Изменить PIN-код';

  @override
  String get allCaughtUpTitle => 'Все дела разобраны';

  @override
  String allCaughtUpMessage(num days) {
    return 'В ближайшие $days дней ничего не истекает. Добавьте дату истечения к документу, и он появится здесь.';
  }

  @override
  String get bucketOverdue => 'Просрочено';

  @override
  String get bucketThisWeek => 'На этой неделе';

  @override
  String get bucketThisMonth => 'В этом месяце';

  @override
  String get bucketComingUp => 'Скоро';

  @override
  String get renew => 'Продлить';

  @override
  String get details => 'Подробнее';

  @override
  String get newExpirationDateHelp => 'Новая дата истечения';

  @override
  String renewedSnackbar(String name) {
    return '«$name» продлён';
  }

  @override
  String get expiresToday => 'Истекает сегодня';

  @override
  String get expiresTomorrow => 'Истекает завтра';

  @override
  String get expiredYesterday => 'Истёк вчера';

  @override
  String expiredDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Истёк $count дней назад',
      many: 'Истёк $count дней назад',
      few: 'Истёк $count дня назад',
      one: 'Истёк $count день назад',
    );
    return '$_temp0';
  }

  @override
  String expiredMonthsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Истёк $count месяцев назад',
      many: 'Истёк $count месяцев назад',
      few: 'Истёк $count месяца назад',
      one: 'Истёк $count месяц назад',
    );
    return '$_temp0';
  }

  @override
  String expiresInDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Истекает через $count дней',
      many: 'Истекает через $count дней',
      few: 'Истекает через $count дня',
      one: 'Истекает через $count день',
    );
    return '$_temp0';
  }

  @override
  String expiresInWeeks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Истекает через $count недель',
      many: 'Истекает через $count недель',
      few: 'Истекает через $count недели',
      one: 'Истекает через $count неделю',
    );
    return '$_temp0';
  }

  @override
  String expiresInMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Истекает через $count месяцев',
      many: 'Истекает через $count месяцев',
      few: 'Истекает через $count месяца',
      one: 'Истекает через $count месяц',
    );
    return '$_temp0';
  }

  @override
  String get financeCategory => 'Финансы';

  @override
  String get healthCategory => 'Здоровье';

  @override
  String get housingCategory => 'Жильё';

  @override
  String get personalCategory => 'Личное';

  @override
  String get travelCategory => 'Путешествия';

  @override
  String get reminderNotificationTitle => 'Скоро истекает';

  @override
  String reminderNotificationBody(String name, String date) {
    return '«$name» истекает $date';
  }

  @override
  String get reminderChannelName => 'Напоминания об истечении срока';

  @override
  String get reminderChannelDescription =>
      'Напоминания для документов с установленной датой истечения';

  @override
  String get expiringBadge => 'Истекает';

  @override
  String disabledForNowSuffix(String subtitle) {
    return '$subtitle · пока отключено';
  }
}
