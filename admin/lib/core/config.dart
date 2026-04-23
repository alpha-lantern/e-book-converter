/// Configuration class for managing external service credentials.
class AppConfig {
  /// The base API URL for the Supabase project.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nlucbgajcftcnzjqcavn.supabase.co',
  );

  /// The public anonymous key for the Supabase project.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_ONmVzK26KPvSfs8pAny2cQ_RyT6rofG',
  );
}
