import 'package:flutter/material.dart';

class DrawerScope extends InheritedWidget {
  const DrawerScope({
    super.key,
    required this.scaffoldKey,
    required super.child,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  static GlobalKey<ScaffoldState>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DrawerScope>()
        ?.scaffoldKey;
  }

  static void openDrawer(BuildContext context) {
    DrawerScope.of(context)?.currentState?.openDrawer();
  }

  @override
  bool updateShouldNotify(DrawerScope oldWidget) =>
      scaffoldKey != oldWidget.scaffoldKey;
}
