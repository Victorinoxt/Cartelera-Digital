import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DrawerWidget({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            child: Center(
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
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            selected: selectedIndex == 0,
            selectedColor: theme.colorScheme.primary,
            leading: Icon(
              selectedIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined,
              color: selectedIndex == 0 
                  ? theme.colorScheme.primary 
                  : isDarkMode ? Colors.white70 : Colors.black87,
            ),
            title: Text(
              'Dashboard',
              style: TextStyle(
                color: selectedIndex == 0 
                    ? theme.colorScheme.primary 
                    : isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            onTap: () {
              onDestinationSelected(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: selectedIndex == 1,
            selectedColor: theme.colorScheme.primary,
            leading: Icon(
              selectedIndex == 1 ? Icons.bar_chart : Icons.bar_chart_outlined,
              color: selectedIndex == 1 
                  ? theme.colorScheme.primary 
                  : isDarkMode ? Colors.white70 : Colors.black87,
            ),
            title: Text(
              'Gráficos',
              style: TextStyle(
                color: selectedIndex == 1 
                    ? theme.colorScheme.primary 
                    : isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            onTap: () {
              onDestinationSelected(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: selectedIndex == 2,
            selectedColor: theme.colorScheme.primary,
            leading: Icon(
              selectedIndex == 2 ? Icons.perm_media : Icons.perm_media_outlined,
              color: selectedIndex == 2 
                  ? theme.colorScheme.primary 
                  : isDarkMode ? Colors.white70 : Colors.black87,
            ),
            title: Text(
              'Media',
              style: TextStyle(
                color: selectedIndex == 2 
                    ? theme.colorScheme.primary 
                    : isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            onTap: () {
              onDestinationSelected(2);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}