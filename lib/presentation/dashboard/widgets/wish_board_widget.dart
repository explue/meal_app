import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/meal_room.dart';
import '../controllers/dashboard_provider.dart';

class WishBoardWidget extends ConsumerWidget {
  final MealRoom room;
  final String currentNick;
  final TextEditingController wishController;

  const WishBoardWidget({
    super.key,
    required this.room,
    required this.currentNick,
    required this.wishController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider);
    final List<dynamic> wishes = room.wishMenus; 

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber),
              SizedBox(width: 8),
              Text('이번 주 이거 먹고 싶어요! (위시보드)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF5D4037))),
            ],
          ),
          const SizedBox(height: 12),
          
          wishes.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('등록된 위시 메뉴가 없습니다. 첫 제안을 던져보세요!', style: TextStyle(fontSize: 12, color: Colors.grey)),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: wishes.map((wish) {
                        final name = wish['menu_name'] ?? '';
                        final user = wish['user_name'] ?? '가족';
                        return Chip(
                          backgroundColor: Colors.white,
                          label: Text('$name ($user)', style: const TextStyle(fontSize: 12)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: wishController,
                  decoration: const InputDecoration(
                    hintText: '먹고 싶은 메뉴를 적어주세요',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4)
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
                onPressed: () {
                  if (wishController.text.trim().isNotEmpty) {
                    controller.addWishMenu(room, wishController.text.trim(), currentNick);
                    wishController.clear();
                  }
                },
                child: const Text('제안', style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }
}