# Sift — Architecture

Sift is a personal document library app: upload files, sort them into
categories, search them, and (optionally, once turned on) get an AI-written
summary of what's in them. This document explains how the codebase is put
together so a new developer can find their way around and add features
without having to reverse-engineer the whole thing first.

Read this once, top to bottom — it's written in the order you'd want to
learn it in, not alphabetically by folder.

---

## 1. The big picture

There are four layers, and data flows through them in one direction:

```
┌─────────────┐     ┌──────────────┐     ┌───────────────┐     ┌──────────┐
│   Storage    │ --> │  Repository  │ --> │   Providers    │ --> │    UI    │
│ (SQLite DB,  │     │ (interfaces  │     │  (Riverpod —   │     │ (screens,│
│  files on    │     │  + Drift     │     │   streams +    │     │  sheets, │
│  disk/blob)  │     │  impl)       │     │   UI state)    │     │  widgets)│
└─────────────┘     └──────────────┘     └───────────────┘     └──────────┘
```

- **Storage**: an actual SQLite database (via the `drift` package) plus,
  for uploaded files, either real files on disk or blob rows in the DB.
- **Repository**: a small interface (`DocumentRepository`,
  `CategoryRepository`) that hides *how* data is stored. Today there's one
  implementation, backed by Drift. Nothing above this layer knows or cares
  that SQLite is involved.
- **Providers**: Riverpod providers that (a) expose repository data as
  streams the UI can watch, and (b) hold UI-only state like the current
  search text, sort order, and selection.
- **UI**: Flutter widgets. They only ever talk to providers — never
  directly to the database or file system.

The reason for the repository layer: the user wanted room to add a remote
(server-backed) storage option later without rewriting the app. Every
screen reads through `documentRepositoryProvider` / `categoryRepositoryProvider`,
so swapping the implementation behind those two providers is the entire
migration — see §5.

---

## 2. Folder-by-folder tour

```
lib/
  main.dart                    — app entry point
  config/
    app_config.dart            — feature flags (currently just AI on/off)
  data/
    models/                    — plain Dart classes: Document, Category, AiSummary
    local/database.dart        — Drift table + database definitions
    repository/                — DocumentRepository/CategoryRepository interfaces
                                  + their Drift implementations
    file_storage_service.dart  — interface for storing uploaded file bytes
    io_file_storage_service.dart   — real filesystem impl (Android/iOS/desktop)
    web_file_storage_service.dart  — DB-blob impl (Web, which has no filesystem)
    storage_location_service.dart  — persists the Windows "custom files folder" setting
    seed_data.dart              — creates default categories on first run
  services/ai/
    ai_summary_service.dart          — interface: summarize(document) -> AiSummary
    disabled_ai_summary_service.dart — default impl: always refuses (AI is off)
    stub_http_ai_summary_service.dart — real HTTP impl, written but not wired up
  providers/
    core_providers.dart        — wires up DB, repositories, file storage, AI service
    data_providers.dart        — streams of documents/categories for the UI
    library_controller.dart    — UI state: search/sort/filter/selection/tabs
    app_init_provider.dart     — runs seed_data.dart once at startup
    storage_location_controller.dart — current files-folder path + change/reset actions
    document_actions.dart      — deleteDocuments(): removes a document's DB row + its file together
  ui/
    home/home_shell.dart       — the app shell: top bar, search box, bottom nav
    library/library_screen.dart — the main document grid/list + category chips
    document_detail/           — the "tap a document" bottom sheet (open/delete live here)
    upload/                    — the "add a document" bottom sheet
    category/                  — the "new category" bottom sheet
    move/                      — the "move N documents to…" bottom sheet
    settings/settings_screen.dart
    widgets/                   — small shared pieces (category dot, doc icon, AI badge, confirm_dialog…)
    theme.dart                 — colors, fonts, the OKLCH-hue-to-Color helper
```

If you're looking for where something lives, this is usually enough to
find it. The rest of this document goes deeper on the parts that aren't
self-explanatory from file names alone.

---

## 3. Data model

Two things get stored: **categories** and **documents**.

```dart
class Category {
  String id;      // e.g. "finance", or a generated uuid for user-created ones
  String name;    // e.g. "Finance"
  double hue;     // 0-360, used to color the category's dot/chip/badge
}

class Document {
  int id;                 // auto-increment, assigned by the DB
  String name;             // "Tax Return 2025.pdf"
  DocType type;             // enum: pdf/doc/img/xls/ppt/txt
  String categoryId;        // which Category this belongs to
  int sizeBytes;
  DateTime addedAt;
  String storageKey;        // opaque key — see §4, FileStorageService
  AiSummary? ai;             // null until a summary has been generated
}
```

