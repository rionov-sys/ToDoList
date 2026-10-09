import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation & status bar transparent and crisp
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Core Services
  final localStorage = LocalStorageService();
  await localStorage.init();

  final apiClient = ApiClient();

  runApp(
    ChronosApp(
      localStorageService: localStorage,
      apiClient: apiClient,
    ),
  );
}
