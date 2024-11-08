import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

export 'database/database.dart';

String _kSupabaseUrl = 'https://dnrinnvsfrbmrlmcxiij.supabase.co';
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRucmlubnZzZnJibXJsbWN4aWlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIyNTE1ODUsImV4cCI6MjAzNzgyNzU4NX0.pQ4yOOl4OLnHnG4Cx9JUC8KD0SSUHVsR0Q2_6DZdUyU';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        anonKey: _kSupabaseAnonKey,
        debug: false,
      );
}
