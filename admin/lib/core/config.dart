/// Configuration class for managing external service credentials.
class AppConfig {
  /// The base API URL for the Supabase project.
  static const String supabaseUrl = String.fromEnvironment(
    'NEXT_PUBLIC_SUPABASE_URL',
    defaultValue: '',
  );

  /// The public anonymous key for the Supabase project.
  static const String supabaseAnonKey = String.fromEnvironment(
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Feature flag to enable debug logs storage and interception.
  static const bool enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: true,
  );

  /// The base URL for the deployed Reader app (for author preview).
  static const String readerBaseUrl = String.fromEnvironment(
    'READER_BASE_URL',
    defaultValue: 'https://codex-reader.pages.dev',
  );
}
