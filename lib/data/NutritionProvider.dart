import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionProvider {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getTodayNutrition(String userId) async {
    final response = await supabase
        .from('nutrition_logs')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return {'calories': 0, 'protein': 0, 'fat': 0, 'carbs': 0, 'fiber': 0};
    }

    return {
      'calories': response['calories'] ?? 0,
      'protein': response['protein'] ?? 0,
      'fat': response['fat'] ?? 0,
      'carbs': response['carbs'] ?? 0,
      'fiber': response['fiber'] ?? 0,
    };
  }
}
