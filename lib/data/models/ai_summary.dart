/// Result of summarizing a document: a short paragraph plus key bullet points.
class AiSummary {
  const AiSummary({required this.summary, required this.points});

  final String summary;
  final List<String> points;

  Map<String, Object?> toJson() => {'summary': summary, 'points': points};

  static AiSummary fromJson(Map<String, Object?> json) => AiSummary(
    summary: json['summary'] as String,
    points: (json['points'] as List).cast<String>(),
  );
}
