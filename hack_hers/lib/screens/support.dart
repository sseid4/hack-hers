import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  static const route = '/support';
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('FAQ'),
          const SizedBox(height: 8),
          const Text(
            '• How to add a profile? Use My Circle > +\n• How to add an event? Use Schedule > +',
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call),
            label: const Text('Call Support'),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call),
            label: const Text('Call Caregiver'),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat),
            label: const Text('Live Chat (prototype)'),
          ),
        ],
      ),
    );
  }
}
