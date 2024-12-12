import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      tooltip: isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
    );
  }
}