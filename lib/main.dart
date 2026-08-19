import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/health_storage_service.dart';
import 'features/home/screens/home_screen.dart';

/// Notificador reativo global de modo de tema para permitir alternar entre Sistema, Claro e Escuro.
final ValueNotifier<ThemeMode> appThemeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialMode = await HealthStorageService().getThemeMode();
  appThemeModeNotifier.value = initialMode;
  runApp(const HealthControlApp());
}

class HealthControlApp extends StatelessWidget {
  const HealthControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Health Control: Asma',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
