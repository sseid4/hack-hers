import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/db.dart';
import '../data/models.dart';
import 'reminder.dart';
import 'memory_aid.dart';
import 'schedule.dart';
import 'circle_profiles.dart';
import 'profile.dart';
import 'recognition.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool voiceOverEnabled = false;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Widget _actionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed, {
    Color color = Colors.blue,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        icon: Icon(icon),
        onPressed: onPressed,
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Profile? nextPerson;
  EventItem? nextEvent;
  AppSettings? settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = context.read<AppDatabase>();
    final s = await db.getSettings();
    // Seed a sample profile/event if empty
    if ((await db.getProfiles()).isEmpty) {
      final id = await db.insertProfile(
        Profile(
          name: 'Catherine',
          relationship: 'Daughter',
          tags: 'Loves gardening',
        ),
      );
      await db.insertEvent(
        EventItem(
          profileId: id,
          dateTime: DateTime.now().add(const Duration(minutes: 30)),
          title: 'Visit',
          type: 'family',
        ),
      );
    }
    final events = await db.getUpcomingEvents(limit: 1);
    EventItem? e = events.isNotEmpty ? events.first : null;
    Profile? p;
    if (e?.profileId != null) {
      p = await db.getProfile(e!.profileId!);
    } else {
      final profiles = await db.getProfiles();
      if (profiles.isNotEmpty) p = profiles.first;
    }
    if (!mounted) return;
    setState(() {
      settings = s;
      nextEvent = e;
      nextPerson = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = settings ?? AppSettings();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Remi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              voiceOverEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            tooltip: voiceOverEnabled ? 'Mute Voice Over' : 'Enable Voice Over',
            onPressed: () async {
              setState(() {
                voiceOverEnabled = !voiceOverEnabled;
              });
              if (voiceOverEnabled) {
                await flutterTts.speak(
                  "Welcome to Remi. Today's Reminder. " +
                      (nextPerson?.name ?? "") +
                      " " +
                      (nextPerson?.relationship ?? "") +
                      ". " +
                      (nextEvent?.title ?? "") +
                      ". " +
                      "Use the buttons below to access My Circle, Memory Aid, Schedule, and Settings. Emergency Contact and Recognize Visitor options are at the bottom.",
                );
              } else {
                await flutterTts.stop();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, ProfileScreen.route),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // App logo (circular) at top-left
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: Colors.white24,
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Today's Reminder",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                _ReminderCard(profile: nextPerson, event: nextEvent),
                const SizedBox(height: 32),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _navButton(
                      context,
                      'My Circle',
                      Icons.group,
                      CircleProfilesScreen.route,
                    ),
                    _navButton(
                      context,
                      'Memory Aid',
                      Icons.memory,
                      MemoryAidScreen.route,
                    ),
                    _navButton(
                      context,
                      'Schedule',
                      Icons.calendar_today,
                      ScheduleScreen.route,
                    ),
                    _navButton(
                      context,
                      'Settings',
                      Icons.settings,
                      SettingsScreen.route,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        context,
                        s.emergencyName == null
                            ? 'Emergency Contact'
                            : 'Call ${s.emergencyName}',
                        Icons.phone,
                        _callEmergency,
                        color: const Color(0xFFB993D6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _actionButton(
                        context,
                        'Recognize Visitor',
                        Icons.camera_alt,
                        () => Navigator.pushNamed(
                          context,
                          RecognitionScreen.route,
                        ),
                        color: const Color(0xFF8CA6DB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(
    BuildContext context,
    String text,
    IconData icon,
    String route,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white.withOpacity(0.85),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Color(0xFF8CA6DB)),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF8CA6DB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _callEmergency() async {
    // Prototype: show dialog instead of placing real phone call
    final s = settings ?? AppSettings();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Call Emergency Contact'),
        content: Text(
          s.emergencyPhone == null
              ? 'No emergency contact set yet.'
              : 'Call ${s.emergencyName} at ${s.emergencyPhone}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.profile, required this.event});
  final Profile? profile;
  final EventItem? event;

  @override
  Widget build(BuildContext context) {
    if (profile == null && event == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(context),
        child: const Text('No reminders yet. Add a profile or event.'),
      );
    }
    final date = event != null
        ? DateFormat('EEE, MMM d – h:mm a').format(event!.dateTime)
        : 'Upcoming';
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        ReminderScreen.route,
        arguments: {'profile': profile, 'event': event},
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(context),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              child: Icon(
                Icons.person,
                size: 36,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.name ?? event?.title ?? 'Reminder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    profile?.relationship ?? date,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _box(BuildContext context) => BoxDecoration(
    color: Colors.white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFB993D6)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  Widget _actionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed, {
    Color color = Colors.blue,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        icon: Icon(icon),
        onPressed: onPressed,
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
