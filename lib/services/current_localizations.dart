import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

/// Looks up an [AppLocalizations] instance from the app's current locale,
/// for the handful of non-widget services (file storage, reminders) that
/// need to produce user-facing text without a `BuildContext`.
///
/// Relies on [Intl.defaultLocale] being kept in sync with the user's chosen
/// language (see `AppLocaleController`), so this stays correct even before
/// any widget has built.
AppLocalizations currentLocalizations() {
  final code = Intl.defaultLocale ?? 'en';
  return lookupAppLocalizations(Locale(code));
}
