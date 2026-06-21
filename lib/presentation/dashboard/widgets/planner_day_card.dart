import 'package:flutter/material.dart';

class PlannerDayCard extends StatelessWidget {
  final String dayLabel;
  final Map<String, Map<String, dynamic>> dayMeals;
  final Function(String mealKey) onToggleStatus;
  final Function(String mealKey) onSlotTap;

  const PlannerDayCard({
    super.key,
    required this.dayLabel,
    required this.dayMeals,
    required this.onToggleStatus,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dayLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFFF8A65))),
            const SizedBox(height: 10),
            ...['breakfast', 'lunch', 'dinner'].map((mealKey) {
              final slot = dayMeals[mealKey]!;
              final List<Map<String, String>> ings = List<Map<String, String>>.from(slot['ingredients'] ?? []);

              String mealLabel = '아침';
              if (mealKey == 'lunch') mealLabel = '점심';
              if (mealKey == 'dinner') mealLabel = '저녁';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 45,
                          child: Text(mealLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 13)),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => onSlotTap(mealKey),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: slot['status'] == 'menu'
                                    ? const Color(0xFFFFFDF9)
                                    : slot['status'] == 'eat_out'
                                        ? Colors.amber.shade50
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                slot['value'].isEmpty ? '식사 추가 또는 터치하여 조율' : slot['value'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: slot['status'] == 'menu' ? FontWeight.normal : FontWeight.bold,
                                  color: slot['status'] == 'menu'
                                      ? (slot['value'].isEmpty ? Colors.black26 : Colors.black87)
                                      : slot['status'] == 'eat_out'
                                          ? Colors.amber.shade900
                                          : Colors.black38,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            slot['status'] == 'menu'
                                ? Icons.toggle_on
                                : slot['status'] == 'eat_out'
                                    ? Icons.restaurant
                                    : Icons.do_not_disturb_on,
                            color: slot['status'] == 'menu'
                                ? const Color(0xFFFF8A65)
                                : slot['status'] == 'eat_out'
                                    ? Colors.amber
                                    : Colors.grey,
                          ),
                          onPressed: () => onToggleStatus(mealKey),
                        )
                      ],
                    ),
                    // 🛠️ 대책 실현: 식단표 메뉴 하단에 소요 재료 목록을 조밀한 칩셋 형태로 상시 바인딩 노출
                    if (slot['status'] == 'menu' && slot['value'].toString().isNotEmpty && ings.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 45, top: 4),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: ings.map((e) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(6)),
                            child: Text('${e['name']}(${e['amount']})', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                          )).toList(),
                        ),
                      )
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}