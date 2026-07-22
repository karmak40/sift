/// Result of summarizing a document: a short paragraph plus key bullet
/// points, and — once a real AI backend is wired up — an optional
/// suggested expiration date read out of the document's content (e.g. a
/// passport or policy's stated expiry).
///
/// [suggestedExpiresAt] is always null today: `DisabledAiSummaryService`
/// never returns an `AiSummary` at all (see `ai_summary_service.dart`), so
/// this field only exists so the UI plumbing (document detail sheet's "AI
/// suggests — apply?" affordance) and `StubHttpAiSummaryService`'s response
/// parsing are ready for it. The user always sets/confirms the actual
/// `Document.expiresAt` themselves — see `Document.expiresAt`.
class AiSummary {
  const AiSummary({required this.summary, required this.points, this.suggestedExpiresAt});

  final String summary;
  final List<String> points;
  final DateTime? suggestedExpiresAt;

  Map<String, Object?> toJson() => {
    'summary': summary,
    'points': points,
    if (suggestedExpiresAt != null) 'suggestedExpiresAt': suggestedExpiresAt!.toIso8601String(),
  };

  static AiSummary fromJson(Map<String, Object?> json) => AiSummary(
    summary: json['summary'] as String,
    points: (json['points'] as List).cast<String>(),
    suggestedExpiresAt: json['suggestedExpiresAt'] == null
        ? null
        : DateTime.parse(json['suggestedExpiresAt'] as String),
  );
}
