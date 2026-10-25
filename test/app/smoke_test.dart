import 'package:finans_takip/data/providers/app_providers.dart';
import 'package:finans_takip/data/providers/mock_price_provider.dart';
import 'package:finans_takip/features/home/home_screen.dart';
import 'package:finans_takip/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    // Tests must not reach out to fonts.googleapis.com.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('home screen shows the portfolio total and the watchlist', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          priceSourceProvider.overrideWithValue(
            MockPriceProvider(latency: Duration.zero, ticking: false),
          ),
        ],
        child: MaterialApp(theme: buildAppTheme(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toplam portföy değeri'), findsOneWidget);
    expect(find.text('İzleme listem'), findsOneWidget);
    expect(find.text('Varlık ekle'), findsOneWidget);
    // Bitcoin sits on the mock watchlist: once in the icon box, once as the
    // row title, plus the name in the subtitle.
    expect(find.text('BTC'), findsNWidgets(2));
    expect(find.textContaining('Bitcoin'), findsOneWidget);
  });

  test('greeting changes with the hour', () {
    expect(greetingFor(DateTime(2026, 1, 1, 8)), 'Günaydın');
    expect(greetingFor(DateTime(2026, 1, 1, 14)), 'İyi günler');
    expect(greetingFor(DateTime(2026, 1, 1, 21)), 'İyi akşamlar');
    expect(greetingFor(DateTime(2026, 1, 1, 3)), 'İyi geceler');
  });
}
