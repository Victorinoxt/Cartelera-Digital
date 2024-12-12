import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcutsService {
  static final Map<ShortcutActivator, VoidCallback> _shortcuts = {};

  static void registerShortcuts({
    required VoidCallback onExport,
    required VoidCallback onNewChart,
    required VoidCallback onSave,
    required VoidCallback onUploadMedia,
    required VoidCallback onPreview,
    required VoidCallback onSettings,
  }) {
    _shortcuts.clear();
    _shortcuts[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE)] = onExport;
    _shortcuts[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN)] = onNewChart;
    _shortcuts[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS)] = onSave;
    _shortcuts[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyU)] = onUploadMedia;
    _shortcuts[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV)] = onPreview;
    _shortcuts[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP)] = onSettings;
  }

  static Widget wrapWithShortcuts(Widget child) {
    return Shortcuts(
      shortcuts: _shortcuts.map(
        (key, value) => MapEntry(key, VoidCallbackIntent()),
      ),
      child: Actions(
        actions: {
          VoidCallbackIntent: CallbackAction<VoidCallbackIntent>(
            onInvoke: (intent) {
              for (final entry in _shortcuts.entries) {
                if (entry.key is LogicalKeySet &&
                    (entry.key as LogicalKeySet).keys.every(
                      (k) => RawKeyboard.instance.keysPressed.contains(k),
                    )) {
                  entry.value.call();
                  break;
                }
              }
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class VoidCallbackIntent extends Intent {
  const VoidCallbackIntent();
}