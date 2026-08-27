import 'package:flutter/material.dart';

class Player {
  final String id;
  String name;
  Color color;
  int startingLife;

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.startingLife = 10,
  });

  Player copyWith({
    String? id,
    String? name,
    Color? color,
    int? startingLife,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      startingLife: startingLife ?? this.startingLife,
    );
  }
}

class HistoryEntry {
  final DateTime timestamp;
  final String playerName;
  final int change;
  final int resultingLife;
  final String description;

  HistoryEntry({
    required this.timestamp,
    required this.playerName,
    required this.change,
    required this.resultingLife,
    required this.description,
  });
}
