import 'dart:developer' as dev;

import 'package:omkar_sale/core/app/all_import_file.dart';

class ApiException extends Equatable implements Exception {
  const ApiException({
    required this.errorMessageKey,
    this.type = CustomErrorType.generalError,
    this.errorCode = -1,
  });
  final String errorMessageKey;
  final int? errorCode;
  final CustomErrorType type;

  @override
  String toString() => errorMessageKey;

  @override
  List<Object?> get props => [errorMessageKey, errorCode, type];

  ApiException copyWith({
    String? errorMessageKey,
    int? errorCode,
    CustomErrorType? type,
  }) {
    return ApiException(
      errorMessageKey: errorMessageKey ?? this.errorMessageKey,
      errorCode: errorCode ?? this.errorCode,
      type: type ?? this.type,
    );
  }
}

class Api {
  Api._();
  static final Api instance = Api._();

  Map<String, dynamic> headers() {
    final jwtToken = AuthLocalRepository.instance.getJwtToken();
    if (kDebugMode) {
      print('token is $jwtToken');
    }
    return {'Authorization': 'Bearer $jwtToken'};
  }

  // ... other imports

  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> parameter,
    required bool useAuthToken,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // Using ListFormat.multiCompatible helps with the location[0][latitude] structure
      final formData = FormData.fromMap(parameter, ListFormat.multiCompatible);

      final response = await dio.post<Map<String, dynamic>>(
        url,
        data: formData,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      return Map.from(response.data!);
    } on DioException catch (e, st) {
      // Log the actual error for debugging
      dev.log('Dio Post Error Type: ${e.type} $st');

      // 1. Handle 500 errors
      if (e.response?.statusCode == 500) {
        throw const ApiException(errorMessageKey: 'internalServerErrorLbl');
      }

      // 2. Handle Connection/Internet Errors
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.error is SocketException) {
        throw const ApiException(
          errorMessageKey: 'noInternetFoundLbl',
          type: CustomErrorType.noInternet,
        );
      }

      // 3. Handle Server Responses (400, 401, 422 etc.)
      final serverResponse = e.response?.data;
      var errorMessage = 'somethingWentWrongLbl';

      // Extract the specific message from the API response if it exists
      if (serverResponse is Map && serverResponse.containsKey('message')) {
        errorMessage = serverResponse['message'].toString();
      }

