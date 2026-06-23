import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/error_handler.dart';
import '../errors/exceptions.dart';
import 'api_response.dart';
import 'dio_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  static Dio createDio({
    required AppLoggingInterceptor loggingInterceptor,
    required AppErrorInterceptor errorInterceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      loggingInterceptor,
      errorInterceptor,
    ]);
    return dio;
  }

  Future<NetworkResult<T>> get<T>(
      String path, {
        T Function(dynamic data)? decoder,
        Map<String, dynamic>? queryParameters,
      }) async {
    return _request<T>(
          () => dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      ),
      decoder: decoder,
    );
  }

  Future<NetworkResult<T>> post<T>(
      String path, {
        Object? data,
        T Function(dynamic data)? decoder,
      }) async {
    return _request<T>(
          () =>
      _handleMockRequest(path, data) ?? dio.post<dynamic>(path, data: data),
      decoder: decoder,
    );
  }

  Future<NetworkResult<T>> _request<T>(
      Future<Response<dynamic>> Function() request, {
        T Function(dynamic data)? decoder,
      }) async {
    try {
      final response = await request();

      final responseData = decoder == null
          ? response.data as T
          : decoder(response.data);

      return NetworkResult.success(responseData);
    } catch (error) {
      return NetworkResult.failure(ErrorHandler.toFailure(error));
    }
  }

  Future<Response<dynamic>>? _handleMockRequest(String path, Object? data) {
    if (path != ApiConstants.login) return null;

    return Future<Response<dynamic>>(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));

      final payload = data is Map ? data : const <String, dynamic>{};
      final email = (payload['email'] as String? ?? '').trim();
      final password = payload['password'] as String? ?? '';

      if (email.toLowerCase() == 'fail@example.com' ||
          password.toLowerCase() == 'invalid') {
        throw const ApiException(
          'Invalid email or password.',
          statusCode: 401,
        );
      }

      final name = _nameFromEmail(email);

      return Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: <String, dynamic>{
          'token': 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
          'user': <String, dynamic>{
            'id': '1',
            'name': name,
            'email': email,
            'bio': 'Building flutter project',
          },
        },
      );
    });
  }

  String _nameFromEmail(String email) {
    final prefix = email.split('@').first.trim();

    if (prefix.isEmpty) return 'Flutter User';

    return prefix
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

typedef DioClient = ApiClient;