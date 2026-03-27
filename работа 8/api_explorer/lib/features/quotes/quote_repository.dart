import '../../core/dio_client.dart';
import '../../core/api_constants.dart';
import 'quote_model.dart';

class QuoteRepository {
  final DioClient _client;

  QuoteRepository(this._client);

  Future<List<Quote>> getQuotes({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }

    final response = await _client.dio.get(
      ApiConstants.quotes,
      queryParameters: params,
    );

    final data = response.data as List<dynamic>;
    return data.map((json) => Quote.fromJson(json)).toList();
  }

  static const categories = [
    'age',
    'beauty',
    'business',
    'change',
    'courage',
    'education',
    'experience',
    'failure',
    'faith',
    'friendship',
    'future',
    'happiness',
    'health',
    'humor',
    'inspirational',
    'intelligence',
    'knowledge',
    'leadership',
    'life',
    'love',
    'money',
    'success',
    'technology',
    'wisdom',
  ];
}
