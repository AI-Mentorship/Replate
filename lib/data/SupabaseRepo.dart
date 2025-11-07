import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepo {
  final supabase = Supabase.instance.client;

  // AUTH
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId != null) {
      try {
        await supabase.from('users').insert({
          'user_id': userId,
          'full_name': fullName,
          'email': email,
          'calorie_goal': 2000,
          'password_hash': 'placeholder_from_app',
        });
      } catch (e) {
        print('users insert error (signUp): $e');
      }
    }
    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId != null) {
      try {
        final existing = await supabase
            .from('users')
            .select()
            .eq('user_id', userId)
            .limit(1);

        if (existing == null || (existing is List && existing.isEmpty)) {
          await supabase.from('users').insert({
            'user_id': userId,
            'full_name': 'New User',
            'email': email,
            'calorie_goal': 2000,
            'password_hash': 'placeholder_from_app',
          });
        }
      } catch (e) {
        print('users ensure error (signIn): $e');
      }
    }

    return response;
  }

  // Session helpers
  String? getCurrentUserId() => supabase.auth.currentUser?.id;
  Future<void> signOut() async => await supabase.auth.signOut();

  // FETCH METHODS
  Future<List<dynamic>> fetchRecipes(String userId) async =>
      await supabase.from('recipes').select().eq('user_id', userId);

  Future<List<dynamic>> fetchPantry(String userId) async =>
      await supabase.from('pantry').select().eq('user_id', userId);

  Future<List<dynamic>> fetchNutritionLogs(String userId) async =>
      await supabase.from('nutrition_logs')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

  Future<List<dynamic>> fetchUsers() async =>
      await supabase.from('users').select();


  // Substitutions 
  Future<List<dynamic>> fetchSubstitutions() async =>
      await supabase.from('substitutions').select();

  // User Preferences 
  Future<Map<String, dynamic>?> fetchUserPreferences(String userId) async {
    final result = await supabase
        .from('user_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return result;
  }

  Future<void> updateUserPreferences(String userId, Map<String, dynamic> prefs) async {
    await supabase.from('user_preferences').upsert({
      'user_id': userId,
      ...prefs,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // User Progress
  Future<List<dynamic>> fetchUserProgress(String userId) async =>
      await supabase.from('user_progress').select().eq('user_id', userId);

  Future<void> updateUserProgress(
      String userId, String recipeId, int step, bool completed) async {
    await supabase.from('user_progress').upsert({
      'user_id': userId,
      'recipe_id': recipeId,
      'current_step': step,
      'completed': completed,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // User Settings 
  Future<Map<String, dynamic>?> fetchUserSettings(String userId) async {
    final result = await supabase
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return result;
  }

  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings) async {
    await supabase.from('user_settings').upsert({
      'user_id': userId,
      ...settings,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
