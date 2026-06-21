import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/meal_room.dart';
import '../../../domain/models/recipe_pool.dart';
import '../../../domain/models/ingredient.dart';
import '../controllers/dashboard_provider.dart';

class CategoryTabView extends ConsumerStatefulWidget {
  final MealRoom room;
  final String appLang;

  const CategoryTabView({super.key, required this.room, required this.appLang});

  @override
  ConsumerState<CategoryTabView> createState() => _CategoryTabViewState();
}

class _CategoryTabViewState extends ConsumerState<CategoryTabView> {
  String _selectedCategory = '전체';

  final List<Map<String, dynamic>> _fixedCategories = [
    {'name': '전체', 'name_en': 'All'},
    {'name': '한식', 'name_en': 'Korean'},
    {'name': '양식', 'name_en': 'Western'},
    {'name': '남미 요리', 'name_en': 'LatAm'},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(dashboardControllerProvider);
    final List<dynamic> rawPool = widget.room.masterRecommendPool;
    final List<dynamic> filteredPool = _selectedCategory == '전체'
        ? rawPool
        : rawPool.where((e) => e['cat'] == _selectedCategory).toList();

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: _fixedCategories.map((cat) {
              bool isSel = _selectedCategory == cat['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(widget.appLang == 'ko' ? cat['name'] : cat['name_en']),
                  selected: isSel,
                  onSelected: (selected) {
                    setState(() { _selectedCategory = cat['name']; });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: filteredPool.isEmpty
              ? const Center(child: Text('해당 카테고리에 요리가 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredPool.length,
                  itemBuilder: (context, index) {
                    final item = filteredPool[index];
                    final recipe = RecipePool(
                      name: item['n'] ?? '',
                      category: item['cat'] ?? '',
                      ingredients: List<Map<String, dynamic>>.from(item['ing'] ?? [])
                          .map((e) => Ingredient(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: e['name'] ?? '',
                                amount: e['amount'] ?? '',
                                parentMenu: item['n'] ?? '',
                              ))
                          .toList(),
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(recipe.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
                            onPressed: () {
                              controller.addRecipeIngredientsToCart(widget.room, recipe);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${recipe.name} 재료들이 장보기 탭에 추가되었습니다.'))
                              );
                            },
                            child: const Text('식단 추가', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}