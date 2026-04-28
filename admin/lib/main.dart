import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';
import 'screens/login_screen.dart';
import 'widgets/book_list_view.dart';
import 'widgets/file_upload_zone.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard against missing configuration
  assert(
    AppConfig.supabaseUrl.isNotEmpty,
    'SUPABASE_URL must be provided via --dart-define',
  );
  assert(
    AppConfig.supabaseAnonKey.isNotEmpty,
    'SUPABASE_ANON_KEY must be provided via --dart-define',
  );

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Codex Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        children: [
          FileUploadZone(
            onFileSelected: (file) {
              if (kDebugMode && file != null) {
                debugPrint('Selected file: ${file.path}');
              }
            },
          ),
          const Expanded(
            child: BookListView(),
          ),
        ],
      ),
    );
  }
}
