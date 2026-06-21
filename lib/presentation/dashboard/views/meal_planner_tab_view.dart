import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/meal_room.dart';
import '../controllers/dashboard_provider.dart';
import '../widgets/wish_board_widget.dart';

class MealPlannerTabView extends ConsumerStatefulWidget {
  final MealRoom room;
  final String appLang;

  const MealPlannerTabView({super.key, required this.room, required this.appLang});

  @override
  ConsumerState<MealPlannerTabView> createState() => _MealPlannerTabViewState();
}

class _MealPlannerTabViewState extends ConsumerState<MealPlannerTabView> {
  final TextEditingController _wishController = TextEditingController();

  @override
  void dispose() {
    _wishController.dispose();
    super.dispose();
  }

  void _showMenuEditDialog(String day, Map<String, dynamic> meal) {
    final controller = ref.read(dashboardControllerProvider);
    final String menuName = meal['menu_name'] ?? '지정된 메뉴 없음';
    final List<dynamic> rawIngs = meal['ingredients'] ?? [];
    
    List<Map<String, dynamic>> tempIngs = List<Map<String, dynamic>>.from(rawIngs);
    final TextEditingController newIngController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('$day - $menuName', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('식단 포함 재료 편집', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newIngController,
                        decoration: const InputDecoration(hintText: '재료 직접 추가', isDense: true),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFFFF8A65)),
                      onPressed: () {
                        if (newIngController.text.trim().isNotEmpty) {
                          setDialogState(() {
                            tempIngs.add({'name': newIngController.text.trim(), 'amount': '적당량'});
                          });
                          newIngController.clear();
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tempIngs.length,
                    itemBuilder: (c, i) => ListTile(
                      dense: true,
                      title: Text(tempIngs[i]['name'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => setDialogState(() => tempIngs.removeAt(i)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('나가기')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
              onPressed: () async {
                await controller.updateMealScheduleIngredients(widget.room, day, tempIngs);
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('수정 완료', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(dashboardControllerProvider);
    final currentNick = ref.watch(currentUserNicknameProvider);
    final schedule = widget.room.weeklySchedule ?? {};
    final days = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                WishBoardWidget(
                  room: widget.room, 
                  currentNick: currentNick, 
                  wishController: _wishController
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8
                    ),
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final meal = schedule[day] ?? {'menu_name': '식단 없음', 'ingredients': []};
                      
                      return InkWell(
                        onTap: () => _showMenuEditDialog(day, meal),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFE0B2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // 🛠️ 오타 완전 수정 완료 슬롯
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A65))),
                              const SizedBox(height: 4),
                              Text(
                                meal['menu_name'] ?? '식단 없음', 
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                              ),
                              Text(
                                '재료 ${meal['ingredients']?.length ?? 0}종', 
                                style: const TextStyle(fontSize: 11, color: Colors.grey)
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => controller.confirmWeeklyScheduleToCart(widget.room),
                  child: const Text('이번 주 식단 확정 및 장보기 전송', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => controller.resetWishMenus(widget.room),
                  child: const Text('위시 메뉴 및 게시판 초기화'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}