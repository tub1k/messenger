import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/settings/bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: Text(context.l10n.systemLang),
              onTap: () {
                context.read<SettingsBloc>().add(
                  SettingsSetLocale(localeCode: 'system'),
                );
              },
            ),
            ListTile(
              title: Text('Русский'),
              onTap: () {
                context.read<SettingsBloc>().add(
                  SettingsSetLocale(localeCode: 'ru'),
                );
              },
            ),
            ListTile(
              title: Text('English'),
              onTap: () {
                context.read<SettingsBloc>().add(
                  SettingsSetLocale(localeCode: 'en'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: Text(context.l10n.systemTheme),
              onTap: () {
                context.read<SettingsBloc>().add(
                  SettingsSetTheme(themeSetting: AppThemeSetting.system),
                );
              },
            ),
            ListTile(
              title: Text(context.l10n.lightTheme),
              onTap: () {
                context.read<SettingsBloc>().add(
                  SettingsSetTheme(themeSetting: AppThemeSetting.light),
                );
              },
            ),
            ListTile(
              title: Text(context.l10n.amoledTheme),
              onTap: () {
                context.read<SettingsBloc>().add(
                  SettingsSetTheme(themeSetting: AppThemeSetting.amoled),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settings)),
          body: ListView(
            key: const PageStorageKey<String>('settings_scroll_position'),
            children: [
              ListTile(
                title: Text(context.l10n.language),
                subtitle: Text(state.locale.languageCode),
                onTap: () {
                  showLanguageSheet(context);
                },
              ),
              ListTile(
                title: Text(context.l10n.theme),
                subtitle: Text(switch (state.otherSettings['theme']
                    as AppThemeSetting) {
                  AppThemeSetting.system => context.l10n.systemTheme,
                  AppThemeSetting.light => context.l10n.lightTheme,
                  AppThemeSetting.amoled => context.l10n.amoledTheme,
                }),
                onTap: () {
                  showThemeSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
