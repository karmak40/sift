import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/data_providers.dart';
import '../../providers/document_actions.dart';
import '../document_detail/document_detail_sheet.dart';
import '../theme.dart';
import '../widgets/category_dot.dart';
import '../widgets/doc_icon_tile.dart';
import '../widgets/permission_primer.dart';
import 'coming_up_model.dart';

String _bucketLabel(AppLocalizations l10n, ExpiryBucket bucket) =>
    switch (bucket) {
      ExpiryBucket.overdue => l10n.bucketOverdue,
      ExpiryBucket.thisWeek => l10n.bucketThisWeek,
      ExpiryBucket.thisMonth => l10n.bucketThisMonth,
      ExpiryBucket.comingUp => l10n.bucketComingUp,
    };

String _formatExpiryPhrase(AppLocalizations l10n, ExpiryPhrase phrase) =>
    switch (phrase.kind) {
      ExpiryPhraseKind.today => l10n.expiresToday,
      ExpiryPhraseKind.tomorrow => l10n.expiresTomorrow,
      ExpiryPhraseKind.yesterday => l10n.expiredYesterday,
      ExpiryPhraseKind.daysAgo => l10n.expiredDaysAgo(phrase.amount),
      ExpiryPhraseKind.monthsAgo => l10n.expiredMonthsAgo(phrase.amount),
      ExpiryPhraseKind.inDays => l10n.expiresInDays(phrase.amount),
      ExpiryPhraseKind.inWeeks => l10n.expiresInWeeks(phrase.amount),
      ExpiryPhraseKind.inMonths => l10n.expiresInMonths(phrase.amount),
    };

String? _summaryText(
  AppLocalizations l10n,
  List<MapEntry<ExpiryBucket, int>> counts,
) {
  if (counts.isEmpty) return null;
  return counts
      .map((e) => '${e.value} ${_bucketLabel(l10n, e.key).toLowerCase()}')
      .join(' · ');
}

/// The "Coming up" tab: documents that are expiring soon or overdue,
/// triaged into urgency buckets with relative countdowns and a one-tap
/// "Renew" that resets the clock. Designed to be a to-do list you clear,
/// not a passive report.
class ComingUpScreen extends ConsumerWidget {
  const ComingUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final docsAsync = ref.watch(documentsProvider);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final catById = {for (final c in categories) c.id: c};

    return docsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.failedToLoad('$e'))),
      data: (docs) {
        final now = DateTime.now();
        final entries = comingUpEntries(docs, now);
        if (entries.isEmpty) return const _AllCaughtUp();

        final summary = _summaryText(l10n, comingUpCounts(entries));
        // Group consecutively — entries are already sorted soonest-first, so
        // buckets come out in urgency order.
        final children = <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              summary ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ];
        ExpiryBucket? lastBucket;
        for (final entry in entries) {
          if (entry.bucket != lastBucket) {
            lastBucket = entry.bucket;
            children.add(_BucketHeader(bucket: entry.bucket));
          }
          children.add(
            _ComingUpRow(
              entry: entry,
              category: catById[entry.document.categoryId],
              now: now,
            ),
          );
        }
        children.add(const SizedBox(height: 90));

        return ListView(children: children);
      },
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hueColorAlpha(150, 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 32,
                color: hueColor(150, lightness: 0.42),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.allCaughtUpTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.allCaughtUpMessage(comingUpHorizonDays),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: SiftColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bucket colors: overdue is danger-red, this-week amber, the rest neutral —
/// urgency you can read at a glance from the color alone.
Color _bucketColor(ExpiryBucket bucket) => switch (bucket) {
  ExpiryBucket.overdue => SiftColors.danger,
  ExpiryBucket.thisWeek => SiftColors.warning,
  ExpiryBucket.thisMonth => SiftColors.textSecondary,
  ExpiryBucket.comingUp => SiftColors.textMuted,
};

class _BucketHeader extends StatelessWidget {
  const _BucketHeader({required this.bucket});
  final ExpiryBucket bucket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _bucketColor(bucket),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _bucketLabel(l10n, bucket).toUpperCase(),
            style: monoStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _bucketColor(bucket),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingUpRow extends ConsumerWidget {
  const _ComingUpRow({
    required this.entry,
    required this.category,
    required this.now,
  });

  final ComingUpEntry entry;
  final Category? category;
  final DateTime now;

  Future<void> _renew(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final doc = entry.document;
    final base = doc.expiresAt ?? now;
    // Renewals are usually annual (policies, passports run longer but a year
    // is the safe default the user can adjust) — prefill +1 year.
    final suggested = DateTime(base.year + 1, base.month, base.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: suggested,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 50),
      helpText: l10n.newExpirationDateHelp,
    );
    if (picked == null || !context.mounted) return;
    final primed = await ensurePermissionPrimed(
      context,
      prefsKey: notificationsPrimedKey,
      icon: Icons.notifications_none_rounded,
      title: l10n.notificationsPrimerTitle,
      message: l10n.notificationsPrimerMessage,
    );
    if (!primed || !context.mounted) return;
    await warnIfNotificationsPermanentlyDenied(context);
    if (!context.mounted) return;
    await setDocumentExpirationWithRef(ref, doc, expiresAt: picked);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.renewedSnackbar(doc.name))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final doc = entry.document;
    final color = _bucketColor(entry.bucket);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SiftColors.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            DocIconTile(type: doc.type, width: 34, height: 40),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        _formatExpiryPhrase(l10n, relativeExpiry(doc, now)),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      if (category != null) ...[
                        const SizedBox(width: 8),
                        CategoryDot(hue: category!.hue, size: 5),
                        const SizedBox(width: 4),
                        Text(
                          category!.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: SiftColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _renew(context, ref),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text(l10n.renew),
                ),
                InkWell(
                  onTap: () => showDocumentDetailSheet(
                    context,
                    document: doc,
                    category: category,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      l10n.details,
                      style: TextStyle(
                        fontSize: 12,
                        color: SiftColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
