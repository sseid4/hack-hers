import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/db.dart';
import '../data/models.dart';

class MemoryAidScreen extends StatefulWidget {
  static const route = '/memory';
  const MemoryAidScreen({super.key});

  @override
  State<MemoryAidScreen> createState() => _MemoryAidScreenState();
}

class _MemoryAidScreenState extends State<MemoryAidScreen> {
  List<Profile> items = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    items = await context.read<AppDatabase>().getProfiles();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Aid')),
      body: items.isEmpty
          ? const Center(child: Text('Add profiles to start.'))
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    onPageChanged: (i) => setState(() => index = i),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final p = items[i];
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              child: Icon(Icons.person, size: 60),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              p.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(p.relationship),
                            const SizedBox(height: 8),
                            Text(p.tags ?? '—'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _markRecognized(context),
                          child: const Text('Recognize'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _markConfused(context),
                          child: const Text('Confused'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _markRecognized(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Great!')));
  }

  void _markConfused(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("We'll show this more often")));
  }
}
