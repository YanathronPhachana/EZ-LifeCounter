import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final int life;
  final int quarterTurns;
  final bool isCompact;
  final bool isVerticalStrip;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int>? onDirectLifeSet;

  // Dice Mode
  final bool showDiceMode;
  final bool isDiceRolling;
  final int? diceValue;
  final String diceType;
  final VoidCallback? onDismissDice;

  const PlayerCard({
    super.key,
    required this.player,
    required this.life,
    this.quarterTurns = 0,
    bool? isRotated,
    this.isCompact = false,
    this.isVerticalStrip = false,
    required this.onIncrement,
    required this.onDecrement,
    this.onDirectLifeSet,
    this.showDiceMode = false,
    this.isDiceRolling = false,
    this.diceValue,
    this.diceType = 'd6',
    this.onDismissDice,
  }) : _legacyIsRotated = isRotated;

  final bool? _legacyIsRotated;

  int get effectiveQuarterTurns =>
      _legacyIsRotated != null ? (_legacyIsRotated ? 2 : 0) : quarterTurns;

  void _showSetLifeDialog(BuildContext context) {
    if (showDiceMode) return;
    final controller = TextEditingController(text: life.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('กำหนดแต้มชีวิต: ${player.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'แต้มพลังชีวิต (HP)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && onDirectLifeSet != null) {
                onDirectLifeSet!(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine high-contrast text and icon color
    final textColor = ThemeData.estimateBrightnessForColor(player.color) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    // Keys for automation testing
    final decKey = (player.id == 'p1' || effectiveQuarterTurns == 2 || effectiveQuarterTurns == 1)
        ? const ValueKey('p1_decrement')
        : const ValueKey('p2_decrement');
    final incKey = (player.id == 'p1' || effectiveQuarterTurns == 2 || effectiveQuarterTurns == 1)
        ? const ValueKey('p1_increment')
        : const ValueKey('p2_increment');

    final borderRadius = BorderRadius.circular(isVerticalStrip ? 16 : (isCompact ? 20 : 28));

    Widget cardContent = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            player.color,
            Color.lerp(player.color, Colors.black, 0.14) ?? player.color,
          ],
        ),
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: player.color.withValues(alpha: 0.38),
            blurRadius: isVerticalStrip ? 6 : (isCompact ? 10 : 16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: showDiceMode
            ? _buildDiceView(context, textColor)
            : _buildNormalHpView(context, textColor, decKey, incKey),
      ),
    );

    if (effectiveQuarterTurns != 0) {
      return RotatedBox(
        quarterTurns: effectiveQuarterTurns,
        child: cardContent,
      );
    }

    return cardContent;
  }

  // 1. Normal View: [-] [ HP ] [+]
  Widget _buildNormalHpView(
    BuildContext context,
    Color textColor,
    Key decKey,
    Key incKey,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;

        // Proportional sizing based on actual card dimensions
        final double iconSize;
        final double maxFontSize;
        final double paddingHoriz;

        if (isVerticalStrip) {
          iconSize = (cardW * 0.22).clamp(16.0, 24.0);
          maxFontSize = (cardW * 0.40).clamp(24.0, 42.0);
          paddingHoriz = (cardW * 0.05).clamp(4.0, 8.0);
        } else if (isCompact) {
          iconSize = (cardW * 0.16).clamp(20.0, 30.0);
          maxFontSize = (cardW * 0.30).clamp(32.0, 52.0);
          paddingHoriz = (cardW * 0.05).clamp(6.0, 14.0);
        } else {
          // Full width (2 players or bottom player in 3-player mode)
          iconSize = (cardW * 0.12).clamp(32.0, 48.0);
          maxFontSize = (cardW * 0.26).clamp(60.0, 92.0);
          paddingHoriz = (cardW * 0.07).clamp(16.0, 28.0);
        }

        return Stack(
          key: const ValueKey('normal_hp_view'),
          children: [
            // Player Name Badge Header (Matching Figma)
            if (player.name.isNotEmpty)
              Positioned(
                top: isVerticalStrip ? 6 : (isCompact ? 8 : 12),
                left: 12,
                right: 12,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact || isVerticalStrip ? 8 : 12,
                        vertical: isCompact || isVerticalStrip ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isVerticalStrip ? 9 : (isCompact ? 11 : 13),
                          fontWeight: FontWeight.w700,
                          color: textColor.withValues(alpha: 0.9),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Visual Layer: [-] [ HP ] [+]
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHoriz),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Minus Sign on Left with subtle glass backing
                      Container(
                        width: iconSize + 8,
                        height: iconSize + 8,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove,
                          size: iconSize,
                          color: textColor.withValues(alpha: 0.95),
                        ),
                      ),

                      // Center Life Number with FittedBox & smooth transition
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 140),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                                  child: FadeTransition(opacity: animation, child: child),
                                );
                              },
                              child: Text(
                                '$life',
                                key: ValueKey<int>(life),
                                style: TextStyle(
                                  fontSize: maxFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  height: 1.0,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Plus Sign on Right with subtle glass backing
                      Container(
                        width: iconSize + 8,
                        height: iconSize + 8,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          size: iconSize,
                          color: textColor.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Interactive Touch Zones: 50% Left (Decrease) and 50% Right (Increase)
            Positioned.fill(
              child: Row(
                children: [
                  // Left 50% Half -> Decrement (-)
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: decKey,
                        splashColor: Colors.black.withValues(alpha: 0.15),
                        highlightColor: Colors.black.withValues(alpha: 0.08),
                        onTap: onDecrement,
                        onLongPress: () => _showSetLifeDialog(context),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),

                  // Right 50% Half -> Increment (+)
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: incKey,
                        splashColor: Colors.black.withValues(alpha: 0.15),
                        highlightColor: Colors.black.withValues(alpha: 0.08),
                        onTap: onIncrement,
                        onLongPress: () => _showSetLifeDialog(context),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 2. Dice View: Images from assets/images for D6 and D20
  Widget _buildDiceView(BuildContext context, Color textColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isD20 = diceType == 'd20';
        final val = diceValue ?? 1;
        final cardW = constraints.maxWidth;
        final cardH = constraints.maxHeight;

        final double imageSize;
        if (isVerticalStrip) {
          imageSize = (cardW * 0.55).clamp(40.0, 55.0);
        } else if (isCompact) {
          imageSize = (cardW * 0.45).clamp(50.0, 75.0);
        } else {
          imageSize = (cardH * 0.45).clamp(80.0, isD20 ? 140.0 : 130.0);
        }

        Widget diceGraphic;
        if (isD20) {
          final d20Val = val.clamp(1, 20);
          diceGraphic = SizedBox(
            width: imageSize,
            height: imageSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/d20.png',
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: isVerticalStrip ? 2 : (isCompact ? 4 : 8)),
                      child: Text(
                        '$d20Val',
                        style: TextStyle(
                          fontSize: (imageSize * 0.26).clamp(12.0, 32.0),
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          final d6Val = val.clamp(1, 6);
          diceGraphic = Image.asset(
            'assets/images/dice$d6Val.png',
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
          );
        }

        return Material(
          key: const ValueKey('dice_view'),
          color: Colors.transparent,
          child: InkWell(
            onTap: isDiceRolling ? null : onDismissDice,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Dice Graphic with glow backing
                  Container(
                    padding: EdgeInsets.all(isVerticalStrip ? 4 : 8),
                    decoration: BoxDecoration(
                      color: isDiceRolling
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedScale(
                      scale: isDiceRolling ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 70),
                      child: diceGraphic,
                    ),
                  ),

                  SizedBox(height: isVerticalStrip ? 4 : (isCompact ? 6 : 12)),

                  // Status Subtitle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isDiceRolling ? 'กำลังสุ่ม...' : 'แตะเพื่อปิด',
                      style: TextStyle(
                        fontSize: isVerticalStrip ? 9 : (isCompact ? 11 : 13),
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
