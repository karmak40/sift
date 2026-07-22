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

  /// Generic-enough MIME type per type — good enough for handing a file to
  /// the OS share sheet, not meant to be authoritative for every possible
  /// sub-format (e.g. all `img` docs are shared as `image/jpeg` regardless
  /// of whether they're actually a PNG — a receiving app cares far more
  /// that it's "an image" than the exact codec).
  String get mimeType => switch (this) {
    DocType.pdf => 'application/pdf',
    DocType.doc => 'application/msword',
    DocType.img => 'image/jpeg',
    DocType.xls => 'application/vnd.ms-excel',
    DocType.ppt => 'application/vnd.ms-powerpoint',
    DocType.txt => 'text/plain',
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
    this.expiresAt,
    this.reminderDaysBefore,
  });

  final int id;
  final String name;
  final DocType type;
  final String categoryId;
  final int sizeBytes;
  final DateTime addedAt;
  final String storageKey;
  final AiSummary? ai;

  /// When this document expires/needs renewing (passport, insurance policy,
  /// warranty, ...) — set manually by the user, null means "not tracked".
  final DateTime? expiresAt;

  /// How many days before [expiresAt] to remind the user. Only meaningful
  /// when [expiresAt] is set; defaults to 30 whenever a caller sets an
  /// expiration date without specifying one.
  final int? reminderDaysBefore;

  bool get hasAi => ai != null;

  bool get hasExpiration => expiresAt != null;

  /// The actual date a reminder notification should fire on.
  ///
  /// Computed via calendar-component subtraction (`DateTime(y, m, d - n)`),
  /// not `Duration(days: n)` — subtracting a fixed-length Duration across a
  /// daylight-saving transition shifts the wall-clock hour (e.g. lands on
  /// 23:00 the day before instead of midnight), which is wrong for a
  /// calendar-date reminder like this.
  DateTime? get reminderDate {
    final expires = expiresAt;
    if (expires == null) return null;
    final days = reminderDaysBefore ?? 30;
    return DateTime(expires.year, expires.month, expires.day - days);
  }

  /// True once we're inside the reminder window (or past the expiration
  /// date entirely) — drives the "expiring soon" badge in the library.
  bool isExpiringSoon(DateTime now) {
    final reminder = reminderDate;
    if (reminder == null) return false;
    return !now.isBefore(reminder);
  }

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
    DateTime? expiresAt,
    bool clearExpiresAt = false,
    int? reminderDaysBefore,
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
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      reminderDaysBefore: clearExpiresAt ? null : (reminderDaysBefore ?? this.reminderDaysBefore),
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
