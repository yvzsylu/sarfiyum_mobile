import 'package:dio/dio.dart';
import '../models/service_result.dart';
// 🔥 YENİ SERVİSİ EKLEDİK
import 'package:sarfiyum_mobile/services/secure_storage_service.dart';

class BaseApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://sarfiyum.com/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  // Eski storage nesnesine gerek kalmadı, servisten çekeceğiz.
  // final _storage = const FlutterSecureStorage();

  BaseApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 🔥 DEĞİŞİKLİK BURADA: Token'ı merkezi servisten alıyoruz.
          // Böylece AuthProvider'ın kaydettiği token'ı kesin buluruz.
          final token = await SecureStorageService().getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  // 👇 AŞAĞISINA DOKUNMADIM, AYNI KALACAK 👇

  Future<ServiceResult<T>> put<T>(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put("/$endpoint", data: data);
      return _processResponse(response, null);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ServiceResult(
        isSuccess: false,
        errors: [e.toString()],
        statusCode: 500,
      );
    }
  }

  Future<ServiceResult<T>> delete<T>(String endpoint) async {
    try {
      final response = await _dio.delete("/$endpoint");
      return _processResponse(response, null);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ServiceResult(
        isSuccess: false,
        errors: [e.toString()],
        statusCode: 500,
      );
    }
  }

  Future<ServiceResult<T>> patch<T>(String endpoint, dynamic data) async {
    try {
      final response = await _dio.patch("/$endpoint", data: data);
      return _processResponse(response, null);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ServiceResult(
        isSuccess: false,
        errors: [e.toString()],
        statusCode: 500,
      );
    }
  }

  Future<ServiceResult<T>> get<T>(
    String endpoint, {
    T Function(Object?)? fromJson,
  }) async {
    try {
      final response = await _dio.get("/$endpoint");
      return _processResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ServiceResult(
        isSuccess: false,
        errors: [e.toString()],
        statusCode: 500,
      );
    }
  }

  Future<ServiceResult<T>> post<T>(
    String endpoint,
    dynamic data, {
    T Function(Object?)? fromJson,
  }) async {
    try {
      final response = await _dio.post("/$endpoint", data: data);
      return _processResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ServiceResult(
        isSuccess: false,
        errors: [e.toString()],
        statusCode: 500,
      );
    }
  }

  // Cevabı İşleyen Ortak Fonksiyon
  ServiceResult<T> _processResponse<T>(
    Response response,
    T Function(Object?)? fromJson,
  ) {
    if (response.data != null && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;

      if (json['isSuccess'] == false ||
          (json['errors'] != null && (json['errors'] as List).isNotEmpty)) {
        return ServiceResult.fromJson(json, (data) => data as T);
      }

      return ServiceResult.fromJson(json, fromJson);
    }

    return ServiceResult<T>(
      isSuccess: false,
      statusCode: response.statusCode ?? 500,
      errors: ["Sunucudan geçersiz veri formatı geldi."],
    );
  }

  ServiceResult<T> _handleError<T>(DioException e) {
    List<String> errors = [];
    String defaultError = "Bağlantı hatası oluştu.";

    if (e.response != null && e.response?.data != null) {
      try {
        final data = e.response!.data;

        if (data is Map<String, dynamic>) {
          if (data['errors'] != null) {
            if (data['errors'] is List) {
              errors = List<String>.from(data['errors']);
            } else if (data['errors'] is String) {
              errors.add(data['errors']);
            }
          } else if (data['message'] != null) {
            errors.add(data['message']);
          }
        } else if (data is String) {
          errors.add(data);
        }
      } catch (_) {
        errors.add(defaultError);
      }
    } else {
      errors.add(e.message ?? defaultError);
    }

    if (errors.isEmpty) errors.add("Bilinmeyen bir hata");

    return ServiceResult<T>(
      isSuccess: false,
      errors: errors,
      statusCode: e.response?.statusCode ?? 500,
    );
  }
}
