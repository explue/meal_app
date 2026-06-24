import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/splash/splash_screen.dart'; // 🎯 경로 오류 없는 표준 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 오리지널 Firebase Options 설정 완벽 보존
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyANCzStz-x9xemPNXhCzjwikPaWohgiWdo",
      authDomain: "our-home-meal-ap.firebaseapp.com",
      projectId: "our-home-meal-ap",
      storageBucket: "our-home-meal-ap.firebasestorage.app",
      messagingSenderId: "3549523243",
      appId: "1:3549523243:web:0f3d5b5d397317d824e96e",
    ),
  );

  runApp(
    const ProviderScope(
      child: SoftMealApp(),
    ),
  );
}

class SoftMealApp extends StatelessWidget {
  const SoftMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = AppTheme.lightTheme;

    return MaterialApp(
      title: 'Happy Table',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          bodyColor: const Color(0xFF424242),
          displayColor: const Color(0xFF424242),
        ).copyWith(
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          labelLarge: baseTheme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      home: const SplashScreen(), // 🎯 여기서 수정된 SplashScreen을 호출합니다.
    );
  }
}