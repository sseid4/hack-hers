import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/db.dart';
import '../data/models.dart';

class SettingsScreen extends StatefulWidget {
  static const route = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings s = AppSettings();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    s = await context.read<AppDatabase>().getSettings();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _save() async {
    await context.read<AppDatabase>().updateSettings(s);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            value: s.faceRecognitionConsent,
            onChanged: (v) => setState(() => s.faceRecognitionConsent = v),
            title: const Text('Face Recognition'),
          ),
          SwitchListTile(
            value: s.aiSuggestions,
            onChanged: (v) => setState(() => s.aiSuggestions = v),
            title: const Text('AI Suggestions'),
          ),
          SwitchListTile(
            value: s.narration,
            onChanged: (v) => setState(() => s.narration = v),
            title: const Text('Narration'),
          ),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Slider(
              value: s.fontScale,
              min: 0.8,
              max: 1.6,
              divisions: 8,
              label: s.fontScale.toStringAsFixed(1),
              onChanged: (v) => setState(() => s.fontScale = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(onPressed: _save, child: const Text('Save')),
          ),
        ],
      ),
    );
  }
}
