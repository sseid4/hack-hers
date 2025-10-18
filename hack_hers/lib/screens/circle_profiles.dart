import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/db.dart';
import '../data/models.dart';

class CircleProfilesScreen extends StatefulWidget {
  static const route = '/profiles';
  const CircleProfilesScreen({super.key});

  @override
  State<CircleProfilesScreen> createState() => _CircleProfilesScreenState();
}

class _CircleProfilesScreenState extends State<CircleProfilesScreen> {
  late Future<List<Profile>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<AppDatabase>().getProfiles();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Circle')),
      body: FutureBuilder<List<Profile>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No profiles yet. Tap + to add.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(p.name),
                subtitle: Text(p.relationship),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await context.read<AppDatabase>().deleteProfile(p.id!);
                    _reload();
                  },
                ),
                onTap: () => _openForm(p),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm(Profile? p) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _ProfileForm(profile: p)));
    _reload();
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.profile});
  final Profile? profile;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final nameCtrl = TextEditingController();
  final relationCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    if (p != null) {
      nameCtrl.text = p.name;
      relationCtrl.text = p.relationship;
      tagsCtrl.text = p.tags ?? '';
      noteCtrl.text = p.note ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Add Profile' : 'Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: relationCtrl,
            decoration: const InputDecoration(labelText: 'Relationship'),
          ),
          TextField(
            controller: tagsCtrl,
            decoration: const InputDecoration(
              labelText: 'Memory Tags (comma separated)',
            ),
          ),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note/Voice placeholder',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final db = context.read<AppDatabase>();
              final p = Profile(
                id: widget.profile?.id,
                name: nameCtrl.text,
                relationship: relationCtrl.text,
                tags: tagsCtrl.text,
                note: noteCtrl.text,
              );
              if (widget.profile == null) {
                await db.insertProfile(p);
              } else {
                await db.updateProfile(p);
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