      throw ApiException(
        errorMessageKey: errorMessage,
        errorCode: e.response?.statusCode ?? 0,
      );
    } on ApiException catch (e) {
      // Rethrow custom API exceptions
      rethrow;
    } catch (e) {
      // Catch any other random exceptions
      throw const ApiException(errorMessageKey: 'somethingWentWrongLbl');
    }
  }

  // static Future<Map<String, dynamic>> post({required String url, required Map<String, dynamic> parameter, required bool useAuthToken}) async {
  //   try {
  //     final dio = Dio();
  //     final formData = FormData.fromMap(parameter, ListFormat.multiCompatible);
  //     final response = await dio.post<Map<String, dynamic>>(
  //       url,
  //       data: formData,
  //       options: useAuthToken ? Options(headers: headers()) : null,
  //     );
  //     return Map.from(response.data!);
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 500) {
  //       throw ApiException(errorMessageKey: 'internalServerError');
  //     }
  //     throw ApiException(
  //       errorMessageKey: e.error is SocketException ? 'noInternetFound' : 'somethingWentWrong',
  //       type: e.error is SocketException ? CustomErrorType.noInternet : CustomErrorType.generalError,
  //       errorCode: e.response?.statusCode ?? 0,
  //     );
  //   } on ApiException catch (e) {
  //     throw ApiException(errorMessageKey: e.errorMessageKey);
  //   } on Exception catch (_) {
  //     throw ApiException(errorMessageKey: 'somethingWentWrong');
  //   }
  // }

  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool useAuthToken = false,
  }) async {
    try {
      final dio = Dio();
      final response = await dio.get<Map<String, dynamic>>(
        url,
        queryParameters: queryParameters,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      return Map.from(response.data!);
    } on DioException catch (e, st) {
      // Log the actual error type for debugging
      dev.log('Dio Error Type: ${e.type} $st');

      // Handle 500 errors
      if (e.response?.statusCode == 500) {
        throw const ApiException(errorMessageKey: 'internalServerErrorLbl');
      }

      // 1. Handle Connection/Internet Errors
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.error is SocketException) {
        throw const ApiException(
          errorMessageKey: 'noInternetFoundLbl',
          type: CustomErrorType.noInternet,
        );
      }

      // 2. Handle Server Responses (400, 401, 404 etc.)
      final serverResponse = e.response?.data;
      var errorMessage = 'somethingWentWrongLbl';

      if (serverResponse is Map && serverResponse.containsKey('message')) {
        errorMessage = serverResponse['message'].toString();
      }

      throw ApiException(
        errorMessageKey: errorMessage,
        errorCode: e.response?.statusCode ?? 0,
      );
    } catch (e) {
      // Catch any other random exceptions
      throw const ApiException(errorMessageKey: 'somethingWentWrongLbl');
    }
  }

  Future<Map<String, dynamic>> patch({
    required String url,
    required Map<String, dynamic> parameter,
    required bool useAuthToken,
  }) async {
    try {
      final dio = Dio();

      // Using ListFormat.multiCompatible as used in your post method for consistency
      final formData = FormData.fromMap(parameter, ListFormat.multiCompatible);

      final response = await dio.patch<Map<String, dynamic>>(
        url,
        data: formData,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      return Map.from(response.data!);
    } on DioException catch (e, st) {
      dev.log('Dio Patch Error Type: ${e.type} $st');

      if (e.response?.statusCode == 500) {
        throw const ApiException(errorMessageKey: 'internalServerErrorLbl');
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.error is SocketException) {
        throw const ApiException(
          errorMessageKey: 'noInternetFoundLbl',
          type: CustomErrorType.noInternet,
        );
      }

      final serverResponse = e.response?.data;
      var errorMessage = 'somethingWentWrongLbl';

      if (serverResponse is Map && serverResponse.containsKey('message')) {
        errorMessage = serverResponse['message'].toString();
      }

      throw ApiException(
        errorMessageKey: errorMessage,
        errorCode: e.response?.statusCode ?? 0,
      );
    } on ApiException {
      // Rethrow custom API exceptions
      rethrow;
    } catch (e) {
      // Catch any other random exceptions
      throw const ApiException(errorMessageKey: 'somethingWentWrongLbl');
    }
  }
  // static Future<Map<String, dynamic>> get({required String url, Map<String, dynamic>? queryParameters, bool useAuthToken = false}) async {
  //   try {
  //     final dio = Dio();

  //     final response = await dio.get<Map<String, dynamic>>(
  //       url,
  //       queryParameters: queryParameters,
  //       options: useAuthToken ? Options(headers: headers()) : null,
  //     );

  //     return Map.from(response.data!);
  //   } on DioException catch (e, st) {
  //     dev.log('error $e $st');

  //     if (e.response?.statusCode == 500) {
  //       throw ApiException(errorMessageKey: 'internalServerError');
  //     }
  //     dev.log('throwing exception ${e.response}');
  //     final serverResponse = e.response?.data;
  //     var errorMessage = 'somethingWentWrong';

  //     if (e.error is SocketException) {
  //       errorMessage = 'noInternetFound';
  //     } else if (serverResponse is Map && serverResponse.containsKey('message')) {
  //       // This captures your "Token is Invalid" message
  //       errorMessage = serverResponse['message'].toString();
  //     }

  //     throw ApiException(
  //       errorMessageKey: errorMessage,
  //       type: e.error is SocketException ? CustomErrorType.noInternet : CustomErrorType.generalError,
  //       errorCode: e.response?.statusCode ?? 0,
  //     );
  //   } on ApiException catch (e) {
  //     throw ApiException(errorMessageKey: e.errorMessageKey);
  //   } on Exception catch (_) {
  //     throw ApiException(errorMessageKey: 'somethingWentWrong');
  //   }
  // }

  Future<Map<String, dynamic>> delete({
    required String url,
    Map<String, dynamic>? data,
    bool useAuthToken = false,
  }) async {
    try {
      final dio = Dio();

      final response = await dio.delete<Map<String, dynamic>>(
        url,
        data: data != null ? FormData.fromMap(data) : null,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      return Map.from(response.data ?? {});
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw const ApiException(errorMessageKey: 'internalServerErrorLbl');
      }
      throw ApiException(
        errorMessageKey: e.error is SocketException
            ? 'noInternetFoundLbl'
            : 'somethingWentWrongLbl',
        type: e.error is SocketException
            ? CustomErrorType.noInternet
            : CustomErrorType.generalError,
      );
    } on ApiException catch (e) {
      throw ApiException(errorMessageKey: e.errorMessageKey);
    } on Exception catch (_) {
      throw const ApiException(errorMessageKey: 'somethingWentWrongLbl');
    }
  }

  Future<void> download({
    required String url,
    required CancelToken cancelToken,
    required String savePath,
    required Function(double) updateDownloadedPercentage,
    bool useAuthToken = false,
  }) async {
    try {
      final dio = Dio();

      final requestHeaders = useAuthToken ? headers() : <String, dynamic>{};
      requestHeaders['Accept'] = 'application/pdf';
      requestHeaders['Content-Type'] = 'application/pdf';

      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        options: Options(headers: requestHeaders),
        onReceiveProgress: (count, total) {
          if (total != -1) {
            updateDownloadedPercentage((count / total) * 100);
          } else {
            updateDownloadedPercentage(0);
          }
        },
      );
    } on DioException catch (e) {
      throw ApiException(
        errorMessageKey: e.error is SocketException
            ? 'noInternetFoundLbl'
            : 'somethingWentWrongLbl',
      );
    } on ApiException catch (e) {
      throw ApiException(errorMessageKey: e.errorMessageKey);
    } on Exception catch (_) {
      throw const ApiException(errorMessageKey: 'somethingWentWrongLbl');
    }
  }
}
