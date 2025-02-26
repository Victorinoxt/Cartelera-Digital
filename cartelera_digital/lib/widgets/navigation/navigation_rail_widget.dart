import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../screens/dashboard/widgets/logo_widget.dart';
import '../../providers/theme_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationRailWidget extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final double logoSize;
  final double railWidth;

  const NavigationRailWidget({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.logoSize = 48,
    this.railWidth = 72,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isExpanded = ref.watch(sidebarExpandedProvider);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 240 : railWidth,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ref.read(sidebarExpandedProvider.notifier).state = !isExpanded;
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: isExpanded ? 20 : 12,
                ),
                child: Hero(
                  tag: 'logo-rail',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDarkMode 
                          ? Colors.black.withOpacity(0.2) 
                          : Colors.grey.withOpacity(0.05),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: LogoWidget(
                      size: logoSize,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              backgroundColor: Colors.transparent,
              extended: isExpanded,
              minExtendedWidth: 240,
              elevation: null,
              useIndicator: true,
              indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
              labelType: isExpanded ? NavigationRailLabelType.none : NavigationRailLabelType.selected,
              destinations: _buildDestinations(context, isExpanded),
            ),
          ),
          // Botón de cerrar sesión
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 8,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 20,
                      ),
                      if (isExpanded) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cerrar Sesión',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Botón de modo oscuro al final de la barra
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: isExpanded ? 16 : 8,
            ),
            child: _buildThemeToggle(context, isExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isExpanded) {
    return Consumer(
      builder: (context, ref, _) {
        final isDarkMode = ref.watch(themeProvider);
        final theme = Theme.of(context);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
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
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    size: 20,
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
          ),
        );
      },
    );
  }

  List<NavigationRailDestination> _buildDestinations(BuildContext context, bool isExpanded) {
    final destinations = [
      _buildDestination(
        context: context,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Dashboard',
        tooltip: 'Panel Principal',
        color: const Color(0xFF1E88E5),
        isExpanded: isExpanded,
      ),
      _buildDestination(
        context: context,
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: 'Gráficos',
        tooltip: 'Gestión de Gráficos',
        color: const Color(0xFF43A047),
        isExpanded: isExpanded,
      ),
      _buildDestination(
        context: context,
        icon: Icons.perm_media_outlined,
        selectedIcon: Icons.perm_media,
        label: 'Media',
        tooltip: 'Gestión de Media',
        color: const Color(0xFFFB8C00),
        isExpanded: isExpanded,
      ),
      _buildDestination(
        context: context,
        icon: Icons.monitor_outlined,
        selectedIcon: Icons.monitor,
        label: 'Monitoreo',
        tooltip: 'Monitoreo de Subidas',
        color: const Color(0xFF6D4C41),
        isExpanded: isExpanded,
      ),
    ];
    
    return destinations;
  }

  NavigationRailDestination _buildDestination({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String tooltip,
    required Color color,
    required bool isExpanded,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    Widget iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        icon,
        key: ValueKey(icon),
        color: isDarkMode ? Colors.white70 : Colors.black54,
        size: 24,
      ),
    );

    if (!isExpanded) {
      iconWidget = Tooltip(
        message: tooltip,
        preferBelow: false,
        verticalOffset: 8,
        child: iconWidget,
      );
    }
    
    return NavigationRailDestination(
      icon: iconWidget,
      selectedIcon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          selectedIcon,
          key: ValueKey(selectedIcon),
          color: color,
          size: 24,
        ),
      ),
      label: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: isExpanded ? 20 : 0,
      ),
    );
  }
}
