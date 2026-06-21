import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/dashboard_provider.dart';
import 'category_tab_view.dart';
import 'meal_planner_tab_view.dart';
import 'shopping_list_tab_view.dart';

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