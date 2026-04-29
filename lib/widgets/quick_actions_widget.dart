import 'package:flutter/cupertino.dart';
import '../services/language_service.dart';
import '../services/theme_service.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onScanNow;
  final VoidCallback onViewHistory;
  final VoidCallback onOpenAnalytics;

  const QuickActionsWidget({
    super.key,
    required this.onScanNow,
    required this.onViewHistory,
    required this.onOpenAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.currentLanguage,
      // Added the 'child' parameter to fix the builder error
      builder: (context, lang, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang == 'tl'
                  ? LanguageService.translate('quick_actions_tl')
                  : LanguageService.translate('quick_actions'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: onViewHistory,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: CupertinoColors.systemGrey5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.clock, color: CupertinoColors.black),
                        const SizedBox(width: 8),
                        Text(
                          lang == 'tl'
                              ? LanguageService.translate('view_history_tl')
                              : LanguageService.translate('view_history'),
                          style: const TextStyle(color: CupertinoColors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    onPressed: onOpenAnalytics,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: CupertinoColors.systemGrey5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.chart_bar,
                          color: CupertinoColors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang == 'tl'
                              ? 'Tingnan ang Analytics'
                              : 'View Analytics',
                          style: const TextStyle(color: CupertinoColors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AnimatedBuilder(
                animation: ThemeService(),
                builder: (context, _) {
                  return CupertinoButton(
                    onPressed: onScanNow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: ThemeService().currentColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.camera, color: CupertinoColors.white),
                        const SizedBox(width: 8),
                        Text(
                          lang == 'tl'
                              ? LanguageService.translate('scan_now_tl')
                              : LanguageService.translate('scan_now'),
                          style: const TextStyle(color: CupertinoColors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}