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
  final FocusNode _detailIngNameFocusNode = FocusNode();
  final FocusNode _detailIngAmountFocusNode = FocusNode();
  
  List<Ingredient> _tempIngredients = [];
  String? _selectedCategoryPath;

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
    _detailIngNameFocusNode.dispose();
    _detailIngAmountFocusNode.dispose();
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

  void _executeDetailAdd(RecipePool recipe, List<Ingredient> editTempIngredients, void Function(void Function()) setDialogState) {
    if (_ingNameController.text.isNotEmpty) {
      setDialogState(() {
        editTempIngredients.insert(0, Ingredient(
          id: '',
          name: _ingNameController.text.trim(),
          amount: _ingAmountController.text.isEmpty ? '적당량' : _formatAmount(_ingAmountController.text),
          parentMenu: recipe.name,
        ));
      });
      _ingNameController.clear();
      _ingAmountController.clear();
      _detailIngNameFocusNode.requestFocus(); 
    }
  }

  void _showRecipeDetailDialog(RecipePool recipe) {
    _ingNameController.clear();
    _ingAmountController.clear();
    
    List<Ingredient> editTempIngredients = List.from(recipe.ingredients);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (innerContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('🍳 ${recipe.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), 
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('추가할 재료가 있으시면 입력해주세요', style: TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold, fontSize: 14)), 
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingNameController,
                          focusNode: _detailIngNameFocusNode, 
                          textInputAction: TextInputAction.next, 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                          decoration: const InputDecoration(hintText: '재료명', isDense: true),
                          onSubmitted: (_) => _detailIngAmountFocusNode.requestFocus(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _ingAmountController,
                          focusNode: _detailIngAmountFocusNode, 
                          textInputAction: TextInputAction.done, 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                          decoration: const InputDecoration(hintText: '수량', isDense: true),
                          onSubmitted: (_) => _executeDetailAdd(recipe, editTempIngredients, setDialogState),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFFFF8A65), size: 28),
                        onPressed: () => _executeDetailAdd(recipe, editTempIngredients, setDialogState),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  WidgetDetailIngredientList(editTempIngredients: editTempIngredients, setDialogState: setDialogState),
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.maxFinite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx), 
                    child: const Text('나가기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)) 
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65), padding: const EdgeInsets.symmetric(horizontal: 16)),
                    onPressed: () async {
                      final updatedRecipe = RecipePool(
                        name: recipe.name,
                        category: recipe.category,
                        ingredients: editTempIngredients,
                      );
                      await ref.read(dashboardControllerProvider).updateOrAddRecipe(widget.room, updatedRecipe);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('저장', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), 
                  ),
                  TextButton(
                    onPressed: () async {
                      final controller = ref.read(dashboardControllerProvider);
                      for (var ing in editTempIngredients) {
                        await controller.addCustomIngredientToCart(widget.room, ing.name, ing.amount);
                      }
                      
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(bottom: 20, left: 24, right: 24),
                          backgroundColor: Colors.green,
                          content: Text('🛒 장보기방에 적재되었습니다!', style: TextStyle(fontWeight: FontWeight.bold)) 
                        )
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text('장보기로 보내기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)), 
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    _newCategoryController.clear();
    int selectedIconIndex = 0; 

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (innerContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('📁 새 카테고리 추가', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _newCategoryController,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), 
                    decoration: const InputDecoration(
                      hintText: '카테고리 이름 입력 (예: 분식, 야식)',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal), 
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('음식 카테고리 아이콘을 선택해주세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)), 
                  const SizedBox(height: 10),
                  GridView.builder(
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
                          color: selectedIconIndex == i ? const Color(0xFFFF8A65).withValues(alpha: 0.15) : Colors.transparent,
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
                ],
              ),
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
    final Set<String> existingCategories = {};
    for (var item in pool) {
      final cat = item['cat']?.toString() ?? '';
      if (cat.isNotEmpty) existingCategories.add(cat);
    }
    
    if (existingCategories.isEmpty) {
      existingCategories.add('[0]한식');
    }
    String selectedCategory = existingCategories.first;

    showDialog(
      context: parentContext,
      builder: (ctx) => StatefulBuilder(
        builder: (innerContext, setCatState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('📁 카테고리 선택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
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
        builder: (innerContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🍳 새 도전요리 등록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
          content: SizedBox(
            width: 400,
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
                          textInputAction: TextInputAction.next,
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
                          textInputAction: TextInputAction.done,
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
                  WidgetTempIngredientList(tempIngredients: _tempIngredients, setDialogState: setDialogState),
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

    for (var item in pool) {
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(item);
      final recipe = RecipePool.fromMap(dataMap);
      categorizedRecipes.putIfAbsent(recipe.category, () => []).add(recipe);
    }

    final allCategories = categorizedRecipes.keys.toList();

    if (_selectedCategoryPath != null) {
      final currentCategoryName = _selectedCategoryPath!;
      final recipeList = (categorizedRecipes[currentCategoryName] ?? [])
          .where((r) => !r.name.contains('시작하기')) 
          .toList();

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFF8A65)),
            onPressed: () => setState(() => _selectedCategoryPath = null), 
          ),
          title: Text(
            '${_getPureCategoryName(currentCategoryName)} 메뉴 목록',
            style: const TextStyle(color: Color(0xFF424242), fontWeight: FontWeight.bold, fontSize: 18), 
          ),
        ),
        body: recipeList.isEmpty
            ? const Center(child: Text('등록된 도전요리가 없습니다.\n우측 상단 버튼으로 요리를 추가해 보세요!', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)) 
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  itemCount: recipeList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,         
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,     
                  ),
                  itemBuilder: (context, index) {
                    final recipe = recipeList[index];

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Stack(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showRecipeDetailDialog(recipe),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  recipe.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF424242)), 
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                              onPressed: () async {
                                final bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('🗑️ 요리 메뉴 삭제', style: TextStyle(fontWeight: FontWeight.bold)), 
                                    content: Text('"${recipe.name}" 요리를 카테고리에서 삭제할까요?', style: const TextStyle(fontWeight: FontWeight.bold)), 
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
                                  await ref.read(dashboardControllerProvider).deleteRecipe(widget.room, recipe);
                                  setState(() {});
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
      );
    }

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
                  label: const Text('카테고리 추가', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), 
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
                  label: const Text('도전요리 추가', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), 
                ),
              ],
            ),
          ),
          
          Expanded(
            child: allCategories.isEmpty
                ? const Center(
                    child: Text(
                      '등록된 요리 카테고리가 없습니다.\n왼쪽 상단 버튼으로 새 카테고리를 만들어보세요!', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, height: 1.5, fontSize: 14), 
                      textAlign: TextAlign.center,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: GridView.builder(
                      itemCount: allCategories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,         
                        crossAxisSpacing: 6,       
                        mainAxisSpacing: 6,
                        childAspectRatio: 0.85,     
                      ),
                      itemBuilder: (context, index) {
                        final catName = allCategories[index];
                        final recipeList = categorizedRecipes[catName] ?? [];
                        final displayCount = recipeList.where((r) => !r.name.contains('시작하기')).length;
                        final pureName = _getPureCategoryName(catName); 

                        return Card(
                          elevation: 1.5,
                          margin: const EdgeInsets.all(2), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Stack(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => setState(() => _selectedCategoryPath = catName),
                                    child: Center(
                                      child: SingleChildScrollView( 
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
                                                size: 28, 
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                pureName,
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
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                                  onPressed: () async {
                                    final bool? confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text('🗑️ 카테고리 삭제', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                                        content: Text('"$pureName" 카테고리를 정말로 삭제할까요?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), 
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                                          TextButton(
                                            onPressed: () => Navigator.pop(c, true), 
                                            child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirm == true) {
                                      await ref.read(dashboardControllerProvider).deleteCategory(widget.room, catName);
                                      setState(() {
                                        if (_selectedCategoryPath == catName) {
                                          _selectedCategoryPath = null;
                                        }
                                      });
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

class WidgetDetailIngredientList extends StatelessWidget {
  final List<Ingredient> editTempIngredients;
  final void Function(void Function()) setDialogState;

  const WidgetDetailIngredientList({super.key, required this.editTempIngredients, required this.setDialogState});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36, maxHeight: 150),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: editTempIngredients.length,
        itemBuilder: (c, i) => Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(editTempIngredients[i].name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), 
              ),
              Expanded(
                flex: 3,
                child: Text(editTempIngredients[i].amount, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center), 
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () {
                    setDialogState(() => editTempIngredients.removeAt(i));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WidgetTempIngredientList extends StatelessWidget {
  final List<Ingredient> tempIngredients;
  final void Function(void Function()) setDialogState;

  const WidgetTempIngredientList({super.key, required this.tempIngredients, required this.setDialogState});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36, maxHeight: 100),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: tempIngredients.length,
        itemBuilder: (c, i) => Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(tempIngredients[i].name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.left), 
              ),
              Expanded(
                flex: 3,
                child: Text(tempIngredients[i].amount, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center), 
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () {
                    setDialogState(() => tempIngredients.removeAt(i));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}