import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

class ApiClient {
  late final Dio _dio;
  String? _authToken;

  ApiClient({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
            receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Custom logging and error interceptor
          return handler.next(e);
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Dio get dio => _dio;

  Never throwFailureFromDio(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      throw const NetworkFailure();
    }

    final response = error.response;
    if (response != null) {
      final data = response.data;
      String message = 'Terjadi kesalahan pada server (${response.statusCode})';
      if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      }
      throw ServerFailure(message, statusCode: response.statusCode);
    }

    throw const ServerFailure('Tidak dapat terhubung ke server.');
  }
}
