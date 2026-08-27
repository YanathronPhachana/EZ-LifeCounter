import 'package:flutter/material.dart';
import 'game_controller.dart';

class GameScope extends InheritedNotifier<GameController> {
  const GameScope({
    super.key,
    required GameController controller,
    required super.child,
  }) : super(notifier: controller);

  static GameController of(BuildContext context) {
    final GameScope? scope = context.dependOnInheritedWidgetOfExactType<GameScope>();
    assert(scope != null, 'No GameScope found in context');
    return scope!.notifier!;
  }
}
