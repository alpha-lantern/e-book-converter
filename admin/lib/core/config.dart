/// Configuration class for managing external service credentials.
class AppConfig {
  /// The base API URL for the Supabase project.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// The public anonymous key for the Supabase project.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
}
