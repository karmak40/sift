# drift_worker.js / sqlite3.wasm

These two files make the local database work on the Web target
(`drift`'s SQLite-in-the-browser support, see `lib/data/local/database.dart`).
They are build artifacts, not hand-written source:

- `sqlite3.wasm` — copied from the `drift` package's own devtools build
  (`<pub cache>/drift-<version>/extension/devtools/build/sqlite3.wasm`).
- `drift_worker.js` (+ `.deps`/`.map`) — compiled from `tool/web_worker.dart`
  via `dart compile js -o web/drift_worker.js tool/web_worker.dart`.

**If you upgrade the `drift` package**, regenerate `drift_worker.js` with
the command above so the worker version matches — a mismatched worker
version is the most likely cause of the app failing to open its database
only on Web (native platforms don't use these files at all).
