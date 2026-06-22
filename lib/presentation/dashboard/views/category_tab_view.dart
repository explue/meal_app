import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _ingNameController = TextEditingController();
  final TextEditingController _ingAmountController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController(); 
  
  final FocusNode _ingNameFocusNode = FocusNode();
  final FocusNode _ingAmountFocusNode = FocusNode();
  
  List<Ingredient> _tempIngredients = [];

  final List<IconData> _availableIcons = [
    Icons.rice_bowl_outlined,      
    Icons.local_pizza_outlined,     
    Icons.ramen_dining_outlined,    
    Icons.bakery_dining_outlined,   
    Icons.soup_kitchen_outlined,    
    Icons.lunch_dining_outlined,    
    Icons.cake_outlined,            
    Icons.local_drink_outlined,     
  ];

  @override
  void dispose() {
    _recipeNameController.dispose();
    _ingNameController.dispose();
    _ingAmountController.dispose();
    _newCategoryController.dispose();
    _ingNameFocusNode.dispose();
    _ingAmountFocusNode.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String rawName) {
    if (rawName.startsWith('[') && rawName.contains(']')) {
      final indexStr = rawName.substring(1, rawName.indexOf(']'));
      final index = int.tryParse(indexStr) ?? 0;
      return _availableIcons[index % _availableIcons.length];
    }
    if (rawName.contains('한식')) return _availableIcons[0];
    if (rawName.contains('양식')) return _availableIcons[1];
    if (rawName.contains('일식')) return _availableIcons[2];
    if (rawName.contains('중식')) return _availableIcons[3];
    return Icons.restaurant_menu_outlined; 
  }

  String _getPureCategoryName(String rawName) {
    if (rawName.startsWith('[') && rawName.contains(']')) {
      return rawName.substring(rawName.indexOf(']') + 1);
    }
    return rawName;
  }

  String _formatAmount(String input) {
    String trimmed = input.trim().toLowerCase();
    if (trimmed.endsWith('그램')) {
      return '${trimmed.substring(0, trimmed.length - 2)}g';
    } else if (trimmed.endsWith('g')) {
      return trimmed;
    } else if (trimmed.endsWith('킬로그램') || trimmed.endsWith('키로그램')) {
      return '${trimmed.substring(0, trimmed.length - 4)}kg';
    } else if (trimmed.endsWith('kg')) {
      return trimmed;
    }
    return input;
  }

  void _addTempIngredient(void Function(void Function()) setDialogState) {
    final name = _ingNameController.text.trim();
    final rawAmount = _ingAmountController.text.trim();
    if (name.isNotEmpty) {
      setDialogState(() {
        _tempIngredients.insert(0, Ingredient(
          id: '', 
          name: name,
          amount: rawAmount.isEmpty ? '적당량' : _formatAmount(rawAmount),
          parentMenu: _recipeNameController.text.trim(),
        ));
      });
      _ingNameController.clear();
      _ingAmountController.clear();
      _ingNameFocusNode.requestFocus();
    }
  }

  void _showAddCategoryDialog() {
    _newCategoryController.clear();
    int selectedIconIndex = 0; 

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('📁 새 카테고리 추가', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _newCategoryController,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '카테고리 이름 입력 (예: 분식, 야식)',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('오렌지 아이콘 선택', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.maxFinite,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _availableIcons.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.0, 
                    ),
                    itemBuilder: (c, i) => InkWell(
                      onTap: () => setDialogState(() => selectedIconIndex = i),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedIconIndex == i ? const Color(0xFFFF8A65).withOpacity(0.15) : Colors.transparent,
                          border: Border.all(
                            color: selectedIconIndex == i ? const Color(0xFFFF8A65) : Colors.grey.shade300,
                            width: selectedIconIndex == i ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _availableIcons[i], 
                          color: selectedIconIndex == i ? const Color(0xFFFF8A65) : Colors.grey,
                          size: 24, 
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
              onPressed: () async {
                final newCat = _newCategoryController.text.trim();
                if (newCat.isNotEmpty) {
                  final encodedCategoryName = '[$selectedIconIndex]$newCat';
                  final dummyRecipe = RecipePool(
                    name: '$newCat 시작하기',
                    category: encodedCategoryName,
                    ingredients: [
                      Ingredient(id: '', name: '기본 재료', amount: '1개', parentMenu: '$newCat 시작하기')
                    ],
                  );
                  await ref.read(dashboardControllerProvider).updateOrAddRecipe(widget.room, dummyRecipe);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('추가', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelectionDialog(BuildContext parentContext) {
    final pool = widget.room.masterRecommendPool;
    final Set<String> existingCategories = {'[0]한식', '[1]양식', '[2]일식', '[3]중식'};
    for (var item in pool) {
      final cat = item['cat']?.toString() ?? '';
      if (cat.isNotEmpty) existingCategories.add(cat);
    }
    String selectedCategory = existingCategories.first;

    showDialog(
      context: parentContext,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setCatState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('📁 카테고리 선택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('이 요리를 어느 카테고리에 저장할까요?', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: existingCategories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value, 
                        child: Text(_getPureCategoryName(value), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setCatState(() => selectedCategory = newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
              onPressed: () async {
                final recipeName = _recipeNameController.text.trim();
                if (recipeName.isNotEmpty) {
                  final newRecipe = RecipePool(
                    name: recipeName,
                    category: selectedCategory, 
                    ingredients: _tempIngredients,
                  );
                  await ref.read(dashboardControllerProvider).updateOrAddRecipe(widget.room, newRecipe);
                  
                  if (parentContext.mounted) Navigator.pop(parentContext); 
                  if (ctx.mounted) Navigator.pop(ctx); 
                }
              },
              child: const Text('확인 저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecipeDialog() {
    _recipeNameController.clear();
    _ingNameController.clear();
    _ingAmountController.clear();
    setState(() => _tempIngredients = []);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🍳 새 도전요리 등록', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _recipeNameController,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: '여기에 요리이름을 넣어주세요.',
                      hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 16, fontWeight: FontWeight.normal),
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingNameController,
                          focusNode: _ingNameFocusNode,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: '재료명', 
                            hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 16, fontWeight: FontWeight.normal),
                            isDense: true
                          ),
                          onSubmitted: (_) => _ingAmountFocusNode.requestFocus(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _ingAmountController,
                          focusNode: _ingAmountFocusNode,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: '수량', 
                            hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 16, fontWeight: FontWeight.normal),
                            isDense: true
                          ),
                          onSubmitted: (_) => _addTempIngredient(setDialogState),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFFFF8A65), size: 28),
                        onPressed: () => _addTempIngredient(setDialogState),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Scrollbar(
                    thumbVisibility: true,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 36, maxHeight: 68),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _tempIngredients.length,
                        itemBuilder: (c, i) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(_tempIngredients[i].name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(_tempIngredients[i].amount, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                  onPressed: () {
                                    setDialogState(() => _tempIngredients.removeAt(i));
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('나가기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
              onPressed: () => _showCategorySelectionDialog(ctx),
              child: const Text('저장', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pool = widget.room.masterRecommendPool;
    final Map<String, List<RecipePool>> categorizedRecipes = {};

    final List<String> defaultOrder = ['[0]한식', '[1]양식', '[2]일식', '[3]중식'];
    for (var cat in defaultOrder) {
      categorizedRecipes[cat] = [];
    }

    for (var item in pool) {
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(item);
      final recipe = RecipePool.fromMap(dataMap);
      categorizedRecipes.putIfAbsent(recipe.category, () => []).add(recipe);
    }

    final allCategories = categorizedRecipes.keys.toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8A65),
                    side: const BorderSide(color: Color(0xFFFF8A65), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                  label: const Text('카테고리 추가', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A65),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _showAddRecipeDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('도전요리 추가', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: allCategories.isEmpty
                ? const Center(child: Text('등록된 요리 카테고리가 없습니다.', style: TextStyle(fontWeight: FontWeight.bold)))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: GridView.builder(
                      itemCount: allCategories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,         
                        crossAxisSpacing: 6,       
                        mainAxisSpacing: 6,
                        // 🛠️ 레이아웃 붕괴 완전 진압: 세로 확장 비율을 0.85로 높여 크기 부족으로 인한 프리징 원천 차단
                        childAspectRatio: 0.85,     
                      ),
                      itemBuilder: (context, index) {
                        final catName = allCategories[index];
                        final recipeList = categorizedRecipes[catName] ?? [];
                        final displayCount = recipeList.where((r) => !r.name.contains('시작하기')).length;

                        return Card(
                          elevation: 1.5,
                          margin: const EdgeInsets.all(2), // 락 걸림 방지를 위한 미세 마진 확보
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Stack(
                            children: [
                              // ⚠️ 렌더 트리 충돌 방지를 위해 메인 정렬 컴포넌트를 LayoutBuilder로 유연하게 감쌈
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${_getPureCategoryName(catName)} 메뉴 목록으로 진입합니다.', style: const TextStyle(fontWeight: FontWeight.bold)), duration: const Duration(milliseconds: 500)),
                                      );
                                    },
                                    child: Center(
                                      child: SingleChildScrollView( // 혹시 모를 내부 오버플로우 방지벽 구축
                                        physics: const NeverScrollableScrollPhysics(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getCategoryIcon(catName),
                                                color: const Color(0xFFFF8A65),
                                                size: 28, // 3열 폭에 무리 주지 않도록 정교화
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _getPureCategoryName(catName),
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '메뉴 $displayCount개',
                                                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              ),
                              
                              Positioned(
                                top: -4,
                                right: -4,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey, size: 14),
                                  onPressed: () async {
                                    final bool? confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text('🗑️ 카테고리 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
                                        content: Text('"${_getPureCategoryName(catName)}"을 정말로 삭제할까요?', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold))),
                                          TextButton(
                                            onPressed: () => Navigator.pop(c, true), 
                                            child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref.read(dashboardControllerProvider).deleteCategory(widget.room, catName);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}