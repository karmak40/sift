# Sift Privacy Policy

_Last updated: 2026-07-23_

Sift is a local-only document vault. This policy explains, plainly, what
that means in practice.

## The short version

Sift doesn't have a server. There's no account to create, nothing is
uploaded anywhere, and the people who make Sift never see your documents,
your categories, or anything else you store in the app. Everything lives
in a local database and local files on your own device.

## What Sift stores, and where

- **Documents, categories, expiration dates, and AI-summary text** (if you
  ever turn AI summaries on — see below) are stored in a local database on
  your device.
- **The actual files you upload or scan** are stored on your device's own
  filesystem (or, in the web preview build, as part of that same local
  database).
- **Your PIN**, if you turn on App Lock, is stored locally as a salted
  hash — never as plain text, and never anywhere but your device.
- **Biometric unlock** (Face ID, Touch ID, Windows Hello, Android
  fingerprint/face unlock) is handled entirely by your device's operating
  system. Sift asks the OS "did this person pass your biometric check?"
  and gets a yes/no answer back — it never receives, stores, or has
  access to any biometric data itself.
- **Forgot your PIN?** The same "ask the OS, get a yes/no" pattern is used
  to let you set a new one: Sift asks your device to confirm it's you,
  using either biometric or your device's own screen lock (PIN, pattern,
  or password) — again never seeing or storing any of that. Your PIN is
  just a lock-screen gate, not an encryption key for your documents, so
  resetting it doesn't touch or re-encrypt anything already stored.

None of this is transmitted to Sift's developer, an analytics service, or
any third party. Sift doesn't use analytics, crash reporting, or
advertising SDKs of any kind.

## Permissions Sift asks for, and why

- **Camera** — used only when you choose to scan a document. Pages are
  turned into a PDF entirely on your device; the images are never sent
  anywhere else.
- **Notifications** — used only to remind you a document is about to
  expire. These reminders are scheduled locally on your device; no
  notification server is involved.
- **Biometric hardware** — used only for the optional App Lock feature,
  as described above.

## Backup & Restore

Sift can export everything it stores into a single backup file, entirely
under your control. When you back up, Sift hands that file to you — via
your device's share sheet (so you can save it to your own cloud drive,
email it to yourself, etc.) or a save dialog you control. Sift itself
never uploads that file anywhere. Restoring works the same way in
reverse: you choose a backup file from your own device, and nothing
leaves it.

## Your device's own backup features

Android and iOS both offer OS-level backup services (for example,
Android's Auto Backup to your own Google account, or an iOS device backup
via iCloud or Finder). Depending on your device settings, these may
include Sift's local data as part of your regular phone backup, the same
way they back up any other app. That's a feature of your device's
operating system, between you and your own cloud account — Sift's
developer has no access to it.

## AI summaries

Sift has an optional AI document-summary feature. **It is turned off by
default in this version of the app**, and nothing is sent to any AI
service unless a future version enables it and you explicitly choose to
use it on a specific document. If that ever changes, this policy will be
updated first to explain exactly what gets sent, to whom, and how to keep
it off.

## Data retention and deletion

Your documents stay on your device for as long as you keep them there.
Deleting a document or category in the app removes it from local storage
immediately. Uninstalling Sift removes all of its local data from your
device (subject to your OS's own backup settings, as noted above).

## Children's privacy

Sift is not directed at children under 13 and does not knowingly collect
information from anyone, since it doesn't collect information from
anyone at all — everything stays on-device.

## Changes to this policy

If Sift's data practices ever change — most notably if AI summaries are
enabled by default, or if any server-backed feature (like cloud sync) is
ever added — this policy will be updated to describe the change before it
ships, and the in-app version of this page will reflect the update.

## Contact

Questions about this policy: karmak40@outlook.com
