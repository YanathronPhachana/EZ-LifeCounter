import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DiceDialog extends StatefulWidget {
  final String initialDiceType; // 'd6' or 'd20'
  final ValueChanged<String>? onDiceTypeChanged;

  const DiceDialog({
    super.key,
    this.initialDiceType = 'd6',
    this.onDiceTypeChanged,
  });

  static Future<void> show(
    BuildContext context, {
    String initialDiceType = 'd6',
    ValueChanged<String>? onDiceTypeChanged,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DiceDialog(
        initialDiceType: initialDiceType,
        onDiceTypeChanged: onDiceTypeChanged,
      ),
    );
  }

  @override
  State<DiceDialog> createState() => _DiceDialogState();
}

class _DiceDialogState extends State<DiceDialog> with SingleTickerProviderStateMixin {
  late String _diceType;
  int _currentValue = 1;
  bool _isRolling = false;
  late AnimationController _animController;
  Timer? _rollTimer;

  @override
  void initState() {
    super.initState();
    _diceType = widget.initialDiceType;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _roll();
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  static Random _createSecureRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random(DateTime.now().microsecondsSinceEpoch);
    }
  }

  void _roll() {
    if (_isRolling) return;
    setState(() {
      _isRolling = true;
    });

    _animController.forward(from: 0.0);
    final max = _diceType == 'd20' ? 20 : 6;
    final random = _createSecureRandom();

    int tickCount = 0;
    _rollTimer?.cancel();
    _rollTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      tickCount++;
      setState(() {
        _currentValue = random.nextInt(max) + 1;
      });

      if (tickCount >= 14) {
        timer.cancel();
        final finalRandom = _createSecureRandom();
        setState(() {
          _currentValue = finalRandom.nextInt(max) + 1;
          _isRolling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title & Dice Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ทอดลูกเต๋า',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                // Toggle D6 / D20
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282828) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _TypeButton(
                        label: 'D6',
                        isSelected: _diceType == 'd6',
                        onTap: () {
                          if (_diceType != 'd6') {
                            setState(() => _diceType = 'd6');
                            widget.onDiceTypeChanged?.call('d6');
                            _roll();
                          }
                        },
                      ),
                      _TypeButton(
                        label: 'D20',
                        isSelected: _diceType == 'd20',
                        onTap: () {
                          if (_diceType != 'd20') {
                            setState(() => _diceType = 'd20');
                            widget.onDiceTypeChanged?.call('d20');
                            _roll();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Animated Dice Graphic from Assets
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final angle = _isRolling
                    ? sin(_animController.value * pi * 4) * 0.2
                    : 0.0;
                final scale = _isRolling
                    ? 0.9 + 0.12 * sin(_animController.value * pi * 3).abs()
                    : 1.0;

                Widget graphic;
                if (_diceType == 'd20') {
                  final d20Val = _currentValue.clamp(1, 20);
                  graphic = SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/d20.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '$d20Val',
                                style: const TextStyle(
                                  fontSize: 34,
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
                  final d6Val = _currentValue.clamp(1, 6);
                  graphic = Image.asset(
                    'assets/images/dice$d6Val.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.contain,
                  );
                }

                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: angle,
                    child: graphic,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              _isRolling ? 'กำลังทอย...' : 'ผลลัพธ์: $_currentValue ($_diceType)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey[300] : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('ปิด'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRolling ? null : _roll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                      foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.casino, size: 20),
                    label: const Text('ทอยใหม่', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
