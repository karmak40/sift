import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('uk'),
  ];

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navComingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get navComingUp;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @newCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategoryTooltip;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search documents & summaries'**
  String get searchHint;

  /// No description provided for @allDocuments.
  ///
  /// In en, this message translates to:
  /// **'All documents'**
  String get allDocuments;

  /// No description provided for @fileCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} file} other{{count} files}}'**
  String fileCount(num count);

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get sortRecent;

  /// No description provided for @sortNameAz.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get sortNameAz;

  /// No description provided for @sortLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get sortLargest;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @emptyNoDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents yet. Tap + to upload your first document.'**
  String get emptyNoDocuments;

  /// No description provided for @emptyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No documents match.'**
  String get emptyNoMatch;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} selected} other{{count} selected}}'**
  String selectedCount(num count);

  /// No description provided for @moveToEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get moveToEllipsis;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @deleteDocumentsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Delete {count} document?} other{Delete {count} documents?}}'**
  String deleteDocumentsConfirmTitle(num count);

  /// No description provided for @deleteDocumentsConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the selected files. This can\'t be undone.'**
  String get deleteDocumentsConfirmMessage;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String failedToLoad(String error);

  /// No description provided for @noFileAttached.
  ///
  /// In en, this message translates to:
  /// **'This document has no file attached to it.'**
  String get noFileAttached;

  /// No description provided for @fileMissingFromDisk.
  ///
  /// In en, this message translates to:
  /// **'The file is missing from disk.'**
  String get fileMissingFromDisk;

  /// No description provided for @fileMissingFromDiskDetailed.
  ///
  /// In en, this message translates to:
  /// **'The file is missing from disk — it may have been moved or deleted outside the app.'**
  String get fileMissingFromDiskDetailed;

  /// No description provided for @openNotSupportedWeb.
  ///
  /// In en, this message translates to:
  /// **'Opening files isn\'t supported in the web preview yet — try Android, iOS, or the Windows app.'**
  String get openNotSupportedWeb;

  /// No description provided for @deleteDocumentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteDocumentConfirmTitle(String name);

  /// No description provided for @deleteDocumentConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the document and its file. This can\'t be undone.'**
  String get deleteDocumentConfirmMessage;

  /// No description provided for @renameDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename document'**
  String get renameDocumentTitle;

  /// No description provided for @deleteDocumentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete document'**
  String get deleteDocumentTooltip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @sizeAddedOn.
  ///
  /// In en, this message translates to:
  /// **'{size} · added {date}'**
  String sizeAddedOn(String size, String date);

  /// No description provided for @documentPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'document preview · {type}'**
  String documentPreviewLabel(String type);

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresOn(String date);

  /// No description provided for @remindMeDaysBeforeChange.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Remind me {count} day before · change} other{Remind me {count} days before · change}}'**
  String remindMeDaysBeforeChange(num count);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @notTrackingExpiration.
  ///
  /// In en, this message translates to:
  /// **'Not tracking an expiration date'**
  String get notTrackingExpiration;

  /// No description provided for @setDate.
  ///
  /// In en, this message translates to:
  /// **'Set date'**
  String get setDate;

  /// No description provided for @remindBeforeExpiresTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me before it expires'**
  String get remindBeforeExpiresTitle;

  /// No description provided for @daysBeforeOption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day before} other{{count} days before}}'**
  String daysBeforeOption(num count);

  /// No description provided for @aiSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'AI SUMMARY'**
  String get aiSummaryLabel;

  /// No description provided for @readingAndExtracting.
  ///
  /// In en, this message translates to:
  /// **'Reading {type} and extracting key points…'**
  String readingAndExtracting(String type);

  /// No description provided for @keyPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'KEY POINTS'**
  String get keyPointsLabel;

  /// No description provided for @aiDisabledLong.
  ///
  /// In en, this message translates to:
  /// **'AI summaries are disabled for now. Enable the AI service to let it read this file and pull out key points.'**
  String get aiDisabledLong;

  /// No description provided for @aiNoSummaryYet.
  ///
  /// In en, this message translates to:
  /// **'No summary yet. Turn on AI to read this file and pull out the important points.'**
  String get aiNoSummaryYet;

  /// No description provided for @summarizeWithAi.
  ///
  /// In en, this message translates to:
  /// **'Summarize with AI'**
  String get summarizeWithAi;

  /// No description provided for @aiDisabledSnackbar.
  ///
  /// In en, this message translates to:
  /// **'AI summaries are disabled for now.'**
  String get aiDisabledSnackbar;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get openFile;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @chooseFiles.
  ///
  /// In en, this message translates to:
  /// **'Choose files'**
  String get chooseFiles;

  /// No description provided for @chooseFilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one or more documents'**
  String get chooseFilesSubtitle;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get scanDocument;

  /// No description provided for @scanDocumentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the camera to capture pages as a PDF'**
  String get scanDocumentSubtitle;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t scan the document: {error}'**
  String scanFailed(String error);

  /// No description provided for @scanFilePrefix.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanFilePrefix;

  /// No description provided for @addDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get addDocumentTitle;

  /// No description provided for @fileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileNameLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @aiOptionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — extract key points'**
  String get aiOptionalSubtitle;

  /// No description provided for @addDocumentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Add {count} document} other{Add {count} documents}}'**
  String addDocumentsCount(num count);

  /// No description provided for @batchSameCategoryNote.
  ///
  /// In en, this message translates to:
  /// **'They\'ll all go into the same category, keeping their file names.'**
  String get batchSameCategoryNote;

  /// No description provided for @deleteCategoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteCategoryConfirmTitle(String name);

  /// No description provided for @deleteCategoryConfirmMessageEmpty.
  ///
  /// In en, this message translates to:
  /// **'This category has no documents. This can\'t be undone.'**
  String get deleteCategoryConfirmMessageEmpty;

  /// No description provided for @deleteCategoryConfirmMessageWithDocs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} document in this category will become uncategorized rather than being deleted. This can\'t be undone.} other{{count} documents in this category will become uncategorized rather than being deleted. This can\'t be undone.}}'**
  String deleteCategoryConfirmMessageWithDocs(num count);

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @newCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCategoryButton;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.'**
  String get noCategoriesYet;

  /// No description provided for @deleteCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryTooltip;

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategoryTitle;

  /// No description provided for @categoryNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNamePlaceholder;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Warranties'**
  String get categoryNameHint;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'preview'**
  String get previewLabel;

  /// No description provided for @createCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get createCategoryButton;

  /// No description provided for @moveToCount.
  ///
  /// In en, this message translates to:
  /// **'Move {count} to…'**
  String moveToCount(num count);

  /// No description provided for @siftLocked.
  ///
  /// In en, this message translates to:
  /// **'Sift is locked'**
  String get siftLocked;

  /// No description provided for @enterPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue'**
  String get enterPinToContinue;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @useBiometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Use biometric unlock'**
  String get useBiometricUnlock;

  /// No description provided for @biometricUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Sift'**
  String get biometricUnlockReason;

  /// No description provided for @pinMinLength.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least {count} digits'**
  String pinMinLength(num count);

  /// No description provided for @confirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirmYourPin;

  /// No description provided for @setAPin.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get setAPin;

  /// No description provided for @enterItOneMoreTime.
  ///
  /// In en, this message translates to:
  /// **'Enter it one more time'**
  String get enterItOneMoreTime;

  /// No description provided for @youllUseThisToUnlock.
  ///
  /// In en, this message translates to:
  /// **'You\'ll use this to unlock Sift'**
  String get youllUseThisToUnlock;

  /// No description provided for @pinsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match'**
  String get pinsDontMatch;

  /// No description provided for @savePin.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get savePin;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSectionLabel;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @aiSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiSectionLabel;

  /// No description provided for @summarizeNewUploads.
  ///
  /// In en, this message translates to:
  /// **'Summarize new uploads'**
  String get summarizeNewUploads;

  /// No description provided for @summarizeNewUploadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default the AI toggle on when uploading'**
  String get summarizeNewUploadsSubtitle;

  /// No description provided for @summariesCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Summaries created'**
  String get summariesCreatedTitle;

  /// No description provided for @summariesCreatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Across your whole library'**
  String get summariesCreatedSubtitle;

  /// No description provided for @storageSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageSectionLabel;

  /// No description provided for @filesFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Files folder'**
  String get filesFolderTitle;

  /// No description provided for @movingFiles.
  ///
  /// In en, this message translates to:
  /// **'Moving files…'**
  String get movingFiles;

  /// No description provided for @couldNotReadFolder.
  ///
  /// In en, this message translates to:
  /// **'Could not read current folder'**
  String get couldNotReadFolder;

  /// No description provided for @changeEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Change…'**
  String get changeEllipsis;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @chooseFolderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder to store Sift files in'**
  String get chooseFolderDialogTitle;

  /// No description provided for @filesMovedBackTo.
  ///
  /// In en, this message translates to:
  /// **'Files moved back to {path}'**
  String filesMovedBackTo(String path);

  /// No description provided for @librarySectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get librarySectionLabel;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add or remove categories'**
  String get categoriesSubtitle;

  /// No description provided for @defaultSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Default sort'**
  String get defaultSortTitle;

  /// No description provided for @securitySectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySectionLabel;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLockTitle;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require a PIN or biometric to open Sift'**
  String get appLockSubtitle;

  /// No description provided for @changePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinTitle;

  /// No description provided for @allCaughtUpTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUpTitle;

  /// No description provided for @allCaughtUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing expires in the next {days} days. Add an expiration date to a document and it\'ll show up here.'**
  String allCaughtUpMessage(num days);

  /// No description provided for @bucketOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get bucketOverdue;

  /// No description provided for @bucketThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get bucketThisWeek;

  /// No description provided for @bucketThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get bucketThisMonth;

  /// No description provided for @bucketComingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get bucketComingUp;

  /// No description provided for @renew.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renew;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @newExpirationDateHelp.
  ///
  /// In en, this message translates to:
  /// **'New expiration date'**
  String get newExpirationDateHelp;

  /// No description provided for @renewedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Renewed \"{name}\"'**
  String renewedSnackbar(String name);

  /// No description provided for @expiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get expiresToday;

  /// No description provided for @expiresTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Expires tomorrow'**
  String get expiresTomorrow;

  /// No description provided for @expiredYesterday.
  ///
  /// In en, this message translates to:
  /// **'Expired yesterday'**
  String get expiredYesterday;

  /// No description provided for @expiredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Expired {count} day ago} other{Expired {count} days ago}}'**
  String expiredDaysAgo(num count);

  /// No description provided for @expiredMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Expired {count} month ago} other{Expired {count} months ago}}'**
  String expiredMonthsAgo(num count);

  /// No description provided for @expiresInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Expires in {count} day} other{Expires in {count} days}}'**
  String expiresInDays(num count);

  /// No description provided for @expiresInWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Expires in {count} week} other{Expires in {count} weeks}}'**
  String expiresInWeeks(num count);

  /// No description provided for @expiresInMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Expires in {count} month} other{Expires in {count} months}}'**
  String expiresInMonths(num count);

  /// No description provided for @financeCategory.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get financeCategory;

  /// No description provided for @healthCategory.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthCategory;

  /// No description provided for @housingCategory.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get housingCategory;

  /// No description provided for @personalCategory.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalCategory;

  /// No description provided for @travelCategory.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travelCategory;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" expires {date}'**
  String reminderNotificationBody(String name, String date);

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Expiration reminders'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders for documents you set an expiration date on'**
  String get reminderChannelDescription;

  /// No description provided for @expiringBadge.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get expiringBadge;

  /// No description provided for @disabledForNowSuffix.
  ///
  /// In en, this message translates to:
  /// **'{subtitle} · disabled for now'**
  String disabledForNowSuffix(String subtitle);

  /// No description provided for @backupSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupSectionLabel;

  /// No description provided for @backupIntro.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this device. Back up to a file you control, and restore it any time — even on a different phone.'**
  String get backupIntro;

  /// No description provided for @backUpNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backUpNowTitle;

  /// No description provided for @backUpNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save all documents and categories to a single file'**
  String get backUpNowSubtitle;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup…'**
  String get restoreTitle;

  /// No description provided for @restoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace everything with a previous backup'**
  String get restoreSubtitle;

  /// No description provided for @saveBackupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Sift backup'**
  String get saveBackupDialogTitle;

  /// No description provided for @backupSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSavedSnackbar;

  /// No description provided for @backupFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create backup: {error}'**
  String backupFailedSnackbar(String error);

  /// No description provided for @chooseBackupFileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Sift backup file'**
  String get chooseBackupFileDialogTitle;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces every document and category currently in Sift with what\'s in this backup file. This can\'t be undone.'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreConfirmButton;

  /// No description provided for @restoreCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore complete'**
  String get restoreCompleteTitle;

  /// No description provided for @restoreCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Close and reopen Sift to see your restored documents.'**
  String get restoreCompleteMessage;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @restoreFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore backup: {error}'**
  String restoreFailedSnackbar(String error);

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like a Sift backup file.'**
  String get invalidBackupFile;

  /// No description provided for @backupTooNew.
  ///
  /// In en, this message translates to:
  /// **'This backup was made with a newer version of Sift and can\'t be restored here.'**
  String get backupTooNew;

  /// No description provided for @aboutSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSectionLabel;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @cameraPrimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan with your camera'**
  String get cameraPrimerTitle;

  /// No description provided for @cameraPrimerMessage.
  ///
  /// In en, this message translates to:
  /// **'Sift needs camera access to turn paper documents into a PDF. Photos are processed entirely on this device and are never uploaded anywhere.'**
  String get cameraPrimerMessage;

  /// No description provided for @biometricPrimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric unlock?'**
  String get biometricPrimerTitle;

  /// No description provided for @biometricPrimerMessage.
  ///
  /// In en, this message translates to:
  /// **'Sift can also use your device\'s fingerprint or face unlock for faster access, instead of typing your PIN every time. You can turn this off again in Settings.'**
  String get biometricPrimerMessage;

  /// No description provided for @notificationsPrimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind you before documents expire?'**
  String get notificationsPrimerTitle;

  /// No description provided for @notificationsPrimerMessage.
  ///
  /// In en, this message translates to:
  /// **'Sift can send a local reminder a few weeks before a document like a passport or policy expires. These reminders are scheduled entirely on this device — no server involved.'**
  String get notificationsPrimerMessage;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Tidy files, happy mind'**
  String get splashTagline;

  /// No description provided for @onboardingStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything in one place'**
  String get onboardingStoreTitle;

  /// No description provided for @onboardingStoreBody.
  ///
  /// In en, this message translates to:
  /// **'Upload files or scan paper documents with your camera — everything lands safely in your library, stored right on this device.'**
  String get onboardingStoreBody;

  /// No description provided for @onboardingOrganizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your way'**
  String get onboardingOrganizeTitle;

  /// No description provided for @onboardingOrganizeBody.
  ///
  /// In en, this message translates to:
  /// **'Sort documents into categories you create — Finance, Health, Travel, whatever makes sense to you.'**
  String get onboardingOrganizeBody;

  /// No description provided for @onboardingFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find it in a snap'**
  String get onboardingFindTitle;

  /// No description provided for @onboardingFindBody.
  ///
  /// In en, this message translates to:
  /// **'Search by name, filter by category, and get reminded before anything important expires.'**
  String get onboardingFindBody;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;
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
      <String>['de', 'en', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
