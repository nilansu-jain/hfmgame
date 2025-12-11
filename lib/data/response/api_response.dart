import '../../utils/enums.dart';

class ApiResponse<T> {
  Status? status;
  T? data;
  String? message;

  ApiResponse(this.status,this.message,this.data);

  ApiResponse.loading()  : status = Status.loading;

  ApiResponse.error(this.message): status = Status.error;

  ApiResponse.completed(this.data) : status = Status.completed;

  @override
  String toString() {
    // TODO: implement toString
    return " Status :: $status \n Message :: $message \n Data :: $data";
  }
}