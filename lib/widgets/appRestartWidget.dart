import 'package:flutter/material.dart';

class AppRestartWidget extends StatefulWidget {
  final Widget child;

  const AppRestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartWidgetState>()?.restartApp();
  }

  @override
  State<AppRestartWidget> createState() => _AppRestartWidgetState();
}

class _AppRestartWidgetState extends State<AppRestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
