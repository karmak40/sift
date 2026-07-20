import '../../data/models/ai_summary.dart';
import '../../data/models/document.dart';
import 'ai_summary_service.dart';

/// Default AI service: makes no network calls, always refuses. This is what
/// the app ships with while `AppConfig.aiEnabled` is false.
class DisabledAiSummaryService implements AiSummaryService {
  const DisabledAiSummaryService();

  @override
  Future<AiSummary> summarize(Document document) {
    throw const AiDisabledException();
  }
}
