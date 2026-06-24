import 'package:flutter/material.dart';
import '../dashboard/views/dashboard_screen.dart';

class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), 
                  blurRadius: 20, 
                  offset: const Offset(0, 10)
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🎯 4번 명세: 첫 화면과 통일감을 주는 적당한 크기의 로고 배치
                Image.asset('assets/app_logo.jpg', width: 200),
                const SizedBox(height: 32),
                
                // 닉네임 라벨 (🎯 3번 명세: 검은색 글씨)
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text(
                    '내 별명 (닉네임)', 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)
                  )
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    // 🎯 3번 명세: 예시는 회색 글씨
                    hintText: '예: 엄마, 아빠, 자취대장',
                    hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 방 번호 라벨 (🎯 3번 명세: 검은색 글씨)
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text(
                    '공유받은 방 번호 (입장 시)', 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)
                  )
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _roomCodeController,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    // 🎯 3번 명세: 가이드는 회색 글씨
                    hintText: '숫자 6자리 입력',
                    hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.meeting_room_outlined, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),
                
                // 버튼 영역
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A65), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DashboardScreen())),
                    child: const Text('입력한 방으로 들어가기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF8A65), width: 1.5), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DashboardScreen())),
                    child: const Text('새로운 요리방 만들기', style: TextStyle(color: Color(0xFFFF8A65), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}