import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure toFailure(dynamic error) {
    if (error is Failure) return error;

    if (error is ApiException || error is ServerException) {
      return ServerFailure(error.toString());
    }

    if (error is CacheException) {
      return CacheFailure(error.message);
    }

    if (error is DioException) {
      return NetworkFailure(_dioMessage(error));
    }

    return UnknownFailure(getMessage(error));
  }

  static String getMessage(dynamic error) {
    if (error is AppException) return error.message;
    if (error is DioException) return _dioMessage(error);
    return error.toString();
  }

  static String _dioMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.sendTimeout => 'Request timed out.',
      DioExceptionType.receiveTimeout => 'Response timed out.',
      DioExceptionType.badResponse => 'Server returned an invalid response.',
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.connectionError => 'No internet connection.',
      DioExceptionType.badCertificate => 'Unable to verify server certificate.',
      DioExceptionType.unknown => 'Something went wrong. Please try again.',
    };
  }
}
