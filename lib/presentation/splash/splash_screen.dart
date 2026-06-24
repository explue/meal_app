import 'package:flutter/material.dart';
import '../auth/gateway_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // 1. 블러에서 선명해지기 시작 (0.5초 대기)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _opacity = 1.0);

    // 2. 선명한 상태 유지 (1.5초)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // 3. 다시 블러로 바뀌며 게이트웨이로 전환 (화면 전환 효과)
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (c) => const GatewayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // 베이지색 배경
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎯 1번 명세: 로고를 큼직하게 배치 (스플래시 전용 크기)
              Image.asset('assets/app_logo.jpg', width: 256), 
              const SizedBox(height: 24),
              const Text(
                '다함께, 즐겁게, 맛있게',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF4E342E)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}