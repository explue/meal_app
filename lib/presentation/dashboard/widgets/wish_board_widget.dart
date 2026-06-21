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

    final Set<String> uniqueWishes = {};
    if (room.wishMenuList != null) {
      for (var e in room.wishMenuList!) {
        uniqueWishes.add('[${e['requested_by']}] ${e['menu_name']}');
      }
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 불필요한 세로 팽창 방지
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, color: Color(0xFFFF8A65)),
              const SizedBox(width: 6),
              const Text('💡 이번 주 이거 먹고 싶어요!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4E342E))),
              const Spacer(),
              Text('($currentNick님 식방 참여 중)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: wishController,
                  decoration: const InputDecoration(
                    hintText: '예: 삼겹살, 떡볶이, 된장찌개',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.black26),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
                onPressed: () async {
                  final text = wishController.text.trim();
                  if (text.isNotEmpty) {
                    await controller.addWishMenu(room, text, currentNick);
                    wishController.clear();
                  }
                },
                child: const Text('건의', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          if (uniqueWishes.isNotEmpty) ...[
            const SizedBox(height: 8),
            // 🛠️ 크기 무제한 무력화 가드: 가로형 ListView에 명확한 제약을 부여하여 hit test 오류 원천 봉쇄
            SizedBox(
              height: 35,
              width: double.infinity,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: uniqueWishes.map((wishText) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: Chip(
                    backgroundColor: const Color(0xFFFFF3E0),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    label: Text(
                      wishText,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFE65100), fontWeight: FontWeight.bold),
                    ),
                  ),
                )).toList(),
              ),
            )
          ]
        ],
      ),
    );
  }
}