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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settings)),
          body: ListView(
            children: [
              ListTile(
                title: Text(context.l10n.language),
                subtitle: Text(state.locale.languageCode),
                onTap: () {
                  showLanguageSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
