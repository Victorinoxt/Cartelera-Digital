import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/theme_toggle_button.dart';

class DrawerWidget extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DrawerWidget({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return Drawer(
      backgroundColor: isDarkMode ? theme.colorScheme.surface : Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Hero(
                    tag: 'logo-drawer',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? theme.colorScheme.surface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/Logo_SIMCUV.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.username,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    user.role,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            selected: selectedIndex == 0,
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              onDestinationSelected(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: selectedIndex == 1,
            leading: const Icon(Icons.movie),
            title: const Text('Medios'),
            onTap: () {
              onDestinationSelected(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: selectedIndex == 2,
            leading: const Icon(Icons.bar_chart),
            title: const Text('Gráficos'),
            onTap: () {
              onDestinationSelected(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: selectedIndex == 3,
            leading: const Icon(Icons.monitor),
            title: const Text('Monitoreo'),
            onTap: () {
              onDestinationSelected(3);
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const ThemeToggleButton(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}