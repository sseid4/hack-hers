import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/db.dart';
import 'data/models.dart';
import 'screens/home.dart';
import 'screens/memory_aid.dart';
import 'screens/schedule.dart';
import 'screens/profile.dart';
import 'screens/circle_profiles.dart';
import 'screens/reminder.dart';
import 'screens/recognition.dart';
import 'screens/settings.dart';
import 'screens/support.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppSettings? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await AppDatabase.instance.getSettings();
    setState(() => _settings = s);
  }

  ThemeData _buildTheme(AppSettings s) {
    const primary = Color(0xFF6CB2B8); // soft teal
    const secondary = Color(0xFF8BC6C6);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
    ).copyWith(primary: primary, secondary: secondary);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: ThemeData.light().textTheme.apply(fontSizeFactor: s.fontScale),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _settings ?? AppSettings();
    return MultiProvider(
      providers: [Provider<AppDatabase>.value(value: AppDatabase.instance)],
      child: MaterialApp(
        title: 'HackHers',
        theme: _buildTheme(s),
        initialRoute: HomeScreen.route,
        routes: {
          HomeScreen.route: (_) => const HomeScreen(),
          ProfileScreen.route: (_) => const ProfileScreen(),
          CircleProfilesScreen.route: (_) => const CircleProfilesScreen(),
          ReminderScreen.route: (_) => const ReminderScreen(),
          MemoryAidScreen.route: (_) => const MemoryAidScreen(),
          ScheduleScreen.route: (_) => const ScheduleScreen(),
          RecognitionScreen.route: (_) => const RecognitionScreen(),
          SettingsScreen.route: (_) => const SettingsScreen(),
          SupportScreen.route: (_) => const SupportScreen(),
        },
      ),
    );
  }
}
