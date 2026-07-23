// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navComingUp => 'Demnächst';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get newCategoryTooltip => 'Neue Kategorie';

  @override
  String get searchHint => 'Dokumente & Zusammenfassungen durchsuchen';

  @override
  String get allDocuments => 'Alle Dokumente';

  @override
  String fileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien',
      one: '$count Datei',
    );
    return '$_temp0';
  }

  @override
  String get sortTooltip => 'Sortieren';

  @override
  String get sortRecent => 'Neueste';

  @override
  String get sortNameAz => 'Name A–Z';

  @override
  String get sortLargest => 'Größte';

  @override
  String get categoryAll => 'Alle';

  @override
  String get emptyNoDocuments =>
      'Noch keine Dokumente. Tippe auf +, um dein erstes Dokument hochzuladen.';

  @override
  String get emptyNoMatch => 'Keine passenden Dokumente.';

  @override
  String get clearFilters => 'Filter zurücksetzen';

  @override
  String selectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '$count ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get moveToEllipsis => 'Verschieben nach…';

  @override
  String get delete => 'Löschen';

  @override
  String get clear => 'Entfernen';

  @override
  String deleteDocumentsConfirmTitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dokumente löschen?',
      one: '$count Dokument löschen?',
    );
    return '$_temp0';
  }

  @override
  String get deleteDocumentsConfirmMessage =>
      'Die ausgewählten Dateien werden entfernt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String failedToLoad(String error) {
    return 'Laden fehlgeschlagen: $error';
  }

  @override
  String get noFileAttached => 'Diesem Dokument ist keine Datei zugeordnet.';

  @override
  String get fileMissingFromDisk => 'Die Datei fehlt auf der Festplatte.';

  @override
  String get fileMissingFromDiskDetailed =>
      'Die Datei fehlt auf der Festplatte — sie wurde möglicherweise außerhalb der App verschoben oder gelöscht.';

  @override
  String get openNotSupportedWeb =>
      'Das Öffnen von Dateien wird in der Web-Vorschau noch nicht unterstützt — versuche es mit Android, iOS oder der Windows-App.';

  @override
  String deleteDocumentConfirmTitle(String name) {
    return '\"$name\" löschen?';
  }

  @override
  String get deleteDocumentConfirmMessage =>
      'Das Dokument und seine Datei werden entfernt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get renameDocumentTitle => 'Dokument umbenennen';

  @override
  String get deleteDocumentTooltip => 'Dokument löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get uncategorized => 'Ohne Kategorie';

  @override
  String sizeAddedOn(String size, String date) {
    return '$size · hinzugefügt am $date';
  }

  @override
  String documentPreviewLabel(String type) {
    return 'Dokumentvorschau · $type';
  }

  @override
  String expiresOn(String date) {
    return 'Läuft ab am $date';
  }

  @override
  String remindMeDaysBeforeChange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Erinnerung $count Tage vorher · ändern',
      one: 'Erinnerung $count Tag vorher · ändern',
    );
    return '$_temp0';
  }

  @override
  String get edit => 'Bearbeiten';

  @override
  String get notTrackingExpiration => 'Kein Ablaufdatum hinterlegt';

  @override
  String get setDate => 'Datum festlegen';

  @override
  String get remindBeforeExpiresTitle => 'Vor Ablauf erinnern';

  @override
  String daysBeforeOption(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage vorher',
      one: '$count Tag vorher',
    );
    return '$_temp0';
  }

  @override
  String get aiSummaryLabel => 'KI-ZUSAMMENFASSUNG';

  @override
  String readingAndExtracting(String type) {
    return '$type wird gelesen, wichtige Punkte werden extrahiert…';
  }

  @override
  String get keyPointsLabel => 'WICHTIGE PUNKTE';

  @override
  String get aiDisabledLong =>
      'KI-Zusammenfassungen sind derzeit deaktiviert. Aktiviere den KI-Dienst, damit er diese Datei liest und wichtige Punkte extrahiert.';

  @override
  String get aiNoSummaryYet =>
      'Noch keine Zusammenfassung. Aktiviere KI, um diese Datei zu lesen und die wichtigen Punkte zu extrahieren.';

  @override
  String get summarizeWithAi => 'Mit KI zusammenfassen';

  @override
  String get aiDisabledSnackbar =>
      'KI-Zusammenfassungen sind derzeit deaktiviert.';

  @override
  String get openFile => 'Datei öffnen';

  @override
  String get share => 'Teilen';

  @override
  String get chooseFiles => 'Dateien auswählen';

  @override
  String get chooseFilesSubtitle => 'Ein oder mehrere Dokumente auswählen';

  @override
  String get scanDocument => 'Dokument scannen';

  @override
  String get scanDocumentSubtitle => 'Seiten mit der Kamera als PDF erfassen';

  @override
  String scanFailed(String error) {
    return 'Dokument konnte nicht gescannt werden: $error';
  }

  @override
  String get scanFilePrefix => 'Scan';

  @override
  String get addDocumentTitle => 'Dokument hinzufügen';

  @override
  String get fileNameLabel => 'Dateiname';

  @override
  String get typeLabel => 'Typ';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get aiOptionalSubtitle => 'Optional — wichtige Punkte extrahieren';

  @override
  String addDocumentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dokumente hinzufügen',
      one: '$count Dokument hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String get batchSameCategoryNote =>
      'Sie werden alle derselben Kategorie zugeordnet, ihre Dateinamen bleiben erhalten.';

  @override
  String deleteCategoryConfirmTitle(String name) {
    return '\"$name\" löschen?';
  }

  @override
  String get deleteCategoryConfirmMessageEmpty =>
      'Diese Kategorie enthält keine Dokumente. Dies kann nicht rückgängig gemacht werden.';

  @override
  String deleteCategoryConfirmMessageWithDocs(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Dokumente in dieser Kategorie werden unkategorisiert, statt gelöscht zu werden. Dies kann nicht rückgängig gemacht werden.',
      one:
          '$count Dokument in dieser Kategorie wird unkategorisiert, statt gelöscht zu werden. Dies kann nicht rückgängig gemacht werden.',
    );
    return '$_temp0';
  }

  @override
  String get categoriesTitle => 'Kategorien';

  @override
  String get newCategoryButton => 'Neu';

  @override
  String get noCategoriesYet => 'Noch keine Kategorien.';

  @override
  String get deleteCategoryTooltip => 'Kategorie löschen';

  @override
  String get newCategoryTitle => 'Neue Kategorie';

  @override
  String get categoryNamePlaceholder => 'Kategoriename';

  @override
  String get nameLabel => 'Name';

  @override
  String get categoryNameHint => 'z. B. Garantien';

  @override
  String get colorLabel => 'Farbe';

  @override
  String get previewLabel => 'Vorschau';

  @override
  String get createCategoryButton => 'Kategorie erstellen';

  @override
  String moveToCount(num count) {
    return '$count verschieben nach…';
  }

  @override
  String get siftLocked => 'Sift ist gesperrt';

  @override
  String get enterPinToContinue => 'Gib deine PIN ein, um fortzufahren';

  @override
  String get incorrectPin => 'Falsche PIN';

  @override
  String get unlock => 'Entsperren';

  @override
  String get useBiometricUnlock => 'Mit Biometrie entsperren';

  @override
  String get biometricUnlockReason => 'Sift entsperren';

  @override
  String pinMinLength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Die PIN muss mindestens $count Ziffern haben',
      one: 'Die PIN muss mindestens $count Ziffer haben',
    );
    return '$_temp0';
  }

  @override
  String get confirmYourPin => 'Bestätige deine PIN';

  @override
  String get setAPin => 'PIN festlegen';

  @override
  String get enterItOneMoreTime => 'Gib sie noch einmal ein';

  @override
  String get youllUseThisToUnlock => 'Damit entsperrst du Sift';

  @override
  String get pinsDontMatch => 'Die PINs stimmen nicht überein';

  @override
  String get savePin => 'PIN speichern';

  @override
  String get continueButton => 'Weiter';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get generalSectionLabel => 'Allgemein';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get aiSectionLabel => 'KI';

  @override
  String get summarizeNewUploads => 'Neue Uploads zusammenfassen';

  @override
  String get summarizeNewUploadsSubtitle =>
      'KI-Umschalter beim Hochladen standardmäßig aktivieren';

  @override
  String get summariesCreatedTitle => 'Erstellte Zusammenfassungen';

  @override
  String get summariesCreatedSubtitle => 'In deiner gesamten Bibliothek';

  @override
  String get storageSectionLabel => 'Speicher';

  @override
  String get filesFolderTitle => 'Dateiordner';

  @override
  String get movingFiles => 'Dateien werden verschoben…';

  @override
  String get couldNotReadFolder =>
      'Aktueller Ordner konnte nicht gelesen werden';

  @override
  String get changeEllipsis => 'Ändern…';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get chooseFolderDialogTitle =>
      'Wähle einen Ordner zum Speichern der Sift-Dateien';

  @override
  String filesMovedBackTo(String path) {
    return 'Dateien wurden zurück nach $path verschoben';
  }

  @override
  String get librarySectionLabel => 'Bibliothek';

  @override
  String get categoriesSubtitle => 'Kategorien hinzufügen oder entfernen';

  @override
  String get defaultSortTitle => 'Standardsortierung';

  @override
  String get securitySectionLabel => 'Sicherheit';

  @override
  String get appLockTitle => 'App-Sperre';

  @override
  String get appLockSubtitle =>
      'PIN oder Biometrie zum Öffnen von Sift erforderlich';

  @override
  String get changePinTitle => 'PIN ändern';

  @override
  String get allCaughtUpTitle => 'Alles erledigt';

  @override
  String allCaughtUpMessage(num days) {
    return 'In den nächsten $days Tagen läuft nichts ab. Füge einem Dokument ein Ablaufdatum hinzu, damit es hier erscheint.';
  }

  @override
  String get bucketOverdue => 'Überfällig';

  @override
  String get bucketThisWeek => 'Diese Woche';

  @override
  String get bucketThisMonth => 'Diesen Monat';

  @override
  String get bucketComingUp => 'Demnächst';

  @override
  String get renew => 'Erneuern';

  @override
  String get details => 'Details';

  @override
  String get newExpirationDateHelp => 'Neues Ablaufdatum';

  @override
  String renewedSnackbar(String name) {
    return '\"$name\" erneuert';
  }

  @override
  String get expiresToday => 'Läuft heute ab';

  @override
  String get expiresTomorrow => 'Läuft morgen ab';

  @override
  String get expiredYesterday => 'Gestern abgelaufen';

  @override
  String expiredDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Tagen abgelaufen',
      one: 'Vor $count Tag abgelaufen',
    );
    return '$_temp0';
  }

  @override
  String expiredMonthsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Monaten abgelaufen',
      one: 'Vor $count Monat abgelaufen',
    );
    return '$_temp0';
  }

  @override
  String expiresInDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Läuft in $count Tagen ab',
      one: 'Läuft in $count Tag ab',
    );
    return '$_temp0';
  }

  @override
  String expiresInWeeks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Läuft in $count Wochen ab',
      one: 'Läuft in $count Woche ab',
    );
    return '$_temp0';
  }

  @override
  String expiresInMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Läuft in $count Monaten ab',
      one: 'Läuft in $count Monat ab',
    );
    return '$_temp0';
  }

  @override
  String get financeCategory => 'Finanzen';

  @override
  String get healthCategory => 'Gesundheit';

  @override
  String get housingCategory => 'Wohnen';

  @override
  String get personalCategory => 'Persönliches';

  @override
  String get travelCategory => 'Reisen';

  @override
  String get reminderNotificationTitle => 'Läuft bald ab';

  @override
  String reminderNotificationBody(String name, String date) {
    return '\"$name\" läuft am $date ab';
  }

  @override
  String get reminderChannelName => 'Ablauferinnerungen';

  @override
  String get reminderChannelDescription =>
      'Erinnerungen für Dokumente mit einem festgelegten Ablaufdatum';

  @override
  String get expiringBadge => 'Läuft ab';

  @override
  String disabledForNowSuffix(String subtitle) {
    return '$subtitle · derzeit deaktiviert';
  }

  @override
  String get backupSectionLabel => 'Sicherung';

  @override
  String get backupIntro =>
      'Alles bleibt auf diesem Gerät. Sichere es in einer Datei, die du selbst kontrollierst, und stelle sie jederzeit wieder her — auch auf einem anderen Telefon.';

  @override
  String get backUpNowTitle => 'Jetzt sichern';

  @override
  String get backUpNowSubtitle =>
      'Alle Dokumente und Kategorien in einer Datei speichern';

  @override
  String get restoreTitle => 'Aus Sicherung wiederherstellen…';

  @override
  String get restoreSubtitle => 'Alles durch eine frühere Sicherung ersetzen';

  @override
  String get saveBackupDialogTitle => 'Sift-Sicherung speichern';

  @override
  String get backupSavedSnackbar => 'Sicherung gespeichert';

  @override
  String backupFailedSnackbar(String error) {
    return 'Sicherung konnte nicht erstellt werden: $error';
  }

  @override
  String get chooseBackupFileDialogTitle => 'Sift-Sicherungsdatei auswählen';

  @override
  String get restoreConfirmTitle => 'Aus Sicherung wiederherstellen?';

  @override
  String get restoreConfirmMessage =>
      'Dadurch werden alle aktuell in Sift vorhandenen Dokumente und Kategorien durch den Inhalt dieser Sicherungsdatei ersetzt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get restoreConfirmButton => 'Wiederherstellen';

  @override
  String get restoreCompleteTitle => 'Wiederherstellung abgeschlossen';

  @override
  String get restoreCompleteMessage =>
      'Schließe Sift und öffne es erneut, um deine wiederhergestellten Dokumente zu sehen.';

  @override
  String get gotIt => 'Verstanden';

  @override
  String restoreFailedSnackbar(String error) {
    return 'Sicherung konnte nicht wiederhergestellt werden: $error';
  }

  @override
  String get invalidBackupFile =>
      'Das sieht nicht wie eine Sift-Sicherungsdatei aus.';

  @override
  String get backupTooNew =>
      'Diese Sicherung wurde mit einer neueren Version von Sift erstellt und kann hier nicht wiederhergestellt werden.';

  @override
  String get aboutSectionLabel => 'Über';

  @override
  String get versionTitle => 'Version';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';
}
