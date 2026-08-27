import 'package:flutter/material.dart';
import '../controllers/game_scope.dart';
import '../screens/setting_screen.dart';

class CenterControlBar extends StatelessWidget {
  const CenterControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Dice Button (Direct In-Card Roll)
          _IconButtonCard(
            onTap: () {
              controller.startDiceRoll();
            },
            tooltip: 'สุ่มลูกเต๋า',
            child: _DiceIcon(color: iconColor),
          ),

          // 2. Reset Button (Double Tap to Reset)
          _IconButtonCard(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('แตะ 2 ครั้ง (Double Tap) เพื่อรีเซ็ตแต้มชีวิต'),
                  duration: Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onDoubleTap: () {
              controller.resetGame();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('รีเซ็ตแต้มชีวิตเป็น ${controller.defaultStartingHp} เรียบร้อยแล้ว'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green[700],
                ),
              );
            },
            tooltip: 'แตะ 2 ครั้งเพื่อรีเซ็ต',
            child: Icon(Icons.sync_rounded, size: 42, color: iconColor),
          ),

          // 3. Settings Button
          _IconButtonCard(
            onTap: () {
              controller.exitDiceMode();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const SettingScreen()),
              );
            },
            tooltip: 'การตั้งค่า',
            child: Icon(Icons.settings_rounded, size: 40, color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _IconButtonCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final String? tooltip;
  final Widget child;

  const _IconButtonCard({
    required this.onTap,
    this.onDoubleTap,
    this.tooltip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          highlightColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          child: Ink(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF64748B)).withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _DiceIcon extends StatelessWidget {
  final Color color;

  const _DiceIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2.5),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center dot
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          // Top-left
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          // Top-right
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          // Bottom-left
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          // Bottom-right
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
