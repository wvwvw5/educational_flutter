import '../../core/dio_client.dart';
import '../../core/api_constants.dart';
import 'fact_model.dart';

class FactRepository {
  final DioClient _client;

  FactRepository(this._client);

  Future<Fact> getRandomFact() async {
    final response = await _client.dio.get(ApiConstants.facts);
    final data = response.data as List<dynamic>;
    return Fact.fromJson(data.first);
  }
}
