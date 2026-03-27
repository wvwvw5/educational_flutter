import '../../core/dio_client.dart';
import '../../core/api_constants.dart';
import 'animal_model.dart';

class AnimalRepository {
  final DioClient _client;

  AnimalRepository(this._client);

  Future<List<Animal>> searchAnimals(String name) async {
    final response = await _client.dio.get(
      ApiConstants.animals,
      queryParameters: {'name': name},
    );

    final data = response.data as List<dynamic>;
    return data.map((json) => Animal.fromJson(json)).toList();
  }
}
