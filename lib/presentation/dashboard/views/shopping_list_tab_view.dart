import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/meal_room.dart';
import '../controllers/dashboard_provider.dart';

class ShoppingListTabView extends ConsumerStatefulWidget {
  final MealRoom room;
  final String appLang;

  const ShoppingListTabView({super.key, required this.room, required this.appLang});

  @override
  ConsumerState<ShoppingListTabView> createState() => _ShoppingListTabViewState();
}

class _ShoppingListTabViewState extends ConsumerState<ShoppingListTabView> {
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _customItemController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    _customItemController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _handlePurchaseAction(String itemName, String userNickname, bool currentStatus) async {
    final controller = ref.read(dashboardControllerProvider);
    await controller.toggleIngredientPurchase(widget.room, itemName, !currentStatus);
    if (!currentStatus && mounted) {
      _showTopNotification(userNickname);
    }
  }

  void _showTopNotification(String nickname) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60, 
        left: 20, right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4E342E).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$nickname님이 장보기를 시작했습니다.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('리스트 초기화', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말 장보기 리스트를 전부 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(dashboardControllerProvider).resetShoppingList(widget.room);
              Navigator.pop(ctx);
            },
            child: const Text('초기화 동의', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('장보기 직접 추가', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _customItemController, decoration: const InputDecoration(hintText: '예: 우유, 계란')),
            const SizedBox(height: 8),
            TextField(controller: _customAmountController, decoration: const InputDecoration(hintText: '예: 1팩, 2개')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
            onPressed: () {
              final name = _customItemController.text.trim();
              final amount = _customAmountController.text.trim();
              if (name.isNotEmpty) {
                ref.read(dashboardControllerProvider).addCustomIngredientToCart(
                  widget.room, name, amount.isEmpty ? '적당량' : amount
                );
                _customItemController.clear();
                _customAmountController.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('추가', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(dashboardControllerProvider);
    final currentNick = ref.watch(currentUserNicknameProvider);
    final list = widget.room.shoppingList ?? [];
    final sharedMemo = widget.room.sharedMemo ?? '가족들에게 필요한 장보기 메모를 남겨보세요!';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: const Color(0xFFFFF3E0),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFFE65100)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '[$sharedMemo]',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16, color: Color(0xFFE65100)),
                constraints: const BoxConstraints(), padding: EdgeInsets.zero,
                onPressed: () {
                  _chatController.text = widget.room.sharedMemo ?? '';
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('한식구 실시간 메모 수정'),
                      content: TextField(controller: _chatController, maxLength: 30, decoration: const InputDecoration(hintText: '예: 마트 가시는 분 두부 사오세요')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
                        ElevatedButton(
                          onPressed: () {
                            controller.updateSharedMemo(widget.room, _chatController.text.trim());
                            Navigator.pop(ctx);
                          },
                          child: const Text('공유'),
                        )
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🎯 명세 반영: '🛒 장보기 목록' 타이틀 글자 크기 16.0으로 확대
              const Text('🛒 장보기 목록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)), 
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65), 
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // 터치 가시성 확보
                  visualDensity: VisualDensity.standard, 
                ),
                onPressed: () => _showAddItemDialog(),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                // 🎯 명세 반영: '장보기 직접 추가' 버튼 글자 크기 16.0으로 확대
                label: const Text('장보기 직접 추가', style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)), 
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('장볼 재료가 없습니다. 요리방에서 추가해 주세요.', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final name = item['name'] ?? '';
                    final amount = item['amount'] ?? '';
                    final bool isPurchased = item['is_purchased'] ?? false;
                    final bool hasAtHome = item['has_at_home'] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          children: [
                            // 🎯 명세 반영: 재료명과 수량이 흔들리지 않도록 가로 비율 고정형 좌측 정렬 레이아웃 적용[cite: 1]
                            Expanded(
                              child: Row(
                                children: [
                                  // 가로폭의 공간을 유연하게 분할하여 자로 잰 듯 정렬합니다.
                                  Expanded(
                                    flex: 6, // 재료명 영역 할당
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16.0, // 고정 규격[cite: 1]
                                        fontWeight: FontWeight.bold,
                                        color: isPurchased ? Colors.grey : Colors.black87,
                                        decoration: isPurchased ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4, // 수량 영역 할당 (재료명 길이에 상관없이 무조건 고정된 지점에서 출발)
                                    child: Text(
                                      amount,
                                      style: TextStyle(
                                        fontSize: 16.0, // 고정 규격[cite: 1]
                                        fontWeight: FontWeight.bold,
                                        color: isPurchased ? Colors.grey : Colors.grey.shade700,
                                        decoration: isPurchased ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // 우측 조작 버튼 레이아웃 영역
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: hasAtHome ? Colors.green.shade50 : Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  ),
                                  onPressed: () => controller.toggleIngredientAtHome(widget.room, name, !hasAtHome),
                                  // 🎯 명세 반영: '집에 있음' 글자 크기 16.0으로 확대[cite: 1]
                                  child: Text('집에 있음', style: TextStyle(color: hasAtHome ? Colors.green : Colors.grey, fontSize: 16.0, fontWeight: FontWeight.bold)), 
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isPurchased ? Colors.grey.shade300 : const Color(0xFFFF8A65),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    elevation: 0
                                  ),
                                  onPressed: () => _handlePurchaseAction(name, currentNick, isPurchased),
                                  // 🎯 명세 반영: '구매' 버튼 글자 크기 16.0으로 확대[cite: 1]
                                  child: Text(isPurchased ? '취소' : '구매', style: TextStyle(color: isPurchased ? Colors.black54 : Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)), 
                                ),
                                // 🎯 명세 반영: '휴지통' 아이콘 크기 재료명과 연동하여 22픽셀로 대폭 확대[cite: 1]
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22), 
                                  onPressed: () => controller.removeIngredientItem(widget.room, name),
                                ),
                              ],
                            ),
                          ],
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
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4E342E)),
              onPressed: () => _showResetConfirmDialog(),
              child: const Text('장보기 리스트 초기화', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0)),
            ),
          ),
        ),
      ],
    );
  }
}