import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';
import 'screens/editor_screen.dart';
import 'screens/login_screen.dart';
import 'services/book_repository.dart';
import 'widgets/book_list_view.dart';
import 'widgets/file_upload_zone.dart';
import 'dart:ui';
import 'screens/debug_logs_screen.dart';
import 'services/debug_logger.dart';

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

  final container = ProviderContainer();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (AppConfig.enableDebugLogs) {
      container.read(debugLoggerProvider.notifier).logError(
            'Flutter Error: ${details.exceptionAsString()}',
            error: details.exception,
            stackTrace: details.stack,
          );
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (AppConfig.enableDebugLogs) {
      container.read(debugLoggerProvider.notifier).logError(
            'Platform Error: $error',
            error: error,
            stackTrace: stack,
          );
    }
    return true;
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
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
        '/editor': (context) => const EditorScreen(),
        '/debug-logs': (context) => const DebugLogsScreen(),
      },
    );
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isUploading = false;

  Future<void> _uploadFile(PlatformFile file) async {
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to read file bytes. Only web upload from memory is supported.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await ref.read(bookRepositoryProvider).createBook(file.name, file.bytes!);
      
      // Refresh the book list provider
      ref.invalidate(bookListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded ${file.name} successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (AppConfig.enableDebugLogs)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () => Navigator.pushNamed(context, '/debug-logs'),
              tooltip: 'View Debug Logs',
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              FileUploadZone(
                onFileSelected: (file) {
                  if (file != null) {
                    _uploadFile(file);
                  }
                },
              ),
              const Expanded(
                child: BookListView(),
              ),
            ],
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
