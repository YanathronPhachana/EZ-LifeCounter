import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';

class GameController extends ChangeNotifier {
  int _defaultStartingHp = 10;

  static const List<Color> defaultColors = [
    Color(0xFF00A3E0), // Cyan/Blue (P1)
    Color(0xFFD32F2F), // Red (P2)
    Color(0xFF2E7D32), // Green (P3)
    Color(0xFFEF6C00), // Orange (P4)
    Color(0xFF7B1FA2), // Purple (P5)
    Color(0xFF009688), // Teal (P6)
    Color(0xFFE91E63), // Pink
    Color(0xFF3F51B5), // Indigo
    Color(0xFFFFB300), // Amber
    Color(0xFF455A64), // Blue Grey
  ];

  // Default starting list has 2 players
  final List<Player> _players = [
    Player(id: 'p1', name: 'Tomson', color: const Color(0xFF00A3E0), startingLife: 10),
    Player(id: 'p2', name: 'Eddy', color: const Color(0xFFD32F2F), startingLife: 10),
  ];

  final Map<String, int> _playerLives = {};
  final Map<String, int> _playerDiceValues = {};

  String _diceType = 'd6'; // 'd6' or 'd20'
  String _themeMode = 'light'; // 'gray', 'dark', 'light'
  final List<HistoryEntry> _history = [];

  // Dice Mode states
  bool _showDiceMode = false;
  bool _isDiceRolling = false;
  Timer? _diceTimer;

  GameController() {
    _initLivesAndDice();
  }

  void _initLivesAndDice() {
    for (var p in _players) {
      _playerLives.putIfAbsent(p.id, () => p.startingLife);
      _playerDiceValues.putIfAbsent(p.id, () => 1);
    }
  }

  @override
  void dispose() {
    _diceTimer?.cancel();
    super.dispose();
  }

  // Getters
  List<Player> get players => List.unmodifiable(_players);
  List<Player> get activePlayers => List.unmodifiable(_players);
  int get playerCount => _players.length;

  // Backward compatibility getters
  Player get player1 => _players.isNotEmpty ? _players[0] : Player(id: 'p1', name: 'P1', color: Colors.blue);
  Player get player2 => _players.length > 1 ? _players[1] : player1;
  int get player1Life => getPlayerLife(player1);
  int get player2Life => getPlayerLife(player2);
  int get player1DiceValue => getPlayerDiceValue(player1);
  int get player2DiceValue => getPlayerDiceValue(player2);

  int get defaultStartingHp => _defaultStartingHp;
  String get diceType => _diceType;
  String get themeMode => _themeMode;
  List<HistoryEntry> get history => List.unmodifiable(_history);

  bool get showDiceMode => _showDiceMode;
  bool get isDiceRolling => _isDiceRolling;

  // Life operations
  int getPlayerLife(Player player) {
    return _playerLives[player.id] ?? _defaultStartingHp;
  }

  int getPlayerDiceValue(Player player) {
    return _playerDiceValues[player.id] ?? 1;
  }

  void changePlayerLife(Player player, int delta) {
    if (_showDiceMode) {
      exitDiceMode();
      return;
    }
    final current = getPlayerLife(player);
    final updated = current + delta;
    _playerLives[player.id] = updated;

    _addHistory(
      playerName: player.name,
      change: delta,
      resultingLife: updated,
      description: delta > 0 ? '+$delta แต้มพลังชีวิต' : '$delta แต้มพลังชีวิต',
    );
    notifyListeners();
  }

  void setPlayerLife(Player player, int newLife) {
    if (_showDiceMode) {
      exitDiceMode();
      return;
    }
    final current = getPlayerLife(player);
    final delta = newLife - current;
    _playerLives[player.id] = newLife;

    _addHistory(
      playerName: player.name,
      change: delta,
      resultingLife: newLife,
      description: 'กำหนดแต้มพลังชีวิตเป็น $newLife',
    );
    notifyListeners();
  }

  // Backward compatibility methods
  void changePlayer1Life(int delta) => changePlayerLife(player1, delta);
  void changePlayer2Life(int delta) => changePlayerLife(player2, delta);

