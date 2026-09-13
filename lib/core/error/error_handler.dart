import 'package:dio/dio.dart';
import 'package:creatify_mobile/core/error/error_model.dart';
import 'package:creatify_mobile/core/error/http_error_strings.dart';

class DioExceptions implements Exception {
  late String message;

  DioExceptions.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = HttpErrorStrings.operationCancelled;
        break;
      case DioExceptionType.connectionError:
        message = HttpErrorStrings.connectionTimeoutActive;
        break;
      case DioExceptionType.receiveTimeout:
        message = HttpErrorStrings.receiveTimeout;
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        message = HttpErrorStrings.sendTimeout;
        break;
      case DioExceptionType.unknown:
        if (dioError.error.toString().contains("SocketException")) {
          message = HttpErrorStrings.genericRes;
          break;
        }
        message = HttpErrorStrings.uknown;
        break;
      default:
        message = "Something Went Wrong. Please Try Again Later";
        break;
    }
  }
  String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return handleError(error);
      case 401:
        return error["message"];
      case 413:
        return "Request too large. Please try with a smaller file or input";
      case 422:
        return _handleValidationError(error);
      case 424:
        return error["message"];
      case 429:
        return error["message"];
      case 403:
        return _handleGenericError(error, "Access Denied");
      case 404:
        return _handleGenericError(error, "Resource Not Found");
      case 500:
        return _handleGenericError(error, "Internal Server Error");
      case 502:
        return "Bad Gateway";
      case 503:
        return "Service Unavailable, Please Try Again";
      case 504:
        return "Service Unavaiilable. Please Try Again Later";
      default:
        return "$statusCode: Oops Something Went Wrong";
    }
  }

  String _handleGenericError(dynamic error, String fallback) {
    if (error is Map && error["message"] != null) {
      return error["message"].toString();
    }
    return fallback;
  }

  String _handleValidationError(dynamic error) {
    if (error is Map && error["errors"] != null && error["errors"] is Map) {
      final Map<String, dynamic> errors = error["errors"];
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }
    return error is Map ? (error["message"]?.toString() ?? "Validation failed") : "Validation failed";
  }

  String handleError(dynamic error) {
    if (error is Map && error["errors"] != null) {
      FailureRes result = FailureRes.fromJson(Map<String, dynamic>.from(error));
      if (result.error.phoneNumber != null && result.error.phoneNumber!.isNotEmpty) {
        return result.error.phoneNumber.toString();
      } else if (result.error.message != null && result.error.message!.isNotEmpty) {
        return result.error.message.toString();
      } else if (result.error.email != null && result.error.email!.isNotEmpty) {
        return result.error.email.toString();
      } else if (result.error.firstName != null && result.error.firstName!.isNotEmpty) {
        return result.error.firstName.toString();
      } else if (result.error.lastName != null && result.error.lastName!.isNotEmpty) {
        return result.error.lastName.toString();
      } else if (result.err.isNotEmpty) {
        return result.err.toString();
      } else if (result.error.amount != null && result.error.amount!.isNotEmpty) {
        return result.error.amount.toString();
      } else if (result.error.transactionPin != null && result.error.transactionPin!.isNotEmpty) {
        return result.error.transactionPin.toString();
      } else if (result.error.username != null && result.error.username!.isNotEmpty) {
        return result.error.username.toString();
      } else if (result.error.password != null && result.error.password!.isNotEmpty) {
        return result.error.password.toString();
      } else if (result.error.code != null && result.error.code!.isNotEmpty) {
        return result.error.code.toString();
      } else if (result.error.token != null && result.error.token!.isNotEmpty) {
        return result.error.token.toString();
      } else if (result.error.recipient != null && result.error.recipient!.isNotEmpty) {
        return 'User does not Exist';
      } else if (result.message.isNotEmpty) {
        return result.message.toString();
      } else {
        return error["message"]?.toString() ?? "An error occurred";
      }
    } else {
      return error is Map ? (error["message"]?.toString() ?? "An error occurred") : "An error occurred";
    }
  }

  @override
  String toString() => message;
}
