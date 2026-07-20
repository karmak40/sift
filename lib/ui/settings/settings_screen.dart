import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/data_providers.dart';
import '../../providers/library_controller.dart';
import '../theme.dart';
import '../widgets/ai_toggle_row.dart';
import '../widgets/section_label.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final uiState = ref.watch(libraryControllerProvider);
    final docs = docsAsync.valueOrNull ?? const [];
    final cats = catsAsync.valueOrNull ?? const [];
    final aiCount = docs.where((d) => d.hasAi).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        const SectionLabel('AI'),
        AiToggleRow(
          title: 'Summarize new uploads',
          subtitle: 'Default the AI toggle on when uploading',
          value: uiState.aiDefaultOn,
          onChanged: aiFeaturesEnabled
              ? (_) => ref.read(libraryControllerProvider.notifier).toggleAiDefault()
              : null,
        ),
        const SizedBox(height: 10),
        _SettingsCard(
          children: [
            _SettingsRow(
              title: 'Summaries created',
              subtitle: 'Across your whole library',
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
        const SectionLabel('Storage'),
        _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Local device storage',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${docs.length} files',
                        style: monoStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (docs.length / 100).clamp(0.03, 1.0),
                      minHeight: 8,
                      backgroundColor: SiftColors.border,
                      color: SiftColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const SectionLabel('Library'),
        _SettingsCard(
          children: [
            _SettingsRow(
              title: 'Categories',
              trailing: Text('${cats.length}', style: monoStyle(fontSize: 13, color: SiftColors.textSecondary)),
            ),
            const Divider(height: 1),
            _SettingsRow(
              title: 'Default sort',
              trailing: Text(
                uiState.sortOrder.label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SiftColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const SectionLabel('Account'),
        _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: SiftColors.accentSoft,
                    child: Text('A', style: TextStyle(color: SiftColors.accentDark, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex Rivera', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('alex@example.com', style: TextStyle(fontSize: 12, color: SiftColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('Sign out', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: SiftColors.danger)),
                ],
              ),
            ),
          ],
        ),
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
  const _SettingsRow({required this.title, this.subtitle, required this.trailing});
  final String title;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        ],
      ),
    );
  }
}
