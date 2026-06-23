
class ApiResponse<T> {
  final bool? status;
  final String? msg;
  final String? statusCode;
  final T? response;

  ApiResponse(this.status, {this.msg = 'Success', this.statusCode, this.response});
}