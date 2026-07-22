import 'package:dio/dio.dart';

import '../../data/models/ai_summary.dart';
import '../../data/models/document.dart';
import 'ai_summary_service.dart';

/// Real HTTP-shaped implementation, ready to point at a summarization
/// backend. Not registered anywhere by default — see `AppConfig.aiEnabled`
/// and `lib/providers/ai_providers.dart`. Written against a generic
/// `POST /summarize` contract; adjust the request/response shape to match
/// whichever API this ends up calling.
class StubHttpAiSummaryService implements AiSummaryService {
  StubHttpAiSummaryService({required this.baseUrl, required this.apiKey})
    : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final String baseUrl;
  final String apiKey;
  final Dio _dio;

  @override
  Future<AiSummary> summarize(Document document) async {
    final response = await _dio.post(
      '/summarize',
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      data: {
        'documentName': document.name,
        'documentType': document.type.label,
        'storageKey': document.storageKey,
      },
    );
    final data = response.data as Map<String, Object?>;
    return AiSummary(
      summary: data['summary'] as String,
      points: (data['points'] as List).cast<String>(),
      // Ready for whenever the real backend reads dates out of the
      // document (a passport/policy's stated expiry) and reports one back
      // — expected as an ISO-8601 string under this key. The document
      // detail sheet only ever offers to *apply* a suggestion the user
      // confirms; this never writes `Document.expiresAt` on its own.
      suggestedExpiresAt: data['suggestedExpiresAt'] == null
          ? null
          : DateTime.tryParse(data['suggestedExpiresAt'] as String),
    );
  }
}
