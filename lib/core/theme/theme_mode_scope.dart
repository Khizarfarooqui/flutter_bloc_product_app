import 'package:flutter/material.dart';

class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ThemeModeScope extends InheritedNotifier<ThemeModeNotifier> {
  const ThemeModeScope({
    super.key,
    required ThemeModeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeModeNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
    assert(scope != null, 'ThemeModeScope not found. Wrap app with ThemeModeScope.');
    return scope!.notifier!;
  }
}
