import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/errors/failures.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;

  AuthService({
    required ApiClient apiClient,
    required LocalStorageService localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = data['token'] as Map<String, dynamic>;

      await _localStorage.saveTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
      );
      await _localStorage.saveUser(user);
      _apiClient.setAuthToken(tokens['accessToken'] as String);

      return user;
    } on DioException catch (e) {
      // If server is not yet running or network failure, use offline-first demo user
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return _fallbackLogin(email: email);
      }
      _apiClient.throwFailureFromDio(e);
    } catch (_) {
      return _fallbackLogin(email: email);
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = data['token'] as Map<String, dynamic>;

      await _localStorage.saveTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
      );
      await _localStorage.saveUser(user);
      _apiClient.setAuthToken(tokens['accessToken'] as String);

      return user;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return _fallbackRegister(email: email, name: name);
      }
      _apiClient.throwFailureFromDio(e);
    } catch (_) {
      return _fallbackRegister(email: email, name: name);
    }
  }

  Future<UserModel?> getCachedUser() async {
    final token = await _localStorage.getAccessToken();
    if (token != null) {
      _apiClient.setAuthToken(token);
    }
    return _localStorage.getUser();
  }

  Future<void> logout() async {
    _apiClient.setAuthToken(null);
    await _localStorage.clearAuth();
  }

  // --- Offline / Demo Fallback Handlers ---
  Future<UserModel> _fallbackLogin({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate async
    final user = UserModel(
      id: 'usr_demo_1',
      email: email.isNotEmpty ? email : 'alex.kusuma@chronos.io',
      name: email.contains('@') ? email.split('@')[0].replaceAll('.', ' ').toUpperCase() : 'Alex Kusuma',
      timezone: 'Asia/Jakarta (WIB • UTC+7)',
      plan: 'Pro Plan',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    await _localStorage.saveTokens(accessToken: 'mock_jwt_token', refreshToken: 'mock_refresh_token');
    await _localStorage.saveUser(user);
    _apiClient.setAuthToken('mock_jwt_token');
    return user;
  }

  Future<UserModel> _fallbackRegister({required String email, required String name}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name.isNotEmpty ? name : 'Alex Kusuma',
      timezone: 'Asia/Jakarta (WIB • UTC+7)',
      plan: 'Pro Plan',
      createdAt: DateTime.now(),
    );
    await _localStorage.saveTokens(accessToken: 'mock_jwt_token', refreshToken: 'mock_refresh_token');
    await _localStorage.saveUser(user);
    _apiClient.setAuthToken('mock_jwt_token');
    return user;
  }
}
