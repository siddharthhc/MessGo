import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Signup
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String role,
  }) async {
    try {
      // 1. Check if username already exists
      final existing = await supabase
          .from('profiles')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        return 'Username already taken';
      }

      // 2. Create auth user
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return 'Signup failed';
      }

      // 3. Create profile
      await supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
        'full_name': fullName,
        'role': role,
      });

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // Current user
  User? get currentUser => supabase.auth.currentUser;

  // Get profile
  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }
}
