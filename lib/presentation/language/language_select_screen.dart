import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/controllers/dashboard_provider.dart';
import '../dashboard/views/dashboard_screen.dart';

class LanguageSelectScreen extends ConsumerWidget {
  const LanguageSelectScreen({super.key});

  final List<Map<String, String>> langs = const [
    {'code': 'ko', 'display': '한국어 (Korean)'},
    {'code': 'en', 'display': 'English (영어)'},
    {'code': 'zh', 'display': '中文 (Chinese)'},
    {'code': 'id', 'display': 'Bahasa Indonesia'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.language, size: 50, color: Color(0xFFFF8A65)),
              const SizedBox(height: 10),
              const Text('Select Language', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 35),
              ListView.builder(
                shrinkWrap: true,
                itemCount: langs.length,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4E342E),
                        side: const BorderSide(color: Color(0xFFFFD1B1), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        await controller.changeLanguage(langs[idx]['code']!);
                        if (!context.mounted) return;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DashboardScreen()));
                      },
                      child: Text(langs[idx]['display']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}