import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/db.dart';
import '../data/models.dart';
import 'settings.dart';
import 'support.dart';

class ProfileScreen extends StatefulWidget {
  static const route = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameCtrl = TextEditingController();
  final emergencyNameCtrl = TextEditingController();
  final emergencyPhoneCtrl = TextEditingController();
  bool narration = false;
  bool ai = true;
  bool face = false;
  double fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = context.read<AppDatabase>();
    final s = await db.getSettings();
    setState(() {
      nameCtrl.text = 'Sara'; // placeholder user name
      narration = s.narration;
      ai = s.aiSuggestions;
      face = s.faceRecognitionConsent;
      fontScale = s.fontScale;
      emergencyNameCtrl.text = s.emergencyName ?? '';
      emergencyPhoneCtrl.text = s.emergencyPhone ?? '';
    });
  }

  Future<void> _save() async {
    final db = context.read<AppDatabase>();
    final s = AppSettings(
      narration: narration,
      fontScale: fontScale,
      aiSuggestions: ai,
      faceRecognitionConsent: face,
      emergencyName: emergencyNameCtrl.text.isEmpty
          ? null
          : emergencyNameCtrl.text,
      emergencyPhone: emergencyPhoneCtrl.text.isEmpty
          ? null
          : emergencyPhoneCtrl.text,
    );
    await db.updateSettings(s);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              nameCtrl.text.isEmpty ? 'Sara' : nameCtrl.text,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Update Name'),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: narration,
            onChanged: (v) => setState(() => narration = v),
            title: const Text('Voice Narration'),
          ),
          SwitchListTile(
            value: ai,
            onChanged: (v) => setState(() => ai = v),
            title: const Text('AI Suggestions'),
          ),
          SwitchListTile(
            value: face,
            onChanged: (v) => setState(() => face = v),
            title: const Text('Facial Recognition Consent'),
          ),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Slider(
              value: fontScale,
              min: 0.8,
              max: 1.6,
              divisions: 8,
              label: fontScale.toStringAsFixed(1),
              onChanged: (v) => setState(() => fontScale = v),
            ),
          ),
          const Divider(),
          TextField(
            controller: emergencyNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Name',
            ),
          ),
          TextField(
            controller: emergencyPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Phone',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.route),
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, SupportScreen.route),
            child: const Text('Help & Support'),
          ),
        ],
      ),
    );
  }
}
