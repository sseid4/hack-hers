import 'package:flutter/material.dart';

class RecognitionScreen extends StatelessWidget {
  static const route = '/recognition';
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recognition')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Camera is OFF in prototype. We will show a live preview only with consent.',
            ),
            const SizedBox(height: 16),
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: const Center(child: Text('Identifying…')),
            ),
            const SizedBox(height: 24),
            const Text(
              'Catherine\nDaughter\n"You had lunch with her yesterday"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Correct'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
