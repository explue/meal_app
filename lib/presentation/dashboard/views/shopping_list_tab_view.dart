import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/meal_room.dart';
import '../controllers/dashboard_provider.dart';

class ShoppingListTabView extends ConsumerWidget {
  final MealRoom room;
  final String appLang;

  const ShoppingListTabView({super.key, required this.room, required this.appLang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider);
    final list = room.shoppingList;

    return Column(
      children: [
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('장볼 재료가 없습니다. 식단표에서 추가해 주세요.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final name = item['name'] ?? '';
                    final amount = item['amount'] ?? '';
                    final parent = item['parent_menu'] ?? '직접 추가';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('$name ($amount)'),
                        subtitle: Text('출처: $parent', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => controller.removeIngredientItem(room, name),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4E342E)),
              onPressed: () => controller.resetShoppingList(room),
              child: const Text('장보기 리스트 초기화', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}