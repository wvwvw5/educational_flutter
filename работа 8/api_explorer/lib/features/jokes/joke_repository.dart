import '../../core/dio_client.dart';
import '../../core/api_constants.dart';
import 'joke_model.dart';

class JokeRepository {
  final DioClient _client;

  JokeRepository(this._client);

  Future<Joke> getRandomJoke() async {
    final response = await _client.dio.get(ApiConstants.jokes);
    final data = response.data as List<dynamic>;
    return Joke.fromJson(data.first);
  }
}
