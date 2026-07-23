import '../../data/models/document.dart';

/// Urgency buckets for the "Coming up" view, most-urgent first. Display
/// labels live in `coming_up_screen.dart` (needs a `BuildContext` for
/// localization) — this file stays pure Dart so it's cheaply unit-testable.
enum ExpiryBucket { overdue, thisWeek, thisMonth, comingUp }

/// How far out the view looks — documents expiring beyond this aren't
/// "coming up" yet, so they don't clutter it. Overdue documents always show
/// regardless of how long ago they lapsed.
const comingUpHorizonDays = 90;

/// Classifies a document into an [ExpiryBucket], or null if it shouldn't
/// appear in the Coming Up view (no expiry set, or expiring further out than
/// [comingUpHorizonDays]). Bucketing is by calendar day, so "today" counts
/// as this-week rather than overdue.
ExpiryBucket? bucketFor(Document doc, DateTime now) {
  final expires = doc.expiresAt;
  if (expires == null) return null;

  final today = DateTime(now.year, now.month, now.day);
  final expiryDay = DateTime(expires.year, expires.month, expires.day);
  final daysUntil = expiryDay.difference(today).inDays;

  if (daysUntil < 0) return ExpiryBucket.overdue;
  if (daysUntil <= 7) return ExpiryBucket.thisWeek;
  if (daysUntil <= 30) return ExpiryBucket.thisMonth;
  if (daysUntil <= comingUpHorizonDays) return ExpiryBucket.comingUp;
  return null;
}

/// A document plus its computed bucket, sorted soonest-expiry-first.
class ComingUpEntry {
  const ComingUpEntry(this.document, this.bucket);
  final Document document;
  final ExpiryBucket bucket;
}

/// Builds the ordered, bucketed list backing the Coming Up view: only
/// documents within the horizon (or overdue), soonest expiry first.
List<ComingUpEntry> comingUpEntries(List<Document> docs, DateTime now) {
  final entries = <ComingUpEntry>[];
  for (final doc in docs) {
    final bucket = bucketFor(doc, now);
    if (bucket != null) entries.add(ComingUpEntry(doc, bucket));
  }
  entries.sort((a, b) => a.document.expiresAt!.compareTo(b.document.expiresAt!));
  return entries;
}

/// Per-bucket counts for the header summary line (e.g. "1 overdue · 2 this
/// month"), in urgency order, omitting empty buckets. Text formatting (the
/// localized bucket words) happens in the widget layer.
List<MapEntry<ExpiryBucket, int>> comingUpCounts(List<ComingUpEntry> entries) {
  final counts = <ExpiryBucket, int>{};
  for (final e in entries) {
    counts[e.bucket] = (counts[e.bucket] ?? 0) + 1;
  }
  return [
    for (final bucket in ExpiryBucket.values)
      if (counts[bucket] case final n?) MapEntry(bucket, n),
  ];
}

/// The shape of a relative-expiry phrase ("Expires in 4 days", "Expired 5
/// days ago") without the actual words — [amount] is only meaningful for the
/// count-bearing kinds. Formatting to localized text happens in the widget
/// layer, where an `AppLocalizations` instance (and its ICU plural rules)
/// is available.
enum ExpiryPhraseKind { today, tomorrow, yesterday, daysAgo, monthsAgo, inDays, inWeeks, inMonths }

class ExpiryPhrase {
  const ExpiryPhrase(this.kind, [this.amount = 0]);
  final ExpiryPhraseKind kind;
  final int amount;
}

/// Classifies when a document expires, relative to [now], into a structured
/// phrase — the visceral countdown the view leans on. Whole-calendar-day
/// based.
ExpiryPhrase relativeExpiry(Document doc, DateTime now) {
  final expires = doc.expiresAt;
  if (expires == null) return const ExpiryPhrase(ExpiryPhraseKind.today);
  final today = DateTime(now.year, now.month, now.day);
  final expiryDay = DateTime(expires.year, expires.month, expires.day);
  final days = expiryDay.difference(today).inDays;

  if (days == 0) return const ExpiryPhrase(ExpiryPhraseKind.today);
  if (days == 1) return const ExpiryPhrase(ExpiryPhraseKind.tomorrow);
  if (days == -1) return const ExpiryPhrase(ExpiryPhraseKind.yesterday);
  if (days < 0) {
    final ago = -days;
    if (ago < 30) return ExpiryPhrase(ExpiryPhraseKind.daysAgo, ago);
    return ExpiryPhrase(ExpiryPhraseKind.monthsAgo, (ago / 30).round());
  }
  if (days < 14) return ExpiryPhrase(ExpiryPhraseKind.inDays, days);
  if (days < 60) return ExpiryPhrase(ExpiryPhraseKind.inWeeks, (days / 7).round());
  return ExpiryPhrase(ExpiryPhraseKind.inMonths, (days / 30).round());
}
