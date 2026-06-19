/// Replace the two placeholder values with your Supabase project credentials,
/// then run `flutter pub get` and restart the app to enable cloud sync + sharing.
///
/// Get these from: https://supabase.com → your project → Settings → API
///
/// See /supabase/schema.sql for the required database schema.
class AppConfig {
  AppConfig._();

  static const supabaseUrl = 'YOUR_SUPABASE_URL';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// True only when both values have been replaced with real credentials.
  static bool get isConfigured =>
      !supabaseUrl.startsWith('YOUR_') && !supabaseAnonKey.startsWith('YOUR_');
}
