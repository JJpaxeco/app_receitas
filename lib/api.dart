import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List> fetchRecipes(String cuisine) async {
    final url = 'https://www.themealdb.com/api/json/v1/1/filter.php?a=$cuisine';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'] ?? [];
    } else {
      return [];
    }
  }

  static Future<Map> fetchRecipeDetails(String recipeId) async {
    final url = 'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$recipeId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'][0] ?? {};
    } else {
      return {};
    }
  }
}
