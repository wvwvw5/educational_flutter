import 'package:dio/dio.dart';
import 'api_constants.dart';

/// Interceptor that automatically adds the API token to every request header.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Api-Key'] = ApiConstants.apiKey;
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      err = DioException(
        requestOptions: err.requestOptions,
        error: 'Invalid API key. Please check your API-Ninjas token.',
        type: DioExceptionType.badResponse,
        response: err.response,
      );
    }
    handler.next(err);
  }
}
