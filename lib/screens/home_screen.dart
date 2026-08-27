import 'package:flutter/material.dart';
import '../controllers/game_scope.dart';
import '../models/player.dart';
import '../widgets/player_card.dart';
import '../widgets/center_control_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final active = controller.activePlayers;
    final count = active.length;

    // Layout configuration based precisely on ForNeed/playerGridDesign.png
    final int topCount;
    final int bottomCount;
    final int topQuarterTurns;
    final int bottomQuarterTurns;

    if (count == 2) {
      topCount = 1;
      bottomCount = 1;
      topQuarterTurns = 2; // 180 deg
      bottomQuarterTurns = 0; // 0 deg
    } else if (count == 3) {
      topCount = 2;
      bottomCount = 1;
      topQuarterTurns = 2; // 180 deg
      bottomQuarterTurns = 0; // 0 deg
    } else if (count == 4) {
      topCount = 2;
      bottomCount = 2;
      topQuarterTurns = 2; // 180 deg
      bottomQuarterTurns = 0; // 0 deg
    } else if (count == 5) {
      topCount = 3;
      bottomCount = 2;
      topQuarterTurns = 1; // 90 deg (- at top, + at bottom)
      bottomQuarterTurns = 0; // 0 deg (- at left, + at right)
    } else {
      // 6 players
      topCount = 3;
      bottomCount = 3;
      topQuarterTurns = 1; // 90 deg (- at top, + at bottom)
      bottomQuarterTurns = 3; // 270 deg (+ at top, - at bottom)
    }

    final topPlayers = active.sublist(0, topCount);
    final bottomPlayers = active.sublist(topCount, topCount + bottomCount);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            children: [
              // 1. Top Section
              Expanded(
                child: Row(
                  children: topPlayers.map((player) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildPlayerCard(
                          context,
                          player: player,
                          quarterTurns: topQuarterTurns,
                          isCompact: topCount > 1,
                          isVerticalStrip: topCount >= 3,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 2. Center Control Bar (Dice, Reset, Settings)
              const CenterControlBar(),

              // 3. Bottom Section
              Expanded(
                child: Row(
                  children: bottomPlayers.map((player) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildPlayerCard(
                          context,
                          player: player,
                          quarterTurns: bottomQuarterTurns,
                          isCompact: bottomCount > 1,
                          isVerticalStrip: bottomCount >= 3,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
    BuildContext context, {
    required Player player,
    required int quarterTurns,
    required bool isCompact,
    required bool isVerticalStrip,
  }) {
    final controller = GameScope.of(context);
    final life = controller.getPlayerLife(player);
    final diceVal = controller.getPlayerDiceValue(player);

    return PlayerCard(
      player: player,
      life: life,
      quarterTurns: quarterTurns,
      isCompact: isCompact,
      isVerticalStrip: isVerticalStrip,
      onIncrement: () => controller.changePlayerLife(player, 1),
      onDecrement: () => controller.changePlayerLife(player, -1),
      onDirectLifeSet: (val) {
        controller.setPlayerLife(player, val);
      },
      showDiceMode: controller.showDiceMode,
      isDiceRolling: controller.isDiceRolling,
      diceValue: diceVal,
      diceType: controller.diceType,
      onDismissDice: () => controller.exitDiceMode(),
    );
  }
}
