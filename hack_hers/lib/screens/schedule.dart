import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/db.dart';
import '../data/models.dart';

class ScheduleScreen extends StatefulWidget {
  static const route = '/schedule';
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime day = DateTime.now();
  List<EventItem> events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    events = await context.read<AppDatabase>().getEventsForDay(day);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          _DayPicker(
            day: day,
            onChanged: (d) => setState(() {
              day = d;
              _load();
            }),
          ),
          const Divider(height: 0),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('No events.'))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (_, i) {
                      final e = events[i];
                      return ListTile(
                        title: Text(e.title),
                        subtitle: Text(
                          DateFormat('h:mm a').format(e.dateTime) +
                              (e.type != null ? '  • ${e.type}' : ''),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await context.read<AppDatabase>().deleteEvent(
                              e.id!,
                            );
                            _load();
                          },
                        ),
                        onTap: () => _openForm(e),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm(EventItem? e) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _EventForm(event: e, initialDay: day),
      ),
    );
    _load();
  }
}

class _DayPicker extends StatelessWidget {
  final DateTime day;
  final ValueChanged<DateTime> onChanged;
  const _DayPicker({required this.day, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final d = DateFormat('EEE, MMM d, yyyy').format(day);
    return Row(
      children: [
        IconButton(
          onPressed: () => onChanged(day.subtract(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(child: Center(child: Text(d))),
        IconButton(
          onPressed: () => onChanged(day.add(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _EventForm extends StatefulWidget {
  const _EventForm({required this.event, required this.initialDay});
  final EventItem? event;
  final DateTime initialDay;

  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  final titleCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  String? type;
  DateTime when = DateTime.now();

  @override
  void initState() {
    super.initState();
    when = DateTime(
      widget.initialDay.year,
      widget.initialDay.month,
      widget.initialDay.day,
      TimeOfDay.now().hour,
      0,
    );
    final e = widget.event;
    if (e != null) {
      titleCtrl.text = e.title;
      notesCtrl.text = e.notes ?? '';
      type = e.type;
      when = e.dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          DropdownButtonFormField<String>(
            value: type,
            items: const [
              DropdownMenuItem(value: 'family', child: Text('Family')),
              DropdownMenuItem(value: 'medical', child: Text('Medical')),
              DropdownMenuItem(value: 'social', child: Text('Social')),
            ],
            onChanged: (v) => setState(() => type = v),
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          ListTile(
            title: const Text('When'),
            subtitle: Text(DateFormat('EEE, MMM d – h:mm a').format(when)),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: when,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (d == null) return;
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(when),
              );
              final dateTime = DateTime(
                d.year,
                d.month,
                d.day,
                t?.hour ?? when.hour,
                t?.minute ?? when.minute,
              );
              setState(() => when = dateTime);
            },
          ),
          TextField(
            controller: notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final db = context.read<AppDatabase>();
    final e = EventItem(
      id: widget.event?.id,
      profileId: null,
      dateTime: when,
      title: titleCtrl.text,
      type: type,
      notes: notesCtrl.text,
    );
    if (widget.event == null) {
      await db.insertEvent(e);
    } else {
      await db.updateEvent(e);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}
