import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/dashboard_provider.dart';
import 'category_tab_view.dart';
import 'meal_planner_tab_view.dart';
import 'shopping_list_tab_view.dart';
import '../../auth/gateway_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🎯 명세 완벽 반영: 방 나가기 팝업처럼 정중앙에 나타나는 복사 성공 알림창 (1.5초 후 자동 소멸)
  void _copyRoomCode(String roomCode) {
    Clipboard.setData(ClipboardData(text: roomCode));
    
    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 누르면 닫히기 가능
      builder: (ctx) {
        // 1.5초 뒤에 자동으로 팝업을 닫아주는 안전 타이머 가동
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (ctx.mounted) Navigator.pop(ctx);
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.check_circle, color: Color(0xFFFF8A65), size: 50),
              const SizedBox(height: 16),
              const Text(
                '방 번호 복사 완료!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 12),
              Text(
                '[$roomCode]\n\n카톡이나 문자에 붙여넣어\n가족들에게 공유해 보세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF424242), height: 1.4),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // 방 나가기 확인 팝업
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🚪 방 나가기', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          '현재 방에서 정말로 나가시겠습니까?\n(방의 요리 데이터는 파이어베이스에 그대로 유지됩니다.)', 
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.5)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(dashboardControllerProvider).leaveRoom(ref.read(currentRoomIdProvider));
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const GatewayScreen()),
                (route) => false,
              );
            },
            child: const Text('나가기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomId = ref.watch(currentRoomIdProvider);
    final appLang = ref.watch(currentLanguageProvider);
    final roomAsync = ref.watch(mealRoomStreamProvider(roomId));

    return roomAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('방 데이터를 불러오지 못했습니다: $err'))),
      data: (room) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF4E342E),
            elevation: 0,
            title: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  room.roomName, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8), 
                InkWell(
                  onTap: () => _copyRoomCode(room.roomId),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          room.roomId,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                tooltip: '방에서 나가기',
                onPressed: () => _showExitConfirmation(context),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF8A65),
              unselectedLabelColor: Colors.white70,
              indicatorColor: const Color(0xFFFF8A65),
              tabs: const [
                Tab(icon: Icon(Icons.restaurant), text: '요리방'),
                Tab(icon: Icon(Icons.calendar_month), text: '식단표'),
                Tab(icon: Icon(Icons.shopping_bag), text: '장보기'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              CategoryTabView(room: room, appLang: appLang),
              MealPlannerTabView(room: room, appLang: appLang),
              ShoppingListTabView(room: room, appLang: appLang),
            ],
          ),
        );
      },
    );
  }
}