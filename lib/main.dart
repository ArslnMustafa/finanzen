import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean URLs on the web (/markets instead of /#/markets). Needs the host
  // to rewrite unknown paths to index.html; see docs/deployment notes.
  usePathUrlStrategy();
  // Every number and date in the app is formatted Turkish.
  Intl.defaultLocale = 'tr_TR';
  await initializeDateFormatting('tr_TR');
  runApp(const ProviderScope(child: FinansTakipApp()));
}
