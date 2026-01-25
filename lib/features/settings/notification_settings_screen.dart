import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SwitchListTile(
        title: const Text('Notify when next'),
        value: settings.notifyNext,
        onChanged: settings.toggleNotify,
      ),
    );
  }
}
