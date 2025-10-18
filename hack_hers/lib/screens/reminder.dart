import 'package:flutter/material.dart';
import '../data/models.dart';

class ReminderScreen extends StatelessWidget {
  static const route = '/reminder';
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final Profile? profile = args?['profile'];
    final EventItem? event = args?['event'];
    final List<Map<String, String>> extraReminders = [
      {
        'title': 'Take Medication',
        'detail': 'It is time to take your afternoon medication.',
      },
      {'title': 'Call Sara', 'detail': 'Sara will call you at 4:00 PM today.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 48,
                      child: Icon(Icons.person, size: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile?.name ?? event?.title ?? 'Reminder',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(profile?.relationship ?? 'Visitor/Call'),
                    const SizedBox(height: 8),
                    Text(
                      '"You had lunch with ${profile?.name ?? 'them'} yesterday"',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirm(context),
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _snooze(context),
                      child: const Text('Snooze'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...extraReminders.map(
                (reminder) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              child: Icon(Icons.notifications, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              reminder['title']!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(reminder['detail']!),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reminder confirmed')));
  }

  void _snooze(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Snoozed for 10 minutes')));
  }
}
