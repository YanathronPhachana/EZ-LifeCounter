import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerEditDialog extends StatefulWidget {
  final Player? player;
  final int defaultHp;
  final Function(String name, Color color, int startingLife) onSave;

  const PlayerEditDialog({
    super.key,
    this.player,
    this.defaultHp = 10,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    Player? player,
    int defaultHp = 10,
    required Function(String name, Color color, int startingLife) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => PlayerEditDialog(
        player: player,
        defaultHp: defaultHp,
        onSave: onSave,
      ),
    );
  }

  @override
  State<PlayerEditDialog> createState() => _PlayerEditDialogState();
}

class _PlayerEditDialogState extends State<PlayerEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _lifeController;
  late Color _selectedColor;

  static const List<Color> availableColors = [
    Color(0xFF00A3E0), // Cyan/Blue
    Color(0xFFD32F2F), // Red
    Color(0xFF2E7D32), // Green
    Color(0xFFEF6C00), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF009688), // Teal
    Color(0xFFE91E63), // Pink
    Color(0xFFFFB300), // Amber
    Color(0xFF3F51B5), // Indigo
    Color(0xFF455A64), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player?.name ?? '');
    _lifeController = TextEditingController(
      text: (widget.player?.startingLife ?? widget.defaultHp).toString(),
    );
    _selectedColor = widget.player?.color ?? availableColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lifeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.player != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Text(
        isEditing ? 'แก้ไขผู้เล่น' : 'เพิ่มผู้เล่นใหม่',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อผู้เล่น',
                hintText: 'กรอกชื่อผู้เล่น',
                filled: true,
                fillColor: isDark ? const Color(0xFF282828) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF404040) : const Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF383838) : const Color(0xFFE2E8F0)),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Starting Life (HP เริ่มต้น)
            TextField(
              controller: _lifeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'HP เริ่มต้น',
                hintText: '${widget.defaultHp}',
                filled: true,
                fillColor: isDark ? const Color(0xFF282828) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF404040) : const Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF383838) : const Color(0xFFE2E8F0)),
                ),
                prefixIcon: const Icon(Icons.favorite_outline),
              ),
            ),
            const SizedBox(height: 20),

            // Color Selector Header
            const Text(
              'เลือกสีประจำตัว',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Color palette
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableColors.map((color) {
                final isSelected = _selectedColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: isSelected ? 0.6 : 0.25),
                          blurRadius: isSelected ? 10 : 4,
                          spreadRadius: isSelected ? 2 : 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () {
            final entered = _nameController.text.trim();
            final name = entered.isEmpty
                ? (widget.player?.name ?? 'ผู้เล่นใหม่')
                : entered;
            final life = int.tryParse(_lifeController.text) ?? widget.defaultHp;

            widget.onSave(name, _selectedColor, life);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : const Color(0xFF2563EB),
            foregroundColor: isDark ? Colors.black87 : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('บันทึก', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
