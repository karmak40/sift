import '../../data/models/ai_summary.dart';
import '../../data/models/document.dart';

/// Thrown by [DisabledAiSummaryService] when a caller tries to summarize
/// while AI is turned off. The UI should avoid triggering this by only
/// showing "Summarize" affordances when `AppConfig.aiEnabled` is true, but
/// the service enforces it too so there's no way to sneak a live call in.
class AiDisabledException implements Exception {
  const AiDisabledException();

  @override
  String toString() =>
      'AI summaries are disabled. Enable AppConfig.aiEnabled to use them.';
}

/// Abstraction over "read a document and produce a summary". Swap the
/// registered implementation in `lib/providers/ai_providers.dart` to turn
/// real AI summarization on.
abstract class AiSummaryService {
  Future<AiSummary> summarize(Document document);
}
