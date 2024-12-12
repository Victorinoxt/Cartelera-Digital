import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

final sidebarExpandedProvider = StateProvider<bool>((ref) => true);
final selectedIndexProvider = StateProvider<int>((ref) => 0);

<<<<<<< HEAD
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 250,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: _buildNavItems(context),
          ),
          _buildThemeToggle(context),
=======
class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final selectedIndex = ref.watch(selectedIndexProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: isExpanded ? 280 : 70,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, isExpanded, ref),
          const SizedBox(height: 16),
          Expanded(
            child: _buildNavItems(context, isExpanded, selectedIndex, ref),
          ),
          _buildThemeToggle(context, isExpanded, ref),
>>>>>>> origin/main
          const SizedBox(height: 16),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildHeader(BuildContext context) {
=======
  Widget _buildHeader(BuildContext context, bool isExpanded, WidgetRef ref) {
>>>>>>> origin/main
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ref.read(sidebarExpandedProvider.notifier).state = !isExpanded;
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.1) 
                  : Colors.grey.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isExpanded ? 160 : 40,
                  height: 40,
                  child: Image.asset(
                    'assets/images/Logo_SIMCUV.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: theme.iconTheme.color?.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildNavItems(BuildContext context) {
=======
  Widget _buildNavItems(BuildContext context, bool isExpanded, int selectedIndex, WidgetRef ref) {
>>>>>>> origin/main
    final items = [
      _NavItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Dashboard',
        color: const Color(0xFF1E88E5),
      ),
      _NavItem(
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: 'Gráficos',
        color: const Color(0xFF43A047),
      ),
      _NavItem(
        icon: Icons.perm_media_outlined,
        selectedIcon: Icons.perm_media,
        label: 'Media',
        color: const Color(0xFFFB8C00),
      ),
      _NavItem(
        icon: Icons.monitor_outlined,
        selectedIcon: Icons.monitor,
        label: 'Monitoreo',
        color: const Color(0xFF6D4C41),
      ),
    ];

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        return _buildNavItem(
          context, 
          items[index], 
<<<<<<< HEAD
=======
          isExpanded, 
>>>>>>> origin/main
          index == selectedIndex,
          () => ref.read(selectedIndexProvider.notifier).state = index,
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, 
    _NavItem item, 
<<<<<<< HEAD
=======
    bool isExpanded, 
>>>>>>> origin/main
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? item.color.withOpacity(0.1) : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 8,
          vertical: 4,
        ),
        leading: Icon(
          isSelected ? item.selectedIcon : item.icon,
          color: isSelected ? item.color : Theme.of(context).iconTheme.color?.withOpacity(0.7),
        ),
        title: isExpanded
            ? Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? item.color : Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildThemeToggle(BuildContext context) {
=======
  Widget _buildThemeToggle(BuildContext context, bool isExpanded, WidgetRef ref) {
>>>>>>> origin/main
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode 
              ? Colors.black.withOpacity(0.2) 
              : Colors.grey.withOpacity(0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 20,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isDarkMode,
                onChanged: (_) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
  });
}
