import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/splash/splash_screen.dart';

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

  // ⚡ 클린 아키텍처 및 Riverpod 정상 작동을 위해 ProviderScope로 랩핑
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
    return MaterialApp(
      title: 'Happy Table',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // 분리 정돈된 글로벌 테마 적용
      home: const SplashScreen(), // 리팩토링된 첫 진입 스플래시 화면 지정
    );
  }
}