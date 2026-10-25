import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'widgets/alert_card.dart';
import 'widgets/alert_form_sheet.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final assetsById = ref.watch(assetsByIdProvider);
    final quotes = ref.watch(quotesProvider).value;

    return AppScreen(
      child: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 28),
        children: [
          Row(
            children: [
              Expanded(child: Text('Alarmlar', style: AppText.screenTitle)),
              PillButton(
                label: 'Ekle',
                icon: LucideIcons.plus,
                onPressed: () => showAlertFormSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Alarm tetiklendiğinde uygulama içi bildirim ve e-posta gönderilir.',
            style: AppText.caption,
          ),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            AppCard(
              radius: AppRadius.largeCard,
              child: EmptyState(
                icon: LucideIcons.bell,
                title: 'Henüz alarm kurmadın',
                message: 'Takip ettiğin bir varlık belirlediğin fiyatı geçtiğinde haber verelim.',
                actionLabel: 'Alarm kur',
                onAction: () => showAlertFormSheet(context),
              ),
            )
          else
            for (final alert in alerts) ...[
              if (alert != alerts.first)
                const SizedBox(height: AppSpacing.card),
              if (assetsById[alert.assetId] != null)
                AlertCard(
                  alert: alert,
                  asset: assetsById[alert.assetId]!,
                  quote: quotes?[alert.assetId],
                  onToggle: (value) => ref
                      .read(alertsProvider.notifier)
                      .setActive(alert.id, isActive: value),
                  onDelete: () =>
                      ref.read(alertsProvider.notifier).remove(alert.id),
                ),
            ],
        ],
      ),
    );
  }
}
