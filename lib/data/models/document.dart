import 'ai_summary.dart';

enum DocType {
  pdf,
  doc,
  img,
  xls,
  ppt,
  txt;

  String get label => switch (this) {
    DocType.pdf => 'PDF',
    DocType.doc => 'DOC',
    DocType.img => 'IMG',
    DocType.xls => 'XLS',
    DocType.ppt => 'PPT',
    DocType.txt => 'TXT',
  };

  static DocType fromLabel(String label) => DocType.values.firstWhere(
    (t) => t.label == label.toUpperCase(),
    orElse: () => DocType.txt,
  );

  static DocType fromExtension(String? extension) {
    switch ((extension ?? '').toLowerCase()) {
      case 'pdf':
        return DocType.pdf;
      case 'doc':
      case 'docx':
        return DocType.doc;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'heic':
        return DocType.img;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return DocType.xls;
      case 'ppt':
      case 'pptx':
        return DocType.ppt;
      default:
        return DocType.txt;
    }
  }
}

/// A single library document. [storageKey] is opaque to the UI: on
/// Android/iOS it is a relative path under the app's documents directory; on
/// web it is the id of a BLOB row holding the file bytes.
class Document {
  const Document({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.sizeBytes,
    required this.addedAt,
    required this.storageKey,
    this.ai,
  });

  final int id;
  final String name;
  final DocType type;
  final String categoryId;
  final int sizeBytes;
  final DateTime addedAt;
  final String storageKey;
  final AiSummary? ai;

  bool get hasAi => ai != null;

  Document copyWith({
    int? id,
    String? name,
    DocType? type,
    String? categoryId,
    int? sizeBytes,
    DateTime? addedAt,
    String? storageKey,
    AiSummary? ai,
    bool clearAi = false,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      addedAt: addedAt ?? this.addedAt,
      storageKey: storageKey ?? this.storageKey,
      ai: clearAi ? null : (ai ?? this.ai),
    );
  }

  String get sizeLabel {
    if (sizeBytes <= 0) return '—';
    const kb = 1024;
    const mb = kb * 1024;
    if (sizeBytes >= mb) return '${(sizeBytes / mb).toStringAsFixed(1)} MB';
    return '${(sizeBytes / kb).toStringAsFixed(0)} KB';
  }
}
