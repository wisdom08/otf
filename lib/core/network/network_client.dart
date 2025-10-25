import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/failures.dart';

class NetworkClient {
  late final Dio _dio;

  NetworkClient() {
    _dio = Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('Headers: ${options.headers}');
            print('Data: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
            print('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print(
              'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            );
            print('Message: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // GET 요청
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST 요청
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT 요청
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE 요청
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure('요청 시간이 초과되었습니다.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return const AuthFailure('인증이 필요합니다.');
        } else if (statusCode == 403) {
          return const PermissionFailure('접근 권한이 없습니다.');
        } else if (statusCode == 404) {
          return const ServerFailure('요청한 리소스를 찾을 수 없습니다.');
        } else if (statusCode! >= 500) {
          return const ServerFailure('서버 오류가 발생했습니다.');
        }
        return ServerFailure('서버 오류: ${error.response?.statusMessage}');
      case DioExceptionType.cancel:
        return const NetworkFailure('요청이 취소되었습니다.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('인터넷 연결을 확인해주세요.');
      default:
        return NetworkFailure('네트워크 오류: ${error.message}');
    }
  }
}