  void setDefaultStartingHp(int hp) {
    if (hp > 0 && _defaultStartingHp != hp) {
      _defaultStartingHp = hp;
      for (var p in _players) {
        p.startingLife = hp;
      }
      for (var key in _playerLives.keys) {
        _playerLives[key] = hp;
      }
      notifyListeners();
    }
  }

  void resetGame() {
    exitDiceMode();
    for (var p in _players) {
      _playerLives[p.id] = _defaultStartingHp;
    }
    _history.clear();
    notifyListeners();
  }

  static Random _createSecureRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random(DateTime.now().microsecondsSinceEpoch);
    }
  }

  // Dice roll operations directly on Player Cards (Cryptographically Secure)
  void startDiceRoll() {
    _showDiceMode = true;
    _isDiceRolling = true;
    notifyListeners();

    final max = _diceType == 'd20' ? 20 : 6;
    final random = _createSecureRandom();

    int tickCount = 0;
    _diceTimer?.cancel();
    _diceTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      tickCount++;
      for (var p in _players) {
        _playerDiceValues[p.id] = random.nextInt(max) + 1;
      }
      notifyListeners();

      if (tickCount >= 16) {
        timer.cancel();
        final results = <String>[];
        final finalRandom = _createSecureRandom();
        for (var p in _players) {
          final rollVal = finalRandom.nextInt(max) + 1;
          _playerDiceValues[p.id] = rollVal;
          results.add('${p.name}: $rollVal');
        }
        _isDiceRolling = false;

        _addHistory(
          playerName: 'ทอดลูกเต๋า (${_diceType.toUpperCase()})',
          change: 0,
          resultingLife: 0,
          description: results.join(' | '),
        );
        notifyListeners();
      }
    });
  }

  void exitDiceMode() {
    _diceTimer?.cancel();
    if (_showDiceMode || _isDiceRolling) {
      _showDiceMode = false;
      _isDiceRolling = false;
      notifyListeners();
    }
  }

  int rollDice() {
    final random = _createSecureRandom();
    final max = _diceType == 'd20' ? 20 : 6;
    return random.nextInt(max) + 1;
  }

  void setDiceType(String type) {
    if (_diceType != type) {
      _diceType = type;
      notifyListeners();
    }
  }

  void setThemeMode(String mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  // Player management: player count changes dynamically based on player list size (min 2, max 6)
  bool get canAddPlayer => _players.length < 6;
  bool get canDeletePlayer => _players.length > 2;

  void addPlayer(String name, Color color, {int? startingLife}) {
    if (_players.length >= 6) return;

    final nextIndex = _players.length;
    final newPlayer = Player(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Player ${nextIndex + 1}' : name.trim(),
      color: color,
      startingLife: startingLife ?? _defaultStartingHp,
    );
    _players.add(newPlayer);
    _playerLives[newPlayer.id] = newPlayer.startingLife;
    _playerDiceValues[newPlayer.id] = 1;
    notifyListeners();
  }

  void updatePlayer(String id, String name, Color color, int startingLife) {
    final index = _players.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = _players[index].copyWith(
        name: name.trim().isEmpty ? _players[index].name : name.trim(),
        color: color,
        startingLife: startingLife,
      );
      _players[index] = updated;
      notifyListeners();
    }
  }

  void deletePlayer(String id) {
    if (_players.length <= 2) return; // Maintain at least 2 players
    final index = _players.indexWhere((p) => p.id == id);
    if (index != -1) {
      final removed = _players.removeAt(index);
      _playerLives.remove(removed.id);
      _playerDiceValues.remove(removed.id);
      notifyListeners();
    }
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final player = _players.removeAt(oldIndex);
    _players.insert(newIndex, player);
    notifyListeners();
  }

  void _addHistory({
    required String playerName,
    required int change,
    required int resultingLife,
    required String description,
  }) {
    _history.insert(
      0,
      HistoryEntry(
        timestamp: DateTime.now(),
        playerName: playerName,
        change: change,
        resultingLife: resultingLife,
        description: description,
      ),
    );
    if (_history.length > 100) {
      _history.removeLast();
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
