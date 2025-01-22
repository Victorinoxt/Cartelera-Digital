import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../screens/dashboard/widgets/logo_widget.dart';

class DesktopMenu extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onNewChart;
  final VoidCallback onSettings;
  final VoidCallback onUploadMedia;
  final VoidCallback onPreview;
  final VoidCallback onSave;

  const DesktopMenu({
    required this.onExport,
    required this.onNewChart,
    required this.onSettings,
    required this.onUploadMedia,
    required this.onPreview,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      style: MenuStyle(
        backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.05)),
        elevation: MaterialStateProperty.all(2),
      ),
      children: [
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: onNewChart,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyN, control: true),
              leadingIcon: const Icon(Icons.add_chart),
              child: const Text('Nuevo Gráfico'),
            ),
            MenuItemButton(
              onPressed: onSave,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true),
              leadingIcon: const Icon(Icons.save),
              child: const Text('Guardar'),
            ),
            MenuItemButton(
              onPressed: onUploadMedia,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyU, control: true),
              leadingIcon: const Icon(Icons.upload_file),
              child: const Text('Subir Media'),
            ),
            const Divider(),
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.history),
                  child: const Text('Proyecto1.chart'),
                  onPressed: () {},
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.history),
                  child: const Text('Proyecto2.chart'),
                  onPressed: () {},
                ),
              ],
              child: const Text('Recientes'),
            ),
            const Divider(),
            MenuItemButton(
              onPressed: onExport,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyE, control: true),
              leadingIcon: const Icon(Icons.file_download),
              child: const Text('Exportar'),
            ),
            const Divider(),
            MenuItemButton(
              onPressed: () => exit(0),
              shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
              leadingIcon: const Icon(Icons.exit_to_app),
              child: const Text('Salir'),
            ),
          ],
          child: const Text('Archivo'),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: onSettings,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyP, control: true),
              leadingIcon: const Icon(Icons.settings),
              child: const Text('Preferencias'),
            ),
            const Divider(),
            MenuItemButton(
              onPressed: onPreview,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyV, control: true),
              leadingIcon: const Icon(Icons.preview),
              child: const Text('Ver Preview'),
            ),
          ],
          child: const Text('Ver'),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () => showAboutDialog(
                context: context,
                applicationName: 'Cartelera Digital',
                applicationVersion: '1.0.0',
                applicationIcon: const LogoWidget(size: 50),
                children: const [
                  Text('Una aplicación para gestionar contenido digital'),
                  SizedBox(height: 8),
                  Text('© 2025 SIMCU. Todos los derechos reservados.'),
                ],
              ),
              leadingIcon: const Icon(Icons.info),
              child: const Text('Acerca de'),
            ),
            MenuItemButton(
              onPressed: () {
                // Implementar apertura de documentación
              },
              leadingIcon: const Icon(Icons.help),
              child: const Text('Documentación'),
            ),
            MenuItemButton(
              onPressed: () {
                // Implementar apertura de tutoriales
              },
              leadingIcon: const Icon(Icons.school),
              child: const Text('Tutoriales'),
            ),
            const Divider(),
            MenuItemButton(
              onPressed: () {
                // Implementar verificación de actualizaciones
              },
              leadingIcon: const Icon(Icons.update),
              child: const Text('Buscar actualizaciones'),
            ),
          ],
          child: const Text('Ayuda'),
        ),
      ],
    );
  }
}