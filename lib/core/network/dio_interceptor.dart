import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/logger_service.dart';

class AppLoggingInterceptor extends Interceptor {
  final LoggerService logger;

  AppLoggingInterceptor({required this.logger});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.log('${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.log('${response.statusCode} ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.log('Dio error: ${err.message}');
    super.onError(err, handler);
  }
}

class AppErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('Network error: ${err.requestOptions.uri} ${err.message}');
    }
    super.onError(err, handler);
  }
}