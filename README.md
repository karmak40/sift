# Sift

A local-only document vault. Scan or upload the documents that matter —
passports, insurance policies, warranties, leases — organize them into
categories, and get reminded before they expire. Everything stays on your
device; nothing is uploaded anywhere unless you explicitly choose to.

## Features

- **Library** — grid/list views, category filters, search across
  documents (and AI summaries, once that's turned on), sort by
  date/name/size.
- **Scan or upload** — capture paper documents with the camera
  (assembled into a PDF on-device) or pick existing files, single or in
  bulk.
- **Expiration tracking** — set an expiration date on any document and
  get a local reminder before it lapses; the "Coming up" tab triages
  everything expiring soon or already overdue.
- **App Lock** — optional PIN + biometric (Face ID/Touch ID/Windows
  Hello/Android biometric) unlock.
- **Backup & Restore** — export everything (documents, categories,
  metadata) into a single file you control, and restore it any time, on
  any device — no cloud account required.
- **Multi-language** — English, Russian, Ukrainian, and German.
- **AI summaries** — the infrastructure exists but ships **off by
  default**; nothing is sent to any AI service unless a future release
  turns it on and you explicitly opt in per document.

See [PRIVACY.md](PRIVACY.md) (also published at
[karmak40.github.io/sift](https://karmak40.github.io/sift/)) for exactly
what does and doesn't happen with your data.

## Platforms

Android and iOS are the shipping targets. Windows and Web builds also
work and are used for fast iteration during development, but aren't the
primary target.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter gen-l10n                                            # localization codegen
flutter run
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for a full tour of the codebase —
folder structure, data flow, and a deep dive into every feature — and
`flutter test` for the test suite.
