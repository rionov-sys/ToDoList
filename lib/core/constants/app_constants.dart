class AppConstants {
  static const String appName = 'Chronos';
  static const String appTagline = 'Kinetic Focus OS & Timeline Tracking';
  
  // API Configuration
  static const String baseUrl = 'https://api.chronos.studio.id/api/v1';
  static const int connectTimeout = 15000; // ms
  static const int receiveTimeout = 15000; // ms

  // Local Storage Keys
  static const String keyAccessToken = 'chronos_access_token';
  static const String keyRefreshToken = 'chronos_refresh_token';
  static const String keyUserData = 'chronos_user_data';
  static const String keyTasksCache = 'chronos_tasks_cache';
  static const String keyOfflineQueue = 'chronos_offline_queue';
  static const String keyDarkMode = 'chronos_dark_mode';
  static const String keyAutoSync = 'chronos_auto_sync';

  // Demo / Initial User Data
  static const String defaultEmail = 'alex.kusuma@chronos.io';
  static const String defaultName = 'Alex Kusuma';
  static const String defaultAvatar = 'AK';
  static const String defaultTimezone = 'Asia/Jakarta (WIB • UTC+7)';
}
