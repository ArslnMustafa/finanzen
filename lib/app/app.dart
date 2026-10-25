import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../theme/app_theme.dart';
import 'router.dart';

class FinansTakipApp extends StatelessWidget {
  const FinansTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finans Takip',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
