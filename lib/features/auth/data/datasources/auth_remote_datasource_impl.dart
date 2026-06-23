import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final result = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: <String, dynamic>{'email': email.trim(), 'password': password},
    );
    return result.fold(
      (failure) => throw ApiException(failure.message),
      UserModel.fromLoginResponse,
    );
  }
}
