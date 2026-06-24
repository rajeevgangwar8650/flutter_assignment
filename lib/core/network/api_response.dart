import '../errors/failures.dart';

class NetworkResult<T> {
  final T? data;
  final Failure? failure;

  const NetworkResult._({this.data, this.failure});

  factory NetworkResult.success(T data) => NetworkResult._(data: data);

  factory NetworkResult.failure(Failure failure) =>
      NetworkResult._(failure: failure);

  bool get isSuccess => failure == null;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    final currentFailure = failure;
    final currentData = data;
    if (currentFailure != null) return onFailure(currentFailure);
    return onSuccess(currentData as T);
  }
}