`AiSummary` is just `{ String summary; List<String> points; }`.

These model classes (`lib/data/models/`) are what the UI works with. They
are **not** the same classes Drift generates from the table definitions —
see the note on `CategoryRow`/`DocumentRow` in §6 if you're wondering why
there are two similarly-named classes.

---

## 4. How a file upload actually works

This is the part most likely to confuse a newcomer, because "where is the
file?" has two different answers depending on platform.

1. User picks a file in the upload sheet (`lib/ui/upload/upload_sheet.dart`)
   using the `file_picker` package — this works the same way on
   Android/iOS/Web and gives us the file's bytes directly.
2. Those bytes are handed to whichever `FileStorageService` is active:
   - **`IoFileStorageService`** (Android/iOS/desktop): writes the bytes to
     a real file under `<base dir>/sift_files/<uuid>.<ext>` and returns
     that filename as the `storageKey`. `<base dir>` is normally the app's
     documents directory, but see "Custom storage location" below.
   - **`WebFileStorageService`** (Web): there is no real filesystem in a
     browser sandbox, so it stores the bytes as a BLOB row in the same
     SQLite (via Drift's web backend) and returns the row's id as the
     `storageKey`.
3. The `storageKey` — just an opaque string — gets saved on the
   `Document` row. Nothing outside `FileStorageService` ever needs to know
   whether it's a filename or a database id.
4. Later, to read the file back, you'd call
   `fileStorageServiceProvider.read(document.storageKey)` and get the bytes
   back, again without caring which platform you're on.

**Why it matters for you:** if you add a feature that needs the actual
file content (e.g. real thumbnail previews, or wiring the AI service to
actually read the file), go through `FileStorageService`, not
`dart:io File` directly — that's the one piece of code that already knows
how to be platform-agnostic.

Which implementation gets used is decided in
`lib/providers/core_providers.dart`:

```dart
final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  if (kIsWeb) return WebFileStorageService(ref.watch(appDatabaseProvider));
  return ref.watch(ioFileStorageServiceProvider);
});
```

### Custom storage location (Windows)

Settings > Storage has a "Files folder" row, visible only on Windows
(`_canChangeStorageLocation` in `lib/ui/settings/settings_screen.dart`
checks `!kIsWeb && Platform.isWindows`) — Android/iOS are sandboxed and
picking an arbitrary folder there doesn't make sense, and Web has no
filesystem at all.

- The chosen folder is persisted as a plain string via `shared_preferences`
  (`lib/data/storage_location_service.dart`, `StorageLocationService`). No
  value stored means "use the default app-data folder".
- `IoFileStorageService` consults this on every `store()`/`read()`/
  `delete()` call (`_baseDir()`), so it's always using whatever the current
  setting says — no restart needed.
- Changing the folder goes through `IoFileStorageService.changeBaseDirectory()`,
  which **moves the existing `sift_files` folder contents to the new
  location** (falling back to copy+delete if the new folder is on a
  different drive, since `File.rename` can't cross volumes) before
  persisting the new setting. This is deliberate: `storageKey` is just a
  filename, not a full path, so if the move didn't happen, every
  previously-uploaded document would silently become unreadable the moment
  the folder changed. See `test/io_file_storage_service_test.dart` for the
  test coverage of this migration (including the "move back to default"
  path).
- `lib/providers/storage_location_controller.dart` exposes the current
  resolved path (and the change/reset actions) as an `AsyncNotifier` so the
  Settings row can show a spinner while a move is in progress.

If this needs to extend to other desktop targets later (macOS, Linux),
the only change needed is loosening the `Platform.isWindows` check — none
of the underlying storage/migration logic is Windows-specific.

### Opening a document

`FileStorageService.openExternally(storageKey)` hands the file to the OS's
default app for its type. On Android/iOS/desktop this resolves the real
path and calls the `open_filex` package — on Windows that's literally just
`cmd /c start "" <path>` under the hood, no native plugin involved. On Web
there's no real file to hand off to another app, so it just returns an
explanatory message instead of pretending to succeed. The document detail
sheet's "Open file" button calls this and shows the returned message (if
any) in a snackbar.

### Deleting a document

Deleting has to do two things — remove the DB row *and* remove the
underlying file/blob — and `DocumentRepository.delete()` only does the
first half. `lib/providers/document_actions.dart`'s `deleteDocuments()` is
the composed operation every delete UI action goes through instead:

```dart
Future<void> deleteDocuments({
  required List<Document> documents,
  required DocumentRepository documentRepository,
  required FileStorageService fileStorageService,
}) async {
  for (final doc in documents) {
    if (doc.storageKey.isNotEmpty) await fileStorageService.delete(doc.storageKey);
  }
  await documentRepository.delete(documents.map((d) => d.id).toList());
}
```

It's written to take the repository/service as parameters rather than
reading providers itself, specifically so it's unit-testable with a fake
`DocumentRepository` (see `test/document_actions_test.dart`) without
needing a real database. `deleteDocumentsWithRef(ref, documents)` is the
thin wrapper UI code actually calls. Both the document detail sheet (single
document, via a trash icon next to the close button) and the library
list view's bulk-selection bar (multiple documents, via "Delete" next to
"Move to…") go through a confirmation dialog first
(`lib/ui/widgets/confirm_dialog.dart`) before calling it.

