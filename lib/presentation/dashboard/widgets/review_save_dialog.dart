import 'package:flutter/material.dart';

class ReviewSaveDialog extends StatefulWidget {
  final List<Map<String, dynamic>> newMenus;
  final VoidCallback onSendOnlyShopping;
  final Function(String targetCategory) onSaveToGlobalAndShopping;

  const ReviewSaveDialog({
    super.key,
    required this.newMenus,
    required this.onSendOnlyShopping,
    required this.onSaveToGlobalAndShopping,
  });

  @override
  State<ReviewSaveDialog> createState() => _ReviewSaveDialogState();
}

class _ReviewSaveDialogState extends State<ReviewSaveDialog> {
  String _selectedCategoryForGlobal = '한식';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('💾 새로운 요리 데이터 처리', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('식단표에 처음 보는 메뉴가 감지되었습니다. 레시피 재료 데이터를 어떻게 정산할까요?', style: TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 15),
          SizedBox(
            height: 80,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.newMenus.length,
              itemBuilder: (c, i) => Text('• ${widget.newMenus[i]['n']} (${widget.newMenus[i]['ing'].length}개 재료)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF8A65))),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryForGlobal,
            decoration: const InputDecoration(labelText: '음식 카테고리 지정', border: OutlineInputBorder(), isDense: true),
            items: ['한식', '양식', '남미 요리'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() { _selectedCategoryForGlobal = v!; }),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onSendOnlyShopping,
          child: const Text('장보기로만 보내기'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65)),
          onPressed: () => widget.onSaveToGlobalAndShopping(_selectedCategoryForGlobal),
          child: const Text('내 데이터에 저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}