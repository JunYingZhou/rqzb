import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../state/app_settings.dart";

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  void _toggleTheme(WidgetRef ref) {
    final current = ref.read(appThemeModeProvider);
    ref.read(appThemeModeProvider.notifier).state =
        current == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
  }

  void _toggleFontSize(WidgetRef ref) {
    final current = ref.read(appFontSizeProvider);
    final next = switch (current) {
      AppFontSize.small => AppFontSize.medium,
      AppFontSize.medium => AppFontSize.large,
      AppFontSize.large => AppFontSize.small,
    };
    ref.read(appFontSizeProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final fontSize = ref.watch(appFontSizeProvider);

    final themeLabel = themeMode == AppThemeMode.light ? "明色" : "暗色";
    final fontLabel = labelForFontSize(fontSize);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "设置",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                    tooltip: "关闭",
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingTile(
                title: "主题色",
                description: "点击切换明暗模式",
                value: themeLabel,
                onPressed: () => _toggleTheme(ref),
              ),
              const SizedBox(height: 12),
              _SettingTile(
                title: "字体大小",
                description: "点击循环切换大小",
                value: fontLabel,
                onPressed: () => _toggleFontSize(ref),
              ),
              const SizedBox(height: 20),
              Text(
                "提示：主题与字号会影响全局显示。",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B5A60),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.description,
    required this.value,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B5A60),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: onPressed,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

