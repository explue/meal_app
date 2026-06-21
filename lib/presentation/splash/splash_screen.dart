import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/controllers/dashboard_provider.dart';
import '../dashboard/views/dashboard_screen.dart';
import '../language/language_select_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animateAndNavigate();
  }

  Future<void> _animateAndNavigate() async {
    // 1. 애니메이션 연출 (텍스트 페이드인)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _textOpacity = 1.0;
    });

    // 스플래시 대기 시간
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // 2. 백엔드 마스터 세션 엔진 검수 작동 (청정 단독 호출 분기)
    await ref.read(dashboardControllerProvider).initAppSession();
    const bool isSessionExists = true; 

    if (isSessionExists) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DashboardScreen()));
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LanguageSelectScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4E342E),
      body: Center(
        child: AnimatedOpacity(
          opacity: _textOpacity,
          duration: const Duration(milliseconds: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 64, color: Color(0xFFFF8A65)),
              const SizedBox(height: 24),
              Text(
                widget.runtimeType.toString() == 'SplashScreen' ? '행복한 식탁' : 'Happy Table',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}