import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/body_measurement_provider.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set initial system-UI overlay to match the FitFudge brand background
  // (#110C08) so there is no colour flash before the first Flutter frame.
  // The AppBarTheme in app_theme.dart keeps this correct during the app run.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,   // Android — light icons on dark bg
      statusBarBrightness: Brightness.dark,         // iOS     — light icons on dark bg
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: AppColors.border,
    ),
  );

  // Lock to portrait + landscape (allow both; individual screens can override).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const FitFudgeApp());
}

class FitFudgeApp extends StatelessWidget {
  const FitFudgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => BodyMeasurementProvider()),
      ],
      child: MaterialApp(
        title: 'FitFudge',
        debugShowCheckedModeBanner: false,
        // Single branded dark theme — applied on both Android and iOS.
        theme: AppTheme.darkTheme,
        // Use the same theme for dark-mode OS requests; we always show dark.
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
