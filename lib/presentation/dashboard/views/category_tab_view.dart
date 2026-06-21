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

  // 🛠️ 요리 상세 편집 팝업 (재료 추가/삭제 및 카테고리 이동 저장)
  void _showRecipeDetailDialog(RecipePool recipe) {
    final controller = ref.read(dashboardControllerProvider);
    final List<Ingredient> tempIngredients = List.from(recipe.ingredients);
    final TextEditingController ingredientInputController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                // 1) 재료 추가 입력창
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ingredientInputController,
                        decoration: const InputDecoration(hintText: '새로운 재료 입력', isDense: true),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFFFF8A65)),
                      onPressed: () {
                        if (ingredientInputController.text.trim().isNotEmpty) {
                          setDialogState(() {
                            tempIngredients.add(Ingredient(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: ingredientInputController.text.trim(),
                              amount: '적당량',
                              parentMenu: recipe.name,
                            ));
                          });
                          ingredientInputController.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 2) 재료 리스트 및 휴지통 버튼
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tempIngredients.length,
                    itemBuilder: (c, i) => ListTile(
                      dense: true,
                      title: Text(tempIngredients[i].name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => setDialogState(() => tempIngredients.removeAt(i)),
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
              onPressed: () {
                Navigator.pop(ctx);
                _showMoveCategoryDialog(recipe, tempIngredients); // 3) 저장 시 카테고리 선택 분기
              },
              child: const Text('저장', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // 🛠️ 저장 위치 선택 팝업 (어떤 카테고리에 저장할지 결정)
  void _showMoveCategoryDialog(RecipePool oldRecipe, List<Ingredient> newIngs) {
    final controller = ref.read(dashboardControllerProvider);
    final categories = ['한식', '양식', '남미 요리', '디저트', '기타'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('저장 위치 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((cat) => ListTile(
            title: Text(cat),
            onTap: () async {
              final updatedRecipe = RecipePool(name: oldRecipe.name, category: cat, ingredients: newIngs);
              await controller.updateOrAddRecipe(widget.room, updatedRecipe);
              if (mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${oldRecipe.name}이(가) $cat 카테고리에 저장되었습니다.')));
            },
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(dashboardControllerProvider);
    final List<dynamic> rawPool = widget.room.masterRecommendPool;
    
    // 1) 중복 없는 카테고리 추출 및 '전체' 추가
    final Set<String> categories = {'전체', ...rawPool.map((e) => e['cat'] as String? ?? '기타').where((c) => c.isNotEmpty)};
    
    final List<dynamic> filteredPool = _selectedCategory == '전체'
        ? rawPool
        : rawPool.where((e) => e['cat'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      // 🎯 1. 도전요리/카테고리 추가 통합 버튼
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4E342E),
        onPressed: () => _showAddMenuDialog(), 
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('도전요리 추가', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 🎯 2. 카테고리 UI (사각형 칩셋 + X 버튼 삭제 복원)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: categories.map((cat) {
                bool isSel = _selectedCategory == cat;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: InputChip(
                    label: Text(cat),
                    selected: isSel,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // 사각형 UI
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    onDeleted: cat == '전체' ? null : () => controller.deleteCategory(widget.room, cat), // X버튼 삭제
                    deleteIcon: const Icon(Icons.cancel, size: 16),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // 🎯 3. 요리 메뉴 그리드 (사각형 카드 + 내부 X 버튼 복원)
          Expanded(
            child: filteredPool.isEmpty
                ? const Center(child: Text('요리가 없습니다. 추가해 보세요!'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4
                    ),
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

                      return GestureDetector(
                        onTap: () => _showRecipeDetailDialog(recipe), // 🎯 요리 클릭 시 상세 팝업
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.restaurant, color: Color(0xFFFF8A65), size: 24),
                                    const SizedBox(height: 8),
                                    Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ),
                              // 🎯 요리 카드 내 X 삭제 버튼
                              Positioned(
                                top: 4, right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                  onPressed: () => controller.deleteRecipe(widget.room, recipe),
                                ),
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
    );
  }

  // 🛠️ 도전 요리 직접 추가 다이얼로그
  void _showAddMenuDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('새 도전요리 추가'),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: '요리 이름을 입력하세요 (예: 불고기)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newRecipe = RecipePool(name: nameController.text.trim(), category: '기타', ingredients: []);
                ref.read(dashboardControllerProvider).updateOrAddRecipe(widget.room, newRecipe);
                Navigator.pop(ctx);
              }
            },
            child: const Text('추가'),
          )
        ],
      ),
    );
  }
}