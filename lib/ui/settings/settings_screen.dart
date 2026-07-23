import 'dart:io' show File, Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_lock_providers.dart';
import '../../providers/app_locale_controller.dart';
import '../../providers/core_providers.dart';
import '../../providers/data_providers.dart';
import '../../providers/library_controller.dart';
import '../../providers/storage_location_controller.dart';
import '../../services/backup/backup_service.dart';
import '../category/manage_categories_sheet.dart';
import '../library/library_screen.dart';
import '../lock/pin_setup_sheet.dart';
import '../theme.dart';
import '../widgets/ai_toggle_row.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/section_label.dart';

/// Endonyms — each language's own name for itself — deliberately not run
/// through AppLocalizations: a Russian speaker picking "Deutsch" from the
/// list should see "Deutsch" regardless of Sift's current display language.
/// Not `const`: `Locale` overrides `==`/`hashCode`, which Dart doesn't allow
/// as a compile-time-constant map key.
final _languageNames = {
  Locale('en'): 'English',
  Locale('ru'): 'Русский',
  Locale('uk'): 'Українська',
  Locale('de'): 'Deutsch',
};

/// Choosing where files live on disk only makes sense on a real desktop
/// filesystem — Android/iOS are sandboxed, and Web has no filesystem at all
/// (see `WebFileStorageService`). Gated to Windows specifically per how this
/// was asked for; drop `Platform.isWindows` for other desktop targets later
/// if needed.
bool get _canChangeStorageLocation => !kIsWeb && Platform.isWindows;

/// Backup/restore needs a real filesystem to read/write a zip file to
/// (`BackupService` is built on `IoFileStorageService`) — unsupported on Web,
/// where uploaded files live as database BLOBs instead. See
/// `services/backup/backup_service.dart`.
bool get _canUseBackup => !kIsWeb;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final docsAsync = ref.watch(documentsProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final uiState = ref.watch(libraryControllerProvider);
    final docs = docsAsync.valueOrNull ?? const [];
    final cats = catsAsync.valueOrNull ?? const [];
    final aiCount = docs.where((d) => d.hasAi).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        Text(
          l10n.settingsTitle,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        SectionLabel(l10n.generalSectionLabel),
        const _SettingsCard(children: [_LanguageRow()]),
        const SizedBox(height: 22),
        SectionLabel(l10n.aiSectionLabel),
        AiToggleRow(
          title: l10n.summarizeNewUploads,
          subtitle: l10n.summarizeNewUploadsSubtitle,
          value: uiState.aiDefaultOn,
          onChanged: aiFeaturesEnabled
              ? (_) => ref.read(libraryControllerProvider.notifier).toggleAiDefault()
              : null,
        ),
        const SizedBox(height: 10),
        _SettingsCard(
          children: [
            _SettingsRow(
              title: l10n.summariesCreatedTitle,
              subtitle: l10n.summariesCreatedSubtitle,
              trailing: Text(
                '$aiCount / ${docs.length}',
                style: TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: SiftColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (_canChangeStorageLocation) ...[
          SectionLabel(l10n.storageSectionLabel),
          const _SettingsCard(children: [_StorageLocationRow()]),
          const SizedBox(height: 22),
        ],
        SectionLabel(l10n.librarySectionLabel),
        _SettingsCard(
          children: [
            _SettingsRow(
              title: l10n.categoriesTitle,
              subtitle: l10n.categoriesSubtitle,
              trailing: Text('${cats.length}', style: monoStyle(fontSize: 13, color: SiftColors.textSecondary)),
              onTap: () => showManageCategoriesSheet(context),
            ),
            const Divider(height: 1),
            _SettingsRow(
              title: l10n.defaultSortTitle,
              trailing: Text(
                sortOrderLabel(l10n, uiState.sortOrder),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SiftColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionLabel(l10n.securitySectionLabel),
        const _SecuritySettings(),
        if (_canUseBackup) ...[
          const SizedBox(height: 22),
          SectionLabel(l10n.backupSectionLabel),
          const _BackupSettings(),
        ],
      ],
    );
  }
}

class _LanguageRow extends ConsumerWidget {
  const _LanguageRow();

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final current = ref.read(appLocaleControllerProvider).valueOrNull;
    // `null` from showModalBottomSheet means "dismissed without choosing"
    // (do nothing); an explicit "System default" tap pops [_systemDefault]
    // instead, so it can be told apart from a dismiss.
    final choice = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePickerSheet(current: current),
    );
    if (choice == null) return;
    await ref.read(appLocaleControllerProvider.notifier).setLocale(choice == _systemDefault ? null : choice);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(appLocaleControllerProvider).valueOrNull;
    return _SettingsRow(
      title: l10n.languageTitle,
      trailing: Text(
        current == null ? l10n.languageSystemDefault : (_languageNames[current] ?? current.languageCode),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SiftColors.accent),
      ),
      onTap: () => _pickLanguage(context, ref),
    );
  }
}

/// Sentinel popped by the "System default" list tile — lets the caller tell
/// an explicit "follow the OS locale" choice apart from the sheet simply
/// being dismissed (which pops a real `null`).
const _systemDefault = Locale('_system_default');

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.current});
  final Locale? current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFCFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: SiftColors.border, borderRadius: BorderRadius.circular(3)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.languageTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            ListTile(
              title: Text(l10n.languageSystemDefault, style: const TextStyle(fontSize: 13.5)),
              trailing: current == null ? Icon(Icons.check, color: SiftColors.accent) : null,
              onTap: () => Navigator.of(context).pop(_systemDefault),
            ),
            for (final locale in supportedAppLocales)
              ListTile(
                title: Text(_languageNames[locale] ?? locale.languageCode, style: const TextStyle(fontSize: 13.5)),
                trailing: current == locale ? Icon(Icons.check, color: SiftColors.accent) : null,
                onTap: () => Navigator.of(context).pop(locale),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StorageLocationRow extends ConsumerWidget {
  const _StorageLocationRow();

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l10n.chooseFolderDialogTitle,
    );
    if (picked == null) return;
    await ref.read(storageLocationControllerProvider.notifier).changePath(picked);
  }

  Future<void> _resetToDefault(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(storageLocationControllerProvider.notifier);
    final defaultPath = await controller.defaultPath();
    await controller.changePath(null);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.filesMovedBackTo(defaultPath))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pathAsync = ref.watch(storageLocationControllerProvider);
    final busy = pathAsync.isLoading;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.filesFolderTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  pathAsync.when(
                    data: (path) => path,
                    loading: () => l10n.movingFiles,
                    error: (e, _) => l10n.couldNotReadFolder,
                  ),
                  style: monoStyle(fontSize: 11, color: SiftColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _choose(context, ref),
                  child: Text(l10n.changeEllipsis),
                ),
                TextButton(
                  onPressed: () => _resetToDefault(context, ref),
                  child: Text(l10n.reset, style: TextStyle(color: SiftColors.textMuted)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SecuritySettings extends ConsumerWidget {
  const _SecuritySettings();

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final didSetPin = await showPinSetupSheet(context);
    if (didSetPin) ref.invalidate(appLockEnabledProvider);
  }

  Future<void> _disable(WidgetRef ref) async {
    await ref.read(appLockServiceProvider).disable();
    ref.invalidate(appLockEnabledProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref.watch(appLockEnabledProvider).valueOrNull ?? false;

    return _SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.appLockTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      l10n.appLockSubtitle,
                      style: TextStyle(fontSize: 12, color: SiftColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                activeTrackColor: SiftColors.accent,
                onChanged: (turnOn) => turnOn ? _enable(context, ref) : _disable(ref),
              ),
            ],
          ),
        ),
        if (enabled) ...[
          const Divider(height: 1),
          _SettingsRow(
            title: l10n.changePinTitle,
            trailing: const SizedBox.shrink(),
            onTap: () => showPinSetupSheet(context),
          ),
        ],
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SiftColors.surface,
        border: Border.all(color: SiftColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.title, this.subtitle, required this.trailing, this.onTap});
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: SiftColors.textSecondary)),
                ],
              ],
            ),
          ),
          trailing,
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: SiftColors.textMuted),
          ],
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// Everything stored locally (categories, documents, expiration dates, AI
/// summaries, and the actual uploaded files) round-tripped through a single
/// zip file the user controls — see `services/backup/backup_service.dart`.
/// No network involved either direction.
class _BackupSettings extends ConsumerStatefulWidget {
  const _BackupSettings();

  @override
  ConsumerState<_BackupSettings> createState() => _BackupSettingsState();
}

class _BackupSettingsState extends ConsumerState<_BackupSettings> {
  bool _busy = false;

  String _backupFileName() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'sift-backup-${now.year}-${two(now.month)}-${two(now.day)}.zip';
  }

  Future<void> _backUpNow() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final bytes = await ref.read(backupServiceProvider).createBackupArchive();
      final fileName = _backupFileName();
      if (!mounted) return;

      if (Platform.isWindows) {
        // Desktop: no OS share sheet worth relying on — let the user pick
        // exactly where the file goes.
        final path = await FilePicker.platform.saveFile(
          dialogTitle: l10n.saveBackupDialogTitle,
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['zip'],
        );
        if (path == null || !mounted) return; // user cancelled
        await File(path).writeAsBytes(bytes, flush: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.backupSavedSnackbar)));
        }
      } else {
        // Android/iOS: hand the file to the OS share sheet so the user can
        // save it to Files/Drive, email it to themselves, etc. — same
        // pattern as sharing a document from the detail view.
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(bytes, name: fileName, mimeType: 'application/zip')],
            fileNameOverrides: [fileName],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.backupFailedSnackbar('$e'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: l10n.chooseBackupFileDialogTitle,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty || !mounted) return;
    final bytes = picked.files.first.bytes;
    if (bytes == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: l10n.restoreConfirmTitle,
      message: l10n.restoreConfirmMessage,
      confirmLabel: l10n.restoreConfirmButton,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(backupServiceProvider).restoreFromArchive(bytes);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          // Restoring closed the live database connection out from under
          // every provider that was watching it — the only safe way
          // forward is a real restart, not popping back into this session.
          canPop: false,
          child: AlertDialog(
            title: Text(l10n.restoreCompleteTitle),
            content: Text(l10n.restoreCompleteMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.gotIt),
              ),
            ],
          ),
        ),
      );
    } on BackupFormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.restoreFailedSnackbar('$e'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final busyIndicator = const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    return _SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
          child: Text(
            l10n.backupIntro,
            style: TextStyle(fontSize: 12, color: SiftColors.textSecondary, height: 1.4),
          ),
        ),
        const Divider(height: 1),
        _SettingsRow(
          title: l10n.backUpNowTitle,
          subtitle: l10n.backUpNowSubtitle,
          trailing: _busy ? busyIndicator : const SizedBox.shrink(),
          onTap: _busy ? null : _backUpNow,
        ),
        const Divider(height: 1),
        _SettingsRow(
          title: l10n.restoreTitle,
          subtitle: l10n.restoreSubtitle,
          trailing: _busy ? busyIndicator : const SizedBox.shrink(),
          onTap: _busy ? null : _restore,
        ),
      ],
    );
  }
}
