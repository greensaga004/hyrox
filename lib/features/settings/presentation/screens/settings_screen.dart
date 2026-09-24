// features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/features/settings/application/settings_controller.dart';
import 'package:hyrox/features/settings/domain/settings_models.dart';
import 'package:hyrox/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsViewState state = ref.watch(settingsControllerProvider);
    final SettingsController controller = ref.read(
      settingsControllerProvider.notifier,
    );
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLanguage effectiveLanguage = controller.effectiveLanguage(
      Localizations.localeOf(context),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (state.isSavingLanguage) ...<Widget>[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          Text(
            l10n.settingsLanguageSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<AppLanguage>(
                segments: <ButtonSegment<AppLanguage>>[
                  ButtonSegment<AppLanguage>(
                    value: AppLanguage.traditionalChinese,
                    label: Text(l10n.languageTraditionalChineseLabel),
                  ),
                  ButtonSegment<AppLanguage>(
                    value: AppLanguage.english,
                    label: Text(l10n.languageEnglishLabel),
                  ),
                ],
                selected: <AppLanguage>{effectiveLanguage},
                onSelectionChanged: (Set<AppLanguage> selection) {
                  controller.selectLanguage(selection.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.settingsAppInfoSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${l10n.settingsAppNameLabel}: ${state.appInfo.appName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.settingsVersionLabel}: ${state.appInfo.version}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.settingsBuildNumberLabel}: ${state.appInfo.buildNumber}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (state.isLoading) ...<Widget>[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.settingsFutureSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: <Widget>[
                _FutureSettingTile(title: l10n.settingsFutureAutoTransition),
                _FutureSettingTile(title: l10n.settingsFutureVoiceAlerts),
                _FutureSettingTile(
                  title: l10n.settingsFutureNotificationSettings,
                ),
                _FutureSettingTile(
                  title: l10n.settingsFutureDefaultRestDuration,
                ),
                _FutureSettingTile(title: l10n.settingsFutureTargetFinishTime),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FutureSettingTile extends StatelessWidget {
  const _FutureSettingTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.schedule),
      title: Text(title),
      subtitle: Text(l10n.settingsComingSoonLabel),
      enabled: false,
    );
  }
}
