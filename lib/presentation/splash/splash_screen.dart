import 'dart:ui';
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
  double _blurValue = 25.0;
  double _imageOpacity = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animateAndNavigate();
  }

  void _animateAndNavigate() async {
    // 1. 시네마틱 교차 디졸브 애니메이션 빌드업
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      _blurValue = 0.0;
      _imageOpacity = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _textOpacity = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // 2. 백엔드 마스터 세션 엔진 검수 작동
    final isSessionExists = await ref.read(dashboardControllerProvider).initAppSession();
    if (!mounted) return;

    if (isSessionExists) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DashboardScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LanguageSelectScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🛠️ 대책 완비: Cannot hit test 에러를 원천 차단하기 위해 스마트폰 화면의 명확한 크기를 계산하여 강제 주입
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경 애니메이션 공간 레이어
            AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _imageOpacity,
              child: Container(
                width: screenSize.width,
                height: screenSize.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.squarespace-cdn.com/content/v1/6763fb4e9c719e7db715ffca/baf718d0-08c3-4f9e-be42-59535f29910a/image_87f875.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // 블러 필터 레이어 크기 안전장치 결속
            if (_blurValue > 0.0)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _blurValue, sigmaY: _blurValue),
                  child: Container(color: Colors.transparent),
                ),
              ),

            // 중앙 타이틀 로고 슬롯
            AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _textOpacity,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 48, color: Color(0xFFFF8A65)),
                  SizedBox(height: 12),
                  Text(
                    'Happy Table',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4E342E), letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}