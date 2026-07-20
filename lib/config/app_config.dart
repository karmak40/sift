/// Central feature-flag configuration for the app.
class AppConfig {
  const AppConfig._();

  /// Master switch for AI summaries. When false, no network calls are made
  /// and every AI-related affordance in the UI renders as disabled.
  ///
  /// Flip this to true (and register [StubHttpAiSummaryService] instead of
  /// [DisabledAiSummaryService] in `lib/providers/ai_providers.dart`) once a
  /// real summarization backend is ready.
  static const bool aiEnabled = false;
}