---

## 5. The storage backend seam (local vs. remote)

`lib/providers/core_providers.dart` has a `StorageBackend` enum with two
values: `local` (implemented, default) and `remote` (not implemented yet,
throws `UnimplementedError` if selected).

```dart
enum StorageBackend { local, remote }

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  switch (ref.watch(storageBackendProvider)) {
    case StorageBackend.local:
      return DriftDocumentRepository(ref.watch(appDatabaseProvider));
    case StorageBackend.remote:
      throw UnimplementedError('Remote storage backend is not built yet.');
  }
});
```

**To add a remote backend later:** write a `RemoteDocumentRepository` and
`RemoteCategoryRepository` that implement the same two abstract classes
(`lib/data/repository/document_repository.dart` and
`category_repository.dart`), wire them into the `.remote` case above, and
flip `storageBackendProvider`. No screen, sheet, or widget needs to change,
because they only ever depend on the abstract `DocumentRepository`/
`CategoryRepository` interfaces, never on `DriftDocumentRepository`
directly.

---

## 6. The local database (Drift)

`lib/data/local/database.dart` defines three tables:

- `Categories` — id, name, hue
- `Documents` — id, name, type, categoryId, sizeBytes, addedAt, storageKey,
  aiSummaryJson (the `AiSummary` serialized to a JSON string, or null)
- `WebFiles` — id, bytes (only used by `WebFileStorageService` on Web)

Drift is a code-generator: it reads the `Table` classes above and
generates `database.g.dart` (a build artifact — never hand-edit it) with a
type-safe query API. If you change a table definition, you need to
regenerate that file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Why the row classes are named `CategoryRow`/`DocumentRow` and not
`Category`/`Document`:** by default Drift names the generated row class
after the singular of the table name, which would collide with our own
`Category`/`Document` model classes. The `@DataClassName('CategoryRow')`
annotation on each table renames Drift's generated class to avoid that
collision. `DriftCategoryRepository`/`DriftDocumentRepository` are the only
places that ever see a `CategoryRow`/`DocumentRow` — they convert to our
own `Category`/`Document` models before anything else sees them.

**Where the database file actually lives** is handled by the
`drift_flutter` package's `driftDatabase(name: 'sift_db', web: ...)` call,
also in `database.dart`. On Android/iOS it's a `.sqlite` file in the app's
documents directory; on Web it's IndexedDB (via a `sqlite3.wasm` module and
a `drift_worker.js` web worker — both prebuilt and checked into `web/`, see
the comment in that folder if you ever need to regenerate them after a
Drift version bump).

---

## 7. State management (Riverpod)

Three kinds of providers, and it's worth keeping them mentally separate:

1. **Infrastructure providers** (`core_providers.dart`) — the database, the
   repositories, the file storage service, the AI service. These are
   plain `Provider`s: created once, injected everywhere via `ref.watch(...)`.

2. **Data stream providers** (`data_providers.dart`) — `StreamProvider`s
   that wrap `repository.watchAll()`. Any screen that watches
   `documentsProvider` automatically rebuilds whenever a document is
   added/edited/moved, because Drift's `.watch()` streams re-emit on every
   write. There's no manual "refresh" anywhere in the UI — this is why.

3. **UI state** (`library_controller.dart`) — a `Notifier` holding things
   that are *not* persisted: current search text, sort order, grid/list
   toggle, which category chip is selected, which documents are checked
   for bulk-move, which bottom tab is active. This is intentionally kept
   separate from the persisted data — closing and reopening the app resets
   the search box, but never loses a document.

The `LibraryController.apply(docs)` method is where filtering/searching/
sorting actually happens — it's plain synchronous list logic (see
`test/widget_test.dart` for examples), not a provider itself. Screens call
`ref.read(libraryControllerProvider.notifier).apply(docs)` after watching
the raw `documentsProvider` list.

---

## 8. The AI feature (and why it's off)

The user asked for AI wiring to exist but be **disabled by default** — no
network calls, no API key needed to run the app. Here's how that's
structured:

