import '../../core/dio_client.dart';
import '../../core/api_constants.dart';
import 'recipe_model.dart';

class RecipeRepository {
  final DioClient _client;

  RecipeRepository(this._client);

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await _client.dio.get(
      ApiConstants.recipes,
      queryParameters: {'query': query},
    );

    final data = response.data as List<dynamic>;
    return data.map((json) => Recipe.fromJson(json)).toList();
  }
}
