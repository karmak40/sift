// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navLibrary => 'Library';

  @override
  String get navComingUp => 'Coming up';

  @override
  String get navSettings => 'Settings';

  @override
  String get newCategoryTooltip => 'New category';

  @override
  String get searchHint => 'Search documents & summaries';

  @override
  String get allDocuments => 'All documents';

  @override
  String fileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return '$_temp0';
  }

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortRecent => 'Recent';

  @override
  String get sortNameAz => 'Name A–Z';

  @override
  String get sortLargest => 'Largest';

  @override
  String get categoryAll => 'All';

  @override
  String get emptyNoDocuments =>
      'No documents yet. Tap + to upload your first document.';

  @override
  String get emptyNoMatch => 'No documents match.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String selectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '$count selected',
    );
    return '$_temp0';
  }

  @override
  String get moveToEllipsis => 'Move to…';

  @override
  String get delete => 'Delete';

  @override
  String get clear => 'Clear';

  @override
  String deleteDocumentsConfirmTitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count documents?',
      one: 'Delete $count document?',
    );
    return '$_temp0';
  }

  @override
  String get deleteDocumentsConfirmMessage =>
      'This removes the selected files. This can\'t be undone.';

  @override
  String failedToLoad(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get noFileAttached => 'This document has no file attached to it.';

  @override
  String get fileMissingFromDisk => 'The file is missing from disk.';

  @override
  String get fileMissingFromDiskDetailed =>
      'The file is missing from disk — it may have been moved or deleted outside the app.';

  @override
  String get openNotSupportedWeb =>
      'Opening files isn\'t supported in the web preview yet — try Android, iOS, or the Windows app.';

  @override
  String deleteDocumentConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteDocumentConfirmMessage =>
      'This removes the document and its file. This can\'t be undone.';

  @override
  String get renameDocumentTitle => 'Rename document';

  @override
  String get deleteDocumentTooltip => 'Delete document';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String sizeAddedOn(String size, String date) {
    return '$size · added $date';
  }

  @override
  String documentPreviewLabel(String type) {
    return 'document preview · $type';
  }

  @override
  String expiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String remindMeDaysBeforeChange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remind me $count days before · change',
      one: 'Remind me $count day before · change',
    );
    return '$_temp0';
  }

  @override
  String get edit => 'Edit';

  @override
  String get notTrackingExpiration => 'Not tracking an expiration date';

  @override
  String get setDate => 'Set date';

  @override
  String get remindBeforeExpiresTitle => 'Remind me before it expires';

  @override
  String daysBeforeOption(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '$count day before',
    );
    return '$_temp0';
  }

  @override
  String get aiSummaryLabel => 'AI SUMMARY';

  @override
  String readingAndExtracting(String type) {
    return 'Reading $type and extracting key points…';
  }

  @override
  String get keyPointsLabel => 'KEY POINTS';

  @override
  String get aiDisabledLong =>
      'AI summaries are disabled for now. Enable the AI service to let it read this file and pull out key points.';

  @override
  String get aiNoSummaryYet =>
      'No summary yet. Turn on AI to read this file and pull out the important points.';

  @override
  String get summarizeWithAi => 'Summarize with AI';

  @override
  String get aiDisabledSnackbar => 'AI summaries are disabled for now.';

  @override
  String get openFile => 'Open file';

  @override
  String get share => 'Share';

  @override
  String get chooseFiles => 'Choose files';

  @override
  String get chooseFilesSubtitle => 'Pick one or more documents';

  @override
  String get scanDocument => 'Scan document';

  @override
  String get scanDocumentSubtitle => 'Use the camera to capture pages as a PDF';

  @override
  String scanFailed(String error) {
    return 'Couldn\'t scan the document: $error';
  }

  @override
  String get scanFilePrefix => 'Scan';

  @override
  String get addDocumentTitle => 'Add document';

  @override
  String get fileNameLabel => 'File name';

  @override
  String get typeLabel => 'Type';

  @override
  String get categoryLabel => 'Category';

  @override
  String get aiOptionalSubtitle => 'Optional — extract key points';

  @override
  String addDocumentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count documents',
      one: 'Add $count document',
    );
    return '$_temp0';
  }

  @override
  String get batchSameCategoryNote =>
      'They\'ll all go into the same category, keeping their file names.';

  @override
  String deleteCategoryConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteCategoryConfirmMessageEmpty =>
      'This category has no documents. This can\'t be undone.';

  @override
  String deleteCategoryConfirmMessageWithDocs(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count documents in this category will become uncategorized rather than being deleted. This can\'t be undone.',
      one:
          '$count document in this category will become uncategorized rather than being deleted. This can\'t be undone.',
    );
    return '$_temp0';
  }

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get newCategoryButton => 'New';

  @override
  String get noCategoriesYet => 'No categories yet.';

  @override
  String get deleteCategoryTooltip => 'Delete category';

  @override
  String get editCategoryTooltip => 'Edit category';

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get editCategoryTitle => 'Edit category';

  @override
  String get categoryNamePlaceholder => 'Category name';

  @override
  String get nameLabel => 'Name';

  @override
  String get categoryNameHint => 'e.g. Warranties';

  @override
  String get colorLabel => 'Color';

  @override
  String get previewLabel => 'preview';

  @override
  String get createCategoryButton => 'Create category';

  @override
  String moveToCount(num count) {
    return 'Move $count to…';
  }

  @override
  String get siftLocked => 'Sift is locked';

  @override
  String get enterPinToContinue => 'Enter your PIN to continue';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get unlock => 'Unlock';

  @override
  String get useBiometricUnlock => 'Use biometric unlock';

  @override
  String get biometricUnlockReason => 'Unlock Sift';

  @override
  String get forgotPinButton => 'Forgot PIN?';

  @override
  String get resetPinReason => 'Verify your device to reset your Sift PIN';

  @override
  String get resetPinFailedTitle => 'Couldn\'t verify your device';

  @override
  String get resetPinFailedMessage =>
      'Make sure your phone has a screen lock (PIN, pattern, fingerprint, or face) set up, then try again. If it truly has none, resetting Sift\'s PIN isn\'t possible without uninstalling and reinstalling the app — which deletes all your local documents.';

  @override
  String pinMinLength(num count) {
    return 'PIN must be at least $count digits';
  }

  @override
  String get confirmYourPin => 'Confirm your PIN';

  @override
  String get setAPin => 'Set a PIN';

  @override
  String get enterItOneMoreTime => 'Enter it one more time';

  @override
  String get youllUseThisToUnlock => 'You\'ll use this to unlock Sift';

  @override
  String get pinsDontMatch => 'PINs don\'t match';

  @override
  String get savePin => 'Save PIN';

  @override
  String get continueButton => 'Continue';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSectionLabel => 'General';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get aiSectionLabel => 'AI';

  @override
  String get summarizeNewUploads => 'Summarize new uploads';

  @override
  String get summarizeNewUploadsSubtitle =>
      'Default the AI toggle on when uploading';

  @override
  String get summariesCreatedTitle => 'Summaries created';

  @override
  String get summariesCreatedSubtitle => 'Across your whole library';

  @override
  String get storageSectionLabel => 'Storage';

  @override
  String get filesFolderTitle => 'Files folder';

  @override
  String get movingFiles => 'Moving files…';

  @override
  String get couldNotReadFolder => 'Could not read current folder';

  @override
  String get changeEllipsis => 'Change…';

  @override
  String get reset => 'Reset';

  @override
  String get chooseFolderDialogTitle =>
      'Choose a folder to store Sift files in';

  @override
  String filesMovedBackTo(String path) {
    return 'Files moved back to $path';
  }

  @override
  String get librarySectionLabel => 'Library';

  @override
  String get categoriesSubtitle => 'Add or remove categories';

  @override
  String get defaultSortTitle => 'Default sort';

  @override
  String get securitySectionLabel => 'Security';

  @override
  String get appLockTitle => 'App Lock';

  @override
  String get appLockSubtitle => 'Require a PIN or biometric to open Sift';

  @override
  String get changePinTitle => 'Change PIN';

  @override
  String get allCaughtUpTitle => 'You\'re all caught up';

  @override
  String allCaughtUpMessage(num days) {
    return 'Nothing expires in the next $days days. Add an expiration date to a document and it\'ll show up here.';
  }

  @override
  String get bucketOverdue => 'Overdue';

  @override
  String get bucketThisWeek => 'This week';

  @override
  String get bucketThisMonth => 'This month';

  @override
  String get bucketComingUp => 'Coming up';

  @override
  String get renew => 'Renew';

  @override
  String get details => 'Details';

  @override
  String get newExpirationDateHelp => 'New expiration date';

  @override
  String renewedSnackbar(String name) {
    return 'Renewed \"$name\"';
  }

  @override
  String get expiresToday => 'Expires today';

  @override
  String get expiresTomorrow => 'Expires tomorrow';

  @override
  String get expiredYesterday => 'Expired yesterday';

  @override
  String expiredDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expired $count days ago',
      one: 'Expired $count day ago',
    );
    return '$_temp0';
  }

  @override
  String expiredMonthsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expired $count months ago',
      one: 'Expired $count month ago',
    );
    return '$_temp0';
  }

  @override
  String expiresInDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expires in $count days',
      one: 'Expires in $count day',
    );
    return '$_temp0';
  }

  @override
  String expiresInWeeks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expires in $count weeks',
      one: 'Expires in $count week',
    );
    return '$_temp0';
  }

  @override
  String expiresInMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expires in $count months',
      one: 'Expires in $count month',
    );
    return '$_temp0';
  }

  @override
  String get financeCategory => 'Finance';

  @override
  String get healthCategory => 'Health';

  @override
  String get housingCategory => 'Housing';

  @override
  String get personalCategory => 'Personal';

  @override
  String get travelCategory => 'Travel';

  @override
  String get reminderNotificationTitle => 'Expiring soon';

  @override
  String reminderNotificationBody(String name, String date) {
    return '\"$name\" expires $date';
  }

  @override
  String get reminderChannelName => 'Expiration reminders';

  @override
  String get reminderChannelDescription =>
      'Reminders for documents you set an expiration date on';

  @override
  String get expiringBadge => 'Expiring';

  @override
  String disabledForNowSuffix(String subtitle) {
    return '$subtitle · disabled for now';
  }

  @override
  String get backupSectionLabel => 'Backup';

  @override
  String get backupIntro =>
      'Everything stays on this device. Back up to a file you control, and restore it any time — even on a different phone.';

  @override
  String get backUpNowTitle => 'Back up now';

  @override
  String get backUpNowSubtitle =>
      'Save all documents and categories to a single file';

  @override
  String get restoreTitle => 'Restore from backup…';

  @override
  String get restoreSubtitle => 'Replace everything with a previous backup';

  @override
  String get saveBackupDialogTitle => 'Save Sift backup';

  @override
  String get backupSavedSnackbar => 'Backup saved';

  @override
  String backupFailedSnackbar(String error) {
    return 'Couldn\'t create backup: $error';
  }

  @override
  String get chooseBackupFileDialogTitle => 'Choose a Sift backup file';

  @override
  String get restoreConfirmTitle => 'Restore from backup?';

  @override
  String get restoreConfirmMessage =>
      'This replaces every document and category currently in Sift with what\'s in this backup file. This can\'t be undone.';

  @override
  String get restoreConfirmButton => 'Restore';

  @override
  String get restoreCompleteTitle => 'Restore complete';

  @override
  String get restoreCompleteMessage =>
      'Close and reopen Sift to see your restored documents.';

  @override
  String get gotIt => 'Got it';

  @override
  String restoreFailedSnackbar(String error) {
    return 'Couldn\'t restore backup: $error';
  }

  @override
  String get invalidBackupFile => 'This doesn\'t look like a Sift backup file.';

  @override
  String get backupTooNew =>
      'This backup was made with a newer version of Sift and can\'t be restored here.';

  @override
  String get aboutSectionLabel => 'About';

  @override
  String get versionTitle => 'Version';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get notNow => 'Not now';

  @override
  String get cameraPrimerTitle => 'Scan with your camera';

  @override
  String get cameraPrimerMessage =>
      'Sift needs camera access to turn paper documents into a PDF. Photos are processed entirely on this device and are never uploaded anywhere.';

  @override
  String get biometricPrimerTitle => 'Enable biometric unlock?';

  @override
  String get biometricPrimerMessage =>
      'Sift can also use your device\'s fingerprint or face unlock for faster access, instead of typing your PIN every time. You can turn this off again in Settings.';

  @override
  String get resetPinPrimerTitle => 'Verify it\'s you';

  @override
  String get resetPinPrimerMessage =>
      'To reset your PIN, Sift will ask your device to confirm it\'s you — using your fingerprint, face, or your phone\'s own screen lock. Nothing about your documents changes; you\'ll just choose a new PIN afterward.';

  @override
  String get notificationsPrimerTitle => 'Remind you before documents expire?';

  @override
  String get notificationsPrimerMessage =>
      'Sift can send a local reminder a few weeks before a document like a passport or policy expires. These reminders are scheduled entirely on this device — no server involved.';

  @override
  String get openSettingsButton => 'Open Settings';

  @override
  String get cameraPermissionDeniedTitle => 'Camera access is off';

  @override
  String get cameraPermissionDeniedMessage =>
      'Sift can\'t scan documents without camera access. Turn it on for Sift in Settings, then try scanning again.';

  @override
  String get notificationsPermissionDeniedTitle => 'Reminders are off';

  @override
  String get notificationsPermissionDeniedMessage =>
      'Notifications are turned off for Sift, so this reminder won\'t actually notify you — but the expiration date is saved and will still show up in Coming Up. Turn notifications on in Settings if you\'d like a reminder too.';

  @override
  String get splashTagline => 'Tidy files, happy mind';

  @override
  String get onboardingStoreTitle => 'Everything in one place';

  @override
  String get onboardingStoreBody =>
      'Upload files or scan paper documents with your camera — everything lands safely in your library, stored right on this device.';

  @override
  String get onboardingOrganizeTitle => 'Organize your way';

  @override
  String get onboardingOrganizeBody =>
      'Sort documents into categories you create — Finance, Health, Travel, whatever makes sense to you.';

  @override
  String get onboardingFindTitle => 'Find it in a snap';

  @override
  String get onboardingFindBody =>
      'Search by name, filter by category, and get reminded before anything important expires.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';
}