- `AiSummaryService` (`lib/services/ai/ai_summary_service.dart`) is an
  abstract interface: `Future<AiSummary> summarize(Document doc)`.
- `DisabledAiSummaryService` is the only implementation actually wired up
  right now. It doesn't just "return an empty summary" — it throws
  `AiDisabledException`, so it's impossible to accidentally get a fake
  success response and think AI is working when it isn't.
- `StubHttpAiSummaryService` is a complete, ready-to-use HTTP client (via
  `dio`) written against a generic `POST /summarize` contract. It exists so
  that turning AI on later is a config change, not a coding project — but
  it is **not** referenced anywhere except as a comment in
  `core_providers.dart`.
- `AppConfig.aiEnabled` (`lib/config/app_config.dart`) is the single
  `bool` that controls everything: which service `aiSummaryServiceProvider`
  hands out, and whether the UI shows AI toggles as interactive or greyed
  out (`lib/ui/widgets/ai_toggle_row.dart` — the `aiFeaturesEnabled` getter
  is what every AI-related toggle in the app checks).

**To turn AI on for real:**
1. Point `StubHttpAiSummaryService` at a real backend (fill in `baseUrl`/
   `apiKey`, adjust the request/response shape to match whatever API you
   end up using).
2. In `core_providers.dart`, change `aiSummaryServiceProvider` to return
   `StubHttpAiSummaryService(...)` when `AppConfig.aiEnabled` is true.
3. Flip `AppConfig.aiEnabled` to `true`.

Every AI toggle, the "Summarize with AI" button, and the Settings AI
section will light up automatically — none of them have their own
separate on/off logic to update.

---

## 9. The UI layer

**Navigation** is a single bottom nav bar with three tabs (Library / AI /
Settings), tracked as UI state in `LibraryController` (`MobileTab` enum),
not Flutter's `Navigator`. `home_shell.dart` just swaps which widget is in
the `Scaffold.body` based on the current tab. The "AI" tab is literally the
same `LibraryScreen` widget as the main tab, just constructed with
`aiOnly: true`, which filters the list down to documents that already have
a summary.

**Modals** (document detail, upload, new category, move-to) are all
`showModalBottomSheet` calls, not separate routes/pages. Each sheet is a
small `ConsumerWidget`/`ConsumerStatefulWidget` in its own folder under
`lib/ui/`, and each exposes a single `showXSheet(context, ...)` function
that the caller uses — you never construct the sheet widget directly.

**Colors**: the design uses OKLCH color values (`oklch(0.55 0.15 250)`).
Flutter's `Color` has no native OKLCH support, so `lib/ui/theme.dart`
approximates each OKLCH hue with Flutter's `HSLColor` at a fixed
saturation/lightness — close enough visually, not a color-accurate
conversion. If pixel-perfect color matching ever matters, that's the
function (`hueColor` / `hueColorAlpha`) to revisit.

---

## 10. How to add a common kind of feature

**Add a new field to Document** (e.g. a "starred" flag):
1. Add the column to the `Documents` table in `database.dart`, bump
   `schemaVersion`, add a migration step.
2. Run `dart run build_runner build --delete-conflicting-outputs`.
3. Add the field to the `Document` model (`lib/data/models/document.dart`)
   and to `_toModel`/`create` in `DriftDocumentRepository`.
4. Use it in the UI same as any other field.

**Add a new screen/tab:**
1. Build the screen as a `ConsumerWidget` under `lib/ui/<name>/`.
2. Add a case to whatever's switching on `MobileTab` in `home_shell.dart`
   (or add a new enum value to `MobileTab` in `library_controller.dart` if
   it's a new bottom-nav destination).

**Add a new modal/bottom sheet:**
Copy the shape of `lib/ui/category/new_category_sheet.dart` — a
`showXSheet(context)` function plus a private `ConsumerStatefulWidget`. Read
from repositories via `ref.read(...RepositoryProvider)`, don't reach into
`AppDatabase` directly.

**Swap in a remote backend:** see §5.

**Turn AI on:** see §8.

---

## 11. Running and testing

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after any Drift/table change
flutter analyze
flutter test
flutter run -d chrome            # fastest way to iterate on this Windows dev machine
flutter run -d <android-device>  # primary shipping-target verification
```

`flutter test` covers the pure-Dart filter/sort logic in
`LibraryController` (`test/widget_test.dart`). It deliberately does not
boot the full app widget tree, because that needs real `path_provider`/
`sqlite3` platform channels that aren't available in the unit-test
environment — full golden-path verification is done by actually running
the app (web or a device/emulator), not by an automated widget test.

There is no seeded demo data anymore: a fresh install starts with the five
default categories (Finance/Health/Housing/Personal/Travel) and an empty
document list. Every document you see after that came from a real upload
through the app.
