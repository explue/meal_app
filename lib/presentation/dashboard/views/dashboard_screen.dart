import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/dashboard_provider.dart';
import 'category_tab_view.dart';
import 'meal_planner_tab_view.dart';
import 'shopping_list_tab_view.dart';
// 🎯 방 탈출 후 돌아갈 온보딩 게이트웨이 화면 임포트
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

  // 🎯 방 나가기 확인 팝업 및 탈출 로직 엔진
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🚪 방 나가기', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          '현재 방에서 정말로 나가시겠습니까?\n(로컬 정보만 초기화되며 방의 요리 데이터는 그대로 유지됩니다.)', 
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.5)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // 1. 팝업창 닫기
              Navigator.pop(ctx);
              
              // TODO: 추후 Provider에서 관리하는 로컬 토큰(방 번호, 닉네임) 초기화 로직이 들어갈 자리입니다.
              
              // 2. 대시보드를 완전히 파괴하고 게이트웨이 화면으로 깔끔하게 복귀
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const GatewayScreen()),
                (route) => false, // 뒤로가기 스택을 0으로 만들어버림
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
            title: Text(room.roomName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            // 🎯 우측 상단 '방에서 나오기' 탈출구 액션 버튼 장착
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