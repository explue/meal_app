import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/meal_room.dart';
import '../controllers/dashboard_provider.dart';
import '../widgets/wish_board_widget.dart';
import '../widgets/planner_day_card.dart';
import '../widgets/review_save_dialog.dart';

class MealPlannerTabView extends ConsumerStatefulWidget {
  final MealRoom room;
  final String appLang;

  const MealPlannerTabView({super.key, required this.room, required this.appLang});

  @override
  ConsumerState<MealPlannerTabView> createState() => _MealPlannerTabViewState();
}

class _MealPlannerTabViewState extends ConsumerState<MealPlannerTabView> {
  final TextEditingController _wishController = TextEditingController();
  final List<Map<String, String>> _daysOfWeek = [
    {'key': 'monday', 'label': '월요일'}, {'key': 'tuesday', 'label': '화요일'},
    {'key': 'wednesday', 'label': '수요일'}, {'key': 'thursday', 'label': '목요일'},
    {'key': 'friday', 'label': '금요일'}, {'key': 'saturday', 'label': '토요일'},
    {'key': 'sunday', 'label': '일요일'},
  ];

  final Map<String, Map<String, Map<String, dynamic>>> _localPlanState = {};

  @override
  void initState() {
    super.initState();
    for (var day in _daysOfWeek) {
      _localPlanState[day['key']!] = {
        'breakfast': {'status': 'menu', 'value': '', 'ingredients': <Map<String, String>>[]},
        'lunch': {'status': 'menu', 'value': '', 'ingredients': <Map<String, String>>[]},
        'dinner': {'status': 'menu', 'value': '', 'ingredients': <Map<String, String>>[]},
      };
    }
  }

  @override
  void dispose() {
    _wishController.dispose();
    super.dispose();
  }

  void _toggleSlotStatus(String dayKey, String mealKey) {
    setState(() {
      final current = _localPlanState[dayKey]![mealKey]!['status'];
      if (current == 'menu') {
        _localPlanState[dayKey]![mealKey]!['status'] = 'eat_out';
        _localPlanState[dayKey]![mealKey]!['value'] = '외식 또는 배달 🥡';
        _localPlanState[dayKey]![mealKey]!['ingredients'] = <Map<String, String>>[];
      } else if (current == 'eat_out') {
        _localPlanState[dayKey]![mealKey]!['status'] = 'skip';
        _localPlanState[dayKey]![mealKey]!['value'] = '식사 계획 없음 (패스) 💤';
        _localPlanState[dayKey]![mealKey]!['ingredients'] = <Map<String, String>>[];
      } else {
        _localPlanState[dayKey]![mealKey]!['status'] = 'menu';
        _localPlanState[dayKey]![mealKey]!['value'] = '';
        _localPlanState[dayKey]![mealKey]!['ingredients'] = <Map<String, String>>[];
      }
    });
  }

  void _generateAiDiet(String option) {
    final List<dynamic> masterPool = widget.room.masterRecommendPool;
    setState(() {
      int poolIdx = 0;
      List<String> wishPool = [];
      if (widget.room.wishMenuList != null) {
        wishPool = widget.room.wishMenuList!.map((e) => e['menu_name'] as String).toSet().toList();
      }

      for (var day in _daysOfWeek) {
        final dayKey = day['key']!;
        for (var mealKey in ['breakfast', 'lunch', 'dinner']) {
          if (_localPlanState[dayKey]![mealKey]!['status'] == 'menu') {
            String targetMenu = '';
            List<Map<String, String>> targetIngredients = [];

            if (wishPool.isNotEmpty) {
              targetMenu = wishPool.removeAt(0);
            } else if (masterPool.isNotEmpty) {
              final picked = masterPool[poolIdx % masterPool.length];
              targetMenu = picked['n'] ?? '';
              targetIngredients = List<Map<String, dynamic>>.from(picked['ing'] ?? [])
                  .map((e) => {'name': e['name'].toString(), 'amount': e['amount'].toString()})
                  .toList();
              poolIdx++;
            }

            if (targetMenu.isNotEmpty) {
              _localPlanState[dayKey]![mealKey]!['value'] = targetMenu;
              _localPlanState[dayKey]![mealKey]!['ingredients'] = targetIngredients;
              if (targetIngredients.isEmpty) {
                _triggerGeminiAiForSlot(dayKey, mealKey, targetMenu);
              }
            }
          }
        }
      }
    });
  }

  Future<void> _triggerGeminiAiForSlot(String dayKey, String mealKey, String menuName) async {
    final controller = ref.read(dashboardControllerProvider);
    final aiIngredients = await controller.fetchAiIngredients(menuName);
    if (mounted) {
      setState(() { _localPlanState[dayKey]![mealKey]!['ingredients'] = aiIngredients; });
    }
  }

  void _executeFinalConfirmation() async {
    List<Map<String, String>> itemsToPack = [];
    List<Map<String, dynamic>> newMenusToReview = [];

    _localPlanState.forEach((dayKey, meals) {
      meals.forEach((mealKey, data) {
        if (data['status'] == 'menu' && data['value'].toString().isNotEmpty) {
          final String menuName = data['value'];
          final List<Map<String, String>> ings = List<Map<String, String>>.from(data['ingredients'] ?? []);
          for (var ing in ings) {
            itemsToPack.add({'menu': menuName, 'name': ing['name']!, 'amount': ing['amount']!});
          }
          if (!widget.room.masterRecommendPool.any((e) => e['n'] == menuName)) {
            newMenusToReview.add({'n': menuName, 'ing': ings});
          }
        }
      });
    });

    if (itemsToPack.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('확정할 식단 메뉴가 존재하지 않습니다.')));
      return;
    }

    if (newMenusToReview.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ReviewSaveDialog(
          newMenus: newMenusToReview,
          onSendOnlyShopping: () { Navigator.pop(ctx); _finalizeShoppingInjection(itemsToPack); },
          onSaveToGlobalAndShopping: (cat) async {
            Navigator.pop(ctx);
            final controller = ref.read(dashboardControllerProvider);
            for (var menu in newMenusToReview) {
              await controller.saveToGlobalRepo(menu['n'], cat, List<Map<String, String>>.from(menu['ing']));
            }
            _finalizeShoppingInjection(itemsToPack);
          },
        ),
      );
    } else {
      _finalizeShoppingInjection(itemsToPack);
    }
  }

  void _finalizeShoppingInjection(List<Map<String, String>> itemsToPack) async {
    final controller = ref.read(dashboardControllerProvider);
    for (var item in itemsToPack) {
      await controller.injectIngredientsToShoppingList(widget.room, item['menu']!, [{'name': item['name']!, 'amount': item['amount']!}]);
    }
    await controller.clearWishMenuAfterConfirmation(widget.room);
    setState(() {
      for (var day in _daysOfWeek) {
        _localPlanState[day['key']!] = {
          'breakfast': {'status': 'menu', 'value': '', 'ingredients': <Map<String, String>>[]},
          'lunch': {'status': 'menu', 'value': '', 'ingredients': <Map<String, String>>[]},
          'dinner': {'status': 'menu', 'value': '', 'ingredients': <Map<String, String>>[]},
        };
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 식단 재료가 장보기에 복사되었으며, 위시 게시판이 리셋되었습니다!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentNick = ref.watch(currentUserNicknameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      body: Column(
        children: [
          WishBoardWidget(room: widget.room, currentNick: currentNick, wishController: _wishController),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E342E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _executeFinalConfirmation,
                icon: const Icon(Icons.done_all, color: Colors.white),
                label: const Text('이번 주 식단 확정 및 위시 메뉴 리셋', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Text('📆 요일별 식단 조율 보드', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                const Spacer(),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8A65),
                    side: const BorderSide(color: Color(0xFFFF8A65)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _showAiOptionsDialog(),
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('AI 자동 식단짜기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _daysOfWeek.length,
              itemBuilder: (context, idx) {
                final day = _daysOfWeek[idx];
                final dayKey = day['key']!;
                return PlannerDayCard(
                  dayLabel: day['label']!,
                  dayMeals: _localPlanState[dayKey]!,
                  onToggleStatus: (mealKey) => _toggleSlotStatus(dayKey, mealKey),
                  onSlotTap: (mealKey) => _showManualInputBottomSheet(dayKey, mealKey),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAiOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 우리집 맞춤 자동 식단 구성', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
        content: const Text('원하는 식단 스타일 옵션을 선택하세요.'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['건강식', '성장기', '바쁜 엄마아빠', '초간단'].map((option) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () { Navigator.pop(context); _generateAiDiet(option); },
                child: Text(option),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  void _showManualInputBottomSheet(String dayKey, String mealKey) {
    final TextEditingController manualController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('요리 이름 직접 입력', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: manualController,
              autofocus: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '예: 삼겹살 김치찌개'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
                  onPressed: () {
                    final typed = manualController.text.trim();
                    if (typed.isNotEmpty) {
                      setState(() {
                        _localPlanState[dayKey]![mealKey]!['value'] = typed;
                        _localPlanState[dayKey]![mealKey]!['ingredients'] = <Map<String, String>>[];
                      });
                      Navigator.pop(ctx);
                      _triggerGeminiAiForSlot(dayKey, mealKey, typed);
                    }
                  },
                  child: const Text('저장', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}