import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/log_util.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  ApiClient._internal() {
    _dio = Dio();
    _setupInterceptors();
  }

  late final Dio _dio;
  String? _baseUrl;
  String? _authToken;

  /// Dio 클라이언트 가져오기
  Dio get client => _dio;

  /// API 클라이언트 초기화
  Future<void> initialize() async {
    await dotenv.load();
    // _baseUrl = dotenv.env['https://trip-craft-jin.vercel.app'];
    _baseUrl = 'https://trip-craft-jin.vercel.app';

    if (_baseUrl != null) {
      _dio.options.baseUrl = _baseUrl!;
    }

    _dio.options.connectTimeout = const Duration(minutes: 10);
    _dio.options.receiveTimeout = const Duration(minutes: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// 인터셉터 설정
  void _setupInterceptors() {
    // 요청 인터셉터
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 인증 토큰이 있으면 헤더에 추가
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          // 요청 로그 출력
          LogUtil.logRequest(
            options.method,
            '${options.baseUrl}${options.path}',
            params: options.queryParameters,
            data: options.data,
          );

          handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 로그 출력
          LogUtil.logResponse(
            response.statusCode ?? 0,
            response.requestOptions.path,
            response.data,
          );

          handler.next(response);
        },
        onError: (error, handler) {
          // 에러 로그 출력
          LogUtil.logError(
            'API 호출 실패: ${error.requestOptions.method} ${error.requestOptions.path}',
            error: error.message,
            tag: 'API_ERROR',
          );

          if (error.response != null) {
            LogUtil.logJson(error.response?.data,
                tag: 'API_ERROR', prefix: '오류 응답');
          }

          handler.next(error);
        },
      ),
    );
  }

  /// 인증 토큰 설정
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// 인증 토큰 제거
  void clearAuthToken() {
    _authToken = null;
  }

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
