import 'package:finans_takip/app/app.dart';
import 'package:finans_takip/data/providers/app_providers.dart';
import 'package:finans_takip/data/providers/mock_price_provider.dart';
import 'package:finans_takip/features/auth/auth_providers.dart';
import 'package:finans_takip/features/auth/data/auth_repository.dart';
import 'package:finans_takip/features/auth/data/demo_auth_repository.dart';
import 'package:finans_takip/features/auth/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppUser.greetingName', () {
    test('prefers the display name', () {
      const user = AppUser(
        id: '1',
        email: 'mustafa@example.com',
        displayName: 'Mustafa',
      );
      expect(user.greetingName, 'Mustafa');
    });

    test('falls back to the part before the @, capitalised', () {
      const user = AppUser(id: '1', email: 'zeynep@example.com');
      expect(user.greetingName, 'Zeynep');
    });

    test('ignores a blank display name', () {
      const user = AppUser(
        id: '1',
        email: 'ali@example.com',
        displayName: '   ',
      );
      expect(user.greetingName, 'Ali');
    });
  });

  group('auth state', () {
    test('starts from the restored session and follows sign-out', () async {
      final repository = DemoAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(container.read(isSignedInProvider), isTrue);
      expect(container.read(userNameProvider), 'Mustafa');

      await repository.signOut();
      await container.pump();

      expect(container.read(authProvider), isNull);
      expect(container.read(isSignedInProvider), isFalse);
    });

    test('a sign-up keeps the name the user typed', () async {
      final repository = DemoAuthRepository();
      await repository.signOut();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(container.read(authProvider), isNull);

      final outcome = await repository.signUpWithEmail(
        email: 'yeni@example.com',
        password: 'cokgizli',
        displayName: 'Zeynep',
      );
      await container.pump();

      expect(outcome, SignUpOutcome.signedIn);
      expect(container.read(authProvider)?.displayName, 'Zeynep');
    });
  });

  testWidgets('without a session the router shows the sign-in screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = DemoAuthRepository();
    await repository.signOut();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          priceSourceProvider.overrideWithValue(
            MockPriceProvider(latency: Duration.zero, ticking: false),
          ),
        ],
        child: const FinansTakipApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Giriş yap'), findsWidgets);
    expect(find.text('Toplam portföy değeri'), findsNothing);

    // Signing in hands the user over to the home screen.
    await repository.signInWithEmail(
      email: 'mustafa@example.com',
      password: 'cokgizli',
    );
    await tester.pumpAndSettle();

    expect(find.text('Toplam portföy değeri'), findsOneWidget);
  });
}
