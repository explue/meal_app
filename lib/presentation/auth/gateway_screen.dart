import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/controllers/dashboard_provider.dart';
import '../dashboard/views/dashboard_screen.dart';

class GatewayScreen extends ConsumerStatefulWidget {
  const GatewayScreen({super.key});

  @override
  ConsumerState<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends ConsumerState<GatewayScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  // 🎯 명세 완벽 반영: 방 개설 성공 시 정중앙에 띄워줄 전용 알림 다이얼로그
  void _showRoomCreatedDialog(String roomCode) {
    showDialog(
      context: context,
      barrierDismissible: false, // 무조건 버튼 눌러서 진입하도록 방어
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 요리방 개설 성공!', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '우리 가족 전용 요리방 코드가 발급되었습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF8A65), width: 2),
              ),
              child: Text(
                roomCode,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF8A65), letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '상단 방번호를 터치하면 언제든 복사하여\n가족들에게 전달할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF424242), height: 1.4),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx); // 팝업 닫기
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const DashboardScreen()),
                );
              },
              child: const Text('요리방 입장하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleRoomAction(String actionType) async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      _showSimpleAlert('알림', '사용하실 별명(닉네임)을 먼저 입력해주세요!');
      return;
    }

    setState(() => _isLoading = true);
    final controller = ref.read(dashboardControllerProvider);

    try {
      await controller.saveUserNickname(nickname);
      String targetRoomId = "";

      if (actionType == 'create') {
        targetRoomId = await controller.createNewRoom('$nickname의 요리방');
        setState(() => _isLoading = false);
        if (!mounted) return;
        // 🎯 개설 성공 팝업창 호출 (여기서 입장 처리 유도)
        _showRoomCreatedDialog(targetRoomId);
      } else {
        targetRoomId = _roomCodeController.text.trim();
        if (targetRoomId.isEmpty) {
          _showSimpleAlert('알림', '입장하실 방 번호를 입력해주세요!');
          setState(() => _isLoading = false);
          return;
        }

        final bool isExists = await controller.verifyRoomExists(targetRoomId);
        if (!isExists) {
          _showSimpleAlert('입장 실패', '❌ 존재하지 않는 방 번호입니다.\n다시 확인해 주세요.');
          setState(() => _isLoading = false);
          return;
        }

        ref.read(currentRoomIdProvider.notifier).state = targetRoomId;
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const DashboardScreen()),
        );
      }
    } catch (e) {
      _showSimpleAlert('오류', '통신 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted && actionType != 'create') setState(() => _isLoading = false);
    }
  }

  // 단순 안내 팝업창
  void _showSimpleAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인', style: TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
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
                Image.asset('assets/app_logo.jpg', width: 200),
                const SizedBox(height: 32),
                
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text('내 별명 (닉네임)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14))
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  enabled: !_isLoading,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '예: 엄마, 아빠, 자취대장',
                    hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text('공유받은 방 번호 (입장 시)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14))
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _roomCodeController,
                  enabled: !_isLoading,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '숫자 6자리 입력',
                    hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.meeting_room_outlined, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),
                
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8A65)))
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8A65), 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                              onPressed: () => _handleRoomAction('enter'),
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
                              onPressed: () => _handleRoomAction('create'),
                              child: const Text('새로운 요리방 만들기', style: TextStyle(color: Color(0xFFFF8A65), fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}