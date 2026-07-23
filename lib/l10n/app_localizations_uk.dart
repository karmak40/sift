// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get navLibrary => 'Бібліотека';

  @override
  String get navComingUp => 'Найближчі';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get newCategoryTooltip => 'Нова категорія';

  @override
  String get searchHint => 'Пошук документів і описів';

  @override
  String get allDocuments => 'Усі документи';

  @override
  String fileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файлів',
      many: '$count файлів',
      few: '$count файли',
      one: '$count файл',
    );
    return '$_temp0';
  }

  @override
  String get sortTooltip => 'Сортування';

  @override
  String get sortRecent => 'Останні';

  @override
  String get sortNameAz => 'За назвою А–Я';

  @override
  String get sortLargest => 'Найбільші';

  @override
  String get categoryAll => 'Усі';

  @override
  String get emptyNoDocuments =>
      'Поки немає документів. Натисніть +, щоб завантажити перший документ.';

  @override
  String get emptyNoMatch => 'Документів не знайдено.';

  @override
  String get clearFilters => 'Скинути фільтри';

  @override
  String selectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вибрано: $count',
      many: 'Вибрано: $count',
      few: 'Вибрано: $count',
      one: 'Вибрано: $count',
    );
    return '$_temp0';
  }

  @override
  String get moveToEllipsis => 'Перемістити до…';

  @override
  String get delete => 'Видалити';

  @override
  String get clear => 'Очистити';

  @override
  String deleteDocumentsConfirmTitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Видалити $count документів?',
      many: 'Видалити $count документів?',
      few: 'Видалити $count документи?',
      one: 'Видалити $count документ?',
    );
    return '$_temp0';
  }

  @override
  String get deleteDocumentsConfirmMessage =>
      'Вибрані файли буде видалено. Це неможливо скасувати.';

  @override
  String failedToLoad(String error) {
    return 'Не вдалося завантажити: $error';
  }

  @override
  String get noFileAttached => 'До цього документа не прикріплено файл.';

  @override
  String get fileMissingFromDisk => 'Файл відсутній на диску.';

  @override
  String get fileMissingFromDiskDetailed =>
      'Файл відсутній на диску — можливо, його перемістили або видалили поза застосунком.';

  @override
  String get openNotSupportedWeb =>
      'Відкриття файлів поки не підтримується у веб-версії — спробуйте Android, iOS або застосунок для Windows.';

  @override
  String deleteDocumentConfirmTitle(String name) {
    return 'Видалити «$name»?';
  }

  @override
  String get deleteDocumentConfirmMessage =>
      'Документ і його файл буде видалено. Це неможливо скасувати.';

  @override
  String get renameDocumentTitle => 'Перейменувати документ';

  @override
  String get deleteDocumentTooltip => 'Видалити документ';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get uncategorized => 'Без категорії';

  @override
  String sizeAddedOn(String size, String date) {
    return '$size · додано $date';
  }

  @override
  String documentPreviewLabel(String type) {
    return 'перегляд документа · $type';
  }

  @override
  String expiresOn(String date) {
    return 'Закінчується $date';
  }

  @override
  String remindMeDaysBeforeChange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Нагадати за $count днів · змінити',
      many: 'Нагадати за $count днів · змінити',
      few: 'Нагадати за $count дні · змінити',
      one: 'Нагадати за $count день · змінити',
    );
    return '$_temp0';
  }

  @override
  String get edit => 'Редагувати';

  @override
  String get notTrackingExpiration => 'Термін дії не відстежується';

  @override
  String get setDate => 'Вказати дату';

  @override
  String get remindBeforeExpiresTitle => 'Нагадати перед закінченням терміну';

  @override
  String daysBeforeOption(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count днів',
      many: 'За $count днів',
      few: 'За $count дні',
      one: 'За $count день',
    );
    return '$_temp0';
  }

  @override
  String get aiSummaryLabel => 'ШІ-РЕЗЮМЕ';

  @override
  String readingAndExtracting(String type) {
    return 'Читання $type і виділення ключових моментів…';
  }

  @override
  String get keyPointsLabel => 'КЛЮЧОВІ МОМЕНТИ';

  @override
  String get aiDisabledLong =>
      'Резюме ШІ поки вимкнено. Увімкніть сервіс ШІ, щоб він прочитав файл і виділив ключові моменти.';

  @override
  String get aiNoSummaryYet =>
      'Резюме ще немає. Увімкніть ШІ, щоб прочитати файл і виділити важливі моменти.';

  @override
  String get summarizeWithAi => 'Створити резюме за допомогою ШІ';

  @override
  String get aiDisabledSnackbar => 'Резюме ШІ поки вимкнено.';

  @override
  String get openFile => 'Відкрити файл';

  @override
  String get share => 'Поділитися';

  @override
  String get chooseFiles => 'Вибрати файли';

  @override
  String get chooseFilesSubtitle => 'Виберіть один або кілька документів';

  @override
  String get scanDocument => 'Сканувати документ';

  @override
  String get scanDocumentSubtitle =>
      'Зніміть сторінки камерою, щоб створити PDF';

  @override
  String scanFailed(String error) {
    return 'Не вдалося відсканувати документ: $error';
  }

  @override
  String get scanFilePrefix => 'Скан';

  @override
  String get addDocumentTitle => 'Додати документ';

  @override
  String get fileNameLabel => 'Назва файлу';

  @override
  String get typeLabel => 'Тип';

  @override
  String get categoryLabel => 'Категорія';

  @override
  String get aiOptionalSubtitle => 'Необов\'язково — виділити ключові моменти';

  @override
  String addDocumentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Додати $count документів',
      many: 'Додати $count документів',
      few: 'Додати $count документи',
      one: 'Додати $count документ',
    );
    return '$_temp0';
  }

  @override
  String get batchSameCategoryNote =>
      'Усі вони потраплять в одну категорію зі збереженням назв файлів.';

  @override
  String deleteCategoryConfirmTitle(String name) {
    return 'Видалити «$name»?';
  }

  @override
  String get deleteCategoryConfirmMessageEmpty =>
      'У цій категорії немає документів. Це неможливо скасувати.';

  @override
  String deleteCategoryConfirmMessageWithDocs(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count документів у цій категорії стануть без категорії, а не будуть видалені. Це неможливо скасувати.',
      many:
          '$count документів у цій категорії стануть без категорії, а не будуть видалені. Це неможливо скасувати.',
      few:
          '$count документи у цій категорії стануть без категорії, а не будуть видалені. Це неможливо скасувати.',
      one:
          '$count документ у цій категорії стане без категорії, а не буде видалений. Це неможливо скасувати.',
    );
    return '$_temp0';
  }

  @override
  String get categoriesTitle => 'Категорії';

  @override
  String get newCategoryButton => 'Нова';

  @override
  String get noCategoriesYet => 'Категорій ще немає.';

  @override
  String get deleteCategoryTooltip => 'Видалити категорію';

  @override
  String get editCategoryTooltip => 'Редагувати категорію';

  @override
  String get newCategoryTitle => 'Нова категорія';

  @override
  String get editCategoryTitle => 'Редагувати категорію';

  @override
  String get categoryNamePlaceholder => 'Назва категорії';

  @override
  String get nameLabel => 'Назва';

  @override
  String get categoryNameHint => 'напр., Гарантії';

  @override
  String get colorLabel => 'Колір';

  @override
  String get previewLabel => 'перегляд';

  @override
  String get createCategoryButton => 'Створити категорію';

  @override
  String moveToCount(num count) {
    return 'Перемістити $count до…';
  }

  @override
  String get siftLocked => 'Sift заблоковано';

  @override
  String get enterPinToContinue => 'Введіть PIN-код, щоб продовжити';

  @override
  String get incorrectPin => 'Невірний PIN-код';

  @override
  String get unlock => 'Розблокувати';

  @override
  String get useBiometricUnlock => 'Розблокувати за біометрією';

  @override
  String get biometricUnlockReason => 'Розблокувати Sift';

  @override
  String get forgotPinButton => 'Забули PIN-код?';

  @override
  String get resetPinReason =>
      'Підтвердьте особу на пристрої, щоб скинути PIN-код Sift';

  @override
  String get resetPinFailedTitle => 'Не вдалося підтвердити особу';

  @override
  String get resetPinFailedMessage =>
      'Переконайтеся, що на телефоні увімкнено блокування екрана (PIN-код, ключ малюнка, відбиток пальця або обличчя), і спробуйте ще раз. Якщо блокування екрана немає взагалі, скинути PIN-код Sift можна лише видаливши й заново встановивши застосунок — це видалить усі локальні документи.';

  @override
  String pinMinLength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'PIN-код має містити щонайменше $count цифр',
      many: 'PIN-код має містити щонайменше $count цифр',
      few: 'PIN-код має містити щонайменше $count цифри',
      one: 'PIN-код має містити щонайменше $count цифру',
    );
    return '$_temp0';
  }

  @override
  String get confirmYourPin => 'Підтвердьте PIN-код';

  @override
  String get setAPin => 'Встановіть PIN-код';

  @override
  String get enterItOneMoreTime => 'Введіть його ще раз';

  @override
  String get youllUseThisToUnlock => 'Він знадобиться для розблокування Sift';

  @override
  String get pinsDontMatch => 'PIN-коди не збігаються';

  @override
  String get savePin => 'Зберегти PIN-код';

  @override
  String get continueButton => 'Продовжити';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get generalSectionLabel => 'Загальні';

  @override
  String get languageTitle => 'Мова';

  @override
  String get languageSystemDefault => 'Як у системі';

  @override
  String get aiSectionLabel => 'ШІ';

  @override
  String get summarizeNewUploads => 'Створювати резюме для нових файлів';

  @override
  String get summarizeNewUploadsSubtitle =>
      'Вмикати ШІ за замовчуванням під час завантаження';

  @override
  String get summariesCreatedTitle => 'Створено резюме';

  @override
  String get summariesCreatedSubtitle => 'У всій бібліотеці';

  @override
  String get storageSectionLabel => 'Сховище';

  @override
  String get filesFolderTitle => 'Папка з файлами';

  @override
  String get movingFiles => 'Переміщення файлів…';

  @override
  String get couldNotReadFolder => 'Не вдалося прочитати поточну папку';

  @override
  String get changeEllipsis => 'Змінити…';

  @override
  String get reset => 'Скинути';

  @override
  String get chooseFolderDialogTitle =>
      'Виберіть папку для зберігання файлів Sift';

  @override
  String filesMovedBackTo(String path) {
    return 'Файли переміщено назад до $path';
  }

  @override
  String get librarySectionLabel => 'Бібліотека';

  @override
  String get categoriesSubtitle => 'Додавання й видалення категорій';

  @override
  String get defaultSortTitle => 'Сортування за замовчуванням';

  @override
  String get securitySectionLabel => 'Безпека';

  @override
  String get appLockTitle => 'Блокування застосунку';

  @override
  String get appLockSubtitle =>
      'Вимагати PIN-код або біометрію для відкриття Sift';

  @override
  String get changePinTitle => 'Змінити PIN-код';

  @override
  String get allCaughtUpTitle => 'Усі справи розібрано';

  @override
  String allCaughtUpMessage(num days) {
    return 'Найближчі $days днів нічого не закінчується. Додайте дату закінчення до документа, і він з\'явиться тут.';
  }

  @override
  String get bucketOverdue => 'Прострочено';

  @override
  String get bucketThisWeek => 'На цьому тижні';

  @override
  String get bucketThisMonth => 'Цього місяця';

  @override
  String get bucketComingUp => 'Незабаром';

  @override
  String get renew => 'Продовжити';

  @override
  String get details => 'Деталі';

  @override
  String get newExpirationDateHelp => 'Нова дата закінчення';

  @override
  String renewedSnackbar(String name) {
    return '«$name» продовжено';
  }

  @override
  String get expiresToday => 'Закінчується сьогодні';

  @override
  String get expiresTomorrow => 'Закінчується завтра';

  @override
  String get expiredYesterday => 'Закінчився вчора';

  @override
  String expiredDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Закінчився $count днів тому',
      many: 'Закінчився $count днів тому',
      few: 'Закінчився $count дні тому',
      one: 'Закінчився $count день тому',
    );
    return '$_temp0';
  }

  @override
  String expiredMonthsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Закінчився $count місяців тому',
      many: 'Закінчився $count місяців тому',
      few: 'Закінчився $count місяці тому',
      one: 'Закінчився $count місяць тому',
    );
    return '$_temp0';
  }

  @override
  String expiresInDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Закінчується через $count днів',
      many: 'Закінчується через $count днів',
      few: 'Закінчується через $count дні',
      one: 'Закінчується через $count день',
    );
    return '$_temp0';
  }

  @override
  String expiresInWeeks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Закінчується через $count тижнів',
      many: 'Закінчується через $count тижнів',
      few: 'Закінчується через $count тижні',
      one: 'Закінчується через $count тиждень',
    );
    return '$_temp0';
  }

  @override
  String expiresInMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Закінчується через $count місяців',
      many: 'Закінчується через $count місяців',
      few: 'Закінчується через $count місяці',
      one: 'Закінчується через $count місяць',
    );
    return '$_temp0';
  }

  @override
  String get financeCategory => 'Фінанси';

  @override
  String get healthCategory => 'Здоров\'я';

  @override
  String get housingCategory => 'Житло';

  @override
  String get personalCategory => 'Особисте';

  @override
  String get travelCategory => 'Подорожі';

  @override
  String get reminderNotificationTitle => 'Скоро закінчується';

  @override
  String reminderNotificationBody(String name, String date) {
    return '«$name» закінчується $date';
  }

  @override
  String get reminderChannelName => 'Нагадування про закінчення терміну';

  @override
  String get reminderChannelDescription =>
      'Нагадування для документів із встановленою датою закінчення';

  @override
  String get expiringBadge => 'Закінчується';

  @override
  String disabledForNowSuffix(String subtitle) {
    return '$subtitle · поки вимкнено';
  }

  @override
  String get backupSectionLabel => 'Резервне копіювання';

  @override
  String get backupIntro =>
      'Усе залишається на цьому пристрої. Створіть резервну копію у файл, який контролюєте ви, і відновіть її будь-коли — навіть на іншому телефоні.';

  @override
  String get backUpNowTitle => 'Створити резервну копію';

  @override
  String get backUpNowSubtitle =>
      'Зберегти всі документи й категорії в один файл';

  @override
  String get restoreTitle => 'Відновити з резервної копії…';

  @override
  String get restoreSubtitle => 'Замінити все вмістом попередньої копії';

  @override
  String get saveBackupDialogTitle => 'Зберегти резервну копію Sift';

  @override
  String get backupSavedSnackbar => 'Резервну копію збережено';

  @override
  String backupFailedSnackbar(String error) {
    return 'Не вдалося створити резервну копію: $error';
  }

  @override
  String get chooseBackupFileDialogTitle =>
      'Виберіть файл резервної копії Sift';

  @override
  String get restoreConfirmTitle => 'Відновити з резервної копії?';

  @override
  String get restoreConfirmMessage =>
      'Це замінить усі документи й категорії, які зараз є в Sift, вмістом цього файлу резервної копії. Це неможливо скасувати.';

  @override
  String get restoreConfirmButton => 'Відновити';

  @override
  String get restoreCompleteTitle => 'Відновлення завершено';

  @override
  String get restoreCompleteMessage =>
      'Закрийте і знову відкрийте Sift, щоб побачити відновлені документи.';

  @override
  String get gotIt => 'Зрозуміло';

  @override
  String restoreFailedSnackbar(String error) {
    return 'Не вдалося відновити резервну копію: $error';
  }

  @override
  String get invalidBackupFile => 'Це не схоже на файл резервної копії Sift.';

  @override
  String get backupTooNew =>
      'Цю резервну копію створено новішою версією Sift, і її не можна відновити тут.';

  @override
  String get aboutSectionLabel => 'Про застосунок';

  @override
  String get versionTitle => 'Версія';

  @override
  String get privacyPolicyTitle => 'Політика конфіденційності';

  @override
  String get notNow => 'Не зараз';

  @override
  String get cameraPrimerTitle => 'Сканування камерою';

  @override
  String get cameraPrimerMessage =>
      'Sift потрібен доступ до камери, щоб перетворити паперові документи на PDF. Фото обробляються повністю на цьому пристрої і нікуди не завантажуються.';

  @override
  String get biometricPrimerTitle => 'Увімкнути розблокування за біометрією?';

  @override
  String get biometricPrimerMessage =>
      'Sift може використовувати відбиток пальця або розпізнавання обличчя для швидшого доступу замість введення PIN-коду щоразу. Ви можете вимкнути це пізніше в налаштуваннях.';

  @override
  String get resetPinPrimerTitle => 'Підтвердьте особу';

  @override
  String get resetPinPrimerMessage =>
      'Щоб скинути PIN-код, Sift попросить ваш пристрій підтвердити, що це ви, — за допомогою відбитка пальця, обличчя або екрана блокування телефону. З вашими документами нічого не зміниться — ви просто оберете новий PIN-код.';

  @override
  String get notificationsPrimerTitle =>
      'Нагадувати перед закінченням терміну документів?';

  @override
  String get notificationsPrimerMessage =>
      'Sift може надсилати локальне нагадування за кілька тижнів до закінчення терміну дії документа, наприклад паспорта чи поліса. Ці нагадування плануються повністю на цьому пристрої — без участі сервера.';

  @override
  String get openSettingsButton => 'Відкрити налаштування';

  @override
  String get cameraPermissionDeniedTitle => 'Доступ до камери вимкнено';

  @override
  String get cameraPermissionDeniedMessage =>
      'Sift не може сканувати документи без доступу до камери. Увімкніть його для Sift у налаштуваннях пристрою й спробуйте ще раз.';

  @override
  String get notificationsPermissionDeniedTitle => 'Нагадування вимкнено';

  @override
  String get notificationsPermissionDeniedMessage =>
      'Сповіщення для Sift вимкнено, тому це нагадування не спрацює — але дату закінчення терміну збережено, і вона з\'явиться на вкладці «Незабаром». Увімкніть сповіщення в налаштуваннях, якщо хочете отримувати нагадування.';

  @override
  String get splashTagline => 'Порядок у файлах — спокій у голові';

  @override
  String get onboardingStoreTitle => 'Усе в одному місці';

  @override
  String get onboardingStoreBody =>
      'Завантажуйте файли або скануйте паперові документи камерою — усе надійно потрапляє в бібліотеку і зберігається прямо на цьому пристрої.';

  @override
  String get onboardingOrganizeTitle => 'Організовуйте по-своєму';

  @override
  String get onboardingOrganizeBody =>
      'Розподіляйте документи за категоріями, які створюєте самі, — Фінанси, Здоров\'я, Подорожі, що завгодно.';

  @override
  String get onboardingFindTitle => 'Знаходьте за секунду';

  @override
  String get onboardingFindBody =>
      'Шукайте за назвою, фільтруйте за категорією та отримуйте нагадування, перш ніж щось важливе закінчиться.';

  @override
  String get onboardingNext => 'Далі';

  @override
  String get onboardingGetStarted => 'Розпочати';
}
