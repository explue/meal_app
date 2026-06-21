import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localization.dart';
import '../../language/language_select_screen.dart';
import '../controllers/dashboard_provider.dart';
import 'category_tab_view.dart';
import 'shopping_list_tab_view.dart';
import 'meal_planner_tab_view.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentTabIndex = 0;
  String? _pendingRoomId;
  bool _hasConfirmedNickname = false;

  final TextEditingController _roomInputController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _roomInputController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Widget _buildSafeLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        'https://images.squarespace-cdn.com/content/v1/6763fb4e9c719e7db715ffca/baf718d0-08c3-4f9e-be42-59535f29910a/image_87f875.png',
        width: 22,
        height: 22,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.restaurant, size: 18, color: Color(0xFFFF8A65));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomId = ref.watch(currentRoomIdProvider);
    final appLang = ref.watch(currentLanguageProvider);
    final currentNick = ref.watch(currentUserNicknameProvider);
    final controller = ref.read(dashboardControllerProvider);

    if (roomId == null && _pendingRoomId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFDF9),
        body: Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, size: 50, color: Color(0xFFFF8A65)),
                const SizedBox(height: 10),
                const Text('Happy Table', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                Text(Lang.txt('slogan', appLang), style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A65),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () async {
                      final newId = await controller.createNewRoom();
                      ref.read(currentRoomIdProvider.notifier).state = null;
                      setState(() { _pendingRoomId = newId; });
                    },
                    icon: const Icon(Icons.add_home_work),
                    label: const Text('새로운 장보기방 만들기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('또는', style: TextStyle(fontSize: 15, color: Colors.grey)),
                const SizedBox(height: 20),
                TextField(
                  controller: _roomInputController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: '6자리 초대 코드 입력',
                    hintText: '518293',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF8A65),
                      side: const BorderSide(color: Color(0xFFFF8A65)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () async {
                      String typedCode = _roomInputController.text.trim();
                      if (typedCode.isNotEmpty) {
                        final fullRoomId = "room_$typedCode";
                        final exists = await ref.read(roomRepositoryProvider).verifyRoomExists(fullRoomId);
                        if (!context.mounted) return;
                        if (exists) {
                          setState(() { _pendingRoomId = fullRoomId; });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('존재하지 않는 방 번호입니다. 다시 확인해 주세요.'))
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.vpn_key),
                    label: const Text('초대 코드로 참여', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const LanguageSelectScreen()));
                  },
                  icon: const Icon(Icons.g_translate, size: 16, color: Colors.grey),
                  label: const Text('Change Language', style: TextStyle(color: Colors.grey, fontSize: 13)),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (_pendingRoomId != null && !_hasConfirmedNickname) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFDF9),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 70, color: Color(0xFFFF8A65)),
              const SizedBox(height: 15),
              const Text('한식구 별명 설정', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
              const SizedBox(height: 8),
              const Text('식구들이 서로를 알아볼 수 있게 별명을 정해 주세요.', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 30),
              TextField(
                controller: _nicknameController,
                maxLength: 8,
                decoration: InputDecoration(
                  hintText: '예: 엄마, 아빠, 삼촌',
                  hintStyle: const TextStyle(color: Colors.black26),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A65), 
                    padding: const EdgeInsets.symmetric(vertical: 14), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  onPressed: () async {
                    final nickText = _nicknameController.text.trim();
                    if (nickText.isNotEmpty) {
                      await controller.saveUserNickname(nickText);
                      await ref.read(roomRepositoryProvider).saveRoomSession(_pendingRoomId!);
                      ref.read(currentRoomIdProvider.notifier).state = _pendingRoomId;
                      setState(() { _hasConfirmedNickname = true; });
                    }
                  },
                  child: const Text('한식구 입장하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      );
    }

    final roomStream = ref.watch(mealRoomStreamProvider(roomId!));

    return roomStream.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const Scaffold(body: Center(child: Text('데이터 연결 오류가 발생했습니다.'))),
      data: (room) {
        if (room == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        String finalAppTitle = (appLang == 'ko') ? Lang.txt('main_title', appLang) : 'Happy Table';
        if (_currentTabIndex == 1) finalAppTitle = Lang.txt('shop_title', appLang);
        if (_currentTabIndex == 2) finalAppTitle = '📆 이번주 식단';

        return Scaffold(
          backgroundColor: const Color(0xFFFFFDF9),
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSafeLogo(),
                const SizedBox(width: 8),
                Text(finalAppTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color(0xFF4E342E))),
                const SizedBox(width: 8),
                _buildSafeLogo(),
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (room.isShoppingStarted && _currentTabIndex == 1)
                  Container(
                    width: double.infinity,
                    color: Colors.amber.shade100,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      Lang.txt('partner_alert', appLang),
                      style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(12)),
                        child: Text(currentNick, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFE65100))),
                      ),
                      const SizedBox(width: 6),
                      const CircleAvatar(
                        radius: 14, backgroundColor: Color(0xFFFFCCBC),
                        child: Icon(Icons.tag, color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 6),
                    Text(room.roomId.replaceAll('room_', ''), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF8A65))),
                    const SizedBox(width: 4),
                    IconButton(
                      constraints: const BoxConstraints(), padding: EdgeInsets.zero,
                      icon: const Icon(Icons.logout, color: Color(0xFFFF8A65), size: 18),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(Lang.txt('exit_ask', appLang), style: const TextStyle(fontWeight: FontWeight.bold)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(Lang.txt('no', appLang))),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  setState(() { _pendingRoomId = null; _hasConfirmedNickname = false; });
                                  await controller.leaveRoom();
                                },
                                child: Text(Lang.txt('yes', appLang), style: const TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              Container(
                margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    _buildTabButton(0, '요리방', Icons.home),
                    _buildTabButton(1, '장보기', Icons.shopping_basket),
                    _buildTabButton(2, '식단표', Icons.calendar_month),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFFFE0B2)),
              
              // 🛠️ 렌더 박스 크기 보장 완공: 하위 위젯들이 튕기지 않도록 공간 점유를 유연하게 확보
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentTabIndex),
                      child: _currentTabIndex == 0
                          ? CategoryTabView(room: room, appLang: appLang)
                          : _currentTabIndex == 1
                              ? ShoppingListTabView(room: room, appLang: appLang)
                              : MealPlannerTabView(room: room, appLang: appLang),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildTabButton(int index, String label, IconData icon) {
    bool isSel = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() { _currentTabIndex = index; }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFFF8A65) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSel ? Colors.white : Colors.black54),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}