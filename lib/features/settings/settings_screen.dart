import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/config/env.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_providers.dart';
import '../auth/data/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppScreen(
        child: ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 28),
          children: [
            Row(
              children: [
                CircleIconButton(
                  icon: LucideIcons.arrowLeft,
                  tooltip: 'Geri',
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
                const SizedBox(width: 12),
                Text('Ayarlar', style: AppText.screenTitle),
              ],
            ),
            const SizedBox(height: 24),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _Row(label: 'Ad', value: ref.watch(userNameProvider)),
                  const Divider(),
                  _Row(label: 'E-posta', value: user?.email ?? '—'),
                  const Divider(),
                  _Row(
                    label: 'Para birimi',
                    value: '${baseCurrency.code} (${baseCurrency.symbol})',
                  ),
                  const Divider(),
                  _Row(
                    label: 'Veri kaynağı',
                    value: Env.hasSupabase ? 'Supabase' : 'Örnek veri (demo)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GhostButton(
              label: 'Çıkış yap',
              icon: LucideIcons.arrowLeft,
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).signOut();
                } on AuthFailure catch (failure) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(failure.message)));
                  }
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Veriler bilgi amaçlıdır, yatırım tavsiyesi değildir. '
              'Fiyatlar kaynağa göre gecikmeli olabilir; her varlığın '
              'tazeliği listelerde yazar.',
              style: AppText.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.bodySecondary)),
          Flexible(
            child: Text(
              value,
              style: AppText.body,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
