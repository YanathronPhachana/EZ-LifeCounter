import 'package:flutter/material.dart';
import '../controllers/game_scope.dart';
import '../widgets/player_edit_dialog.dart';
import '../widgets/feedback_dialog.dart';
import 'history_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  void _showCustomHpDialog(BuildContext context) {
    final controller = GameScope.of(context);
    final textController = TextEditingController(text: controller.defaultStartingHp.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('กำหนด HP เริ่มต้น'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'HP เริ่มต้น',
            hintText: 'กรอกตัวเลข HP ที่ต้องการ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(textController.text);
              if (val != null && val > 0) {
                controller.setDefaultStartingHp(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showPatchLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Patch Log', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Version 2.0.0 (Major Release)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('✨ ดีไซน์ UI/UX ใหม่ระดับพรีเมียม สไตล์ Modern Minimalist สะอาดตา สบายตายิ่งขึ้น'),
              Text('🎲 ยกระดับการสุ่มลูกเต๋าเป็น True Random (CSPRNG) ไร้การคาดเดาและยุติธรรมสูงสุด'),
              Text('👥 ปรับระบบจำนวนผู้เล่นอัตโนมัติ 2–6 คน เชื่อมต่อกับรายชื่อผู้เล่นโดยตรง'),
              Text('📐 จัด Grid เลย์เอาต์ตาม playerGridDesign แบบสมบูรณ์แบบ 100%'),
              Text('⚡ ระบบ Responsive Auto-scaling ป้องกันการล้นขอบจอในทุกขนาดอุปกรณ์'),
              Text('🔄 แอนิเมชันตัวเลข HP ลื่นไหล พร้อมระบบแตะแบ่งครึ่ง 50/50 รวดเร็วและแม่นยำ'),
              Text('⚙️ กำหนดค่า HP เริ่มต้นแบบกำหนดเอง 100% พร้อมระบบบันทึกค่าในตัว'),
              Text('🎨 ธีมระดับพรีเมียม 3 สไตล์: Dark, Slate Gray, Light'),
              Text('🛡️ Double Tap เพื่อ Reset แต้ม ป้องกันการกดพลาดระหว่างแข่งขัน'),
              Text('📜 ระบบบันทึกประวัติการเล่น (History Log) พร้อมล้างอัตโนมัติเมื่อเริ่มเกมใหม่'),
              Text('📩 ระบบฟอร์มแจ้งข้อเสนอแนะ (Feedback) ส่งตรงถึงผู้พัฒนาทันที'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    FeedbackDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // 1. SECTION: รายชื่อผู้เล่น (Player List - Automatically sets Player Count)
          _buildSectionHeader(
            context,
            icon: Icons.people_alt_outlined,
            title: 'รายชื่อผู้เล่น (${controller.players.length} คน)',
            subtitle: 'จำนวนผู้เล่นในเกมจะเปลี่ยนตามรายชื่อ (2–6 คน)',
            action: OutlinedButton.icon(
              onPressed: controller.canAddPlayer
                  ? () {
                      PlayerEditDialog.show(
                        context,
                        defaultHp: controller.defaultStartingHp,
                        onSave: (name, color, life) {
                          controller.addPlayer(name, color, startingLife: life);
                        },
                      );
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(
                  color: controller.canAddPlayer
                      ? (isDark ? Colors.white70 : Colors.black87)
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              ),
              icon: const Text('เพิ่มผู้เล่น', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              label: const Icon(Icons.add, size: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Player list items (Reorderable / Positionable)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.players.length,
            // ignore: deprecated_member_use
            onReorder: (oldIndex, newIndex) {
              controller.reorderPlayers(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final player = controller.players[index];
              final slotNum = index + 1;

              return Container(
                key: ValueKey(player.id),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: player.color.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : const Color(0xFF64748B)).withValues(alpha: isDark ? 0.25 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Drag Handle
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.drag_indicator,
                          size: 22,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ),

                    // Slot Indicator
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: player.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'P$slotNum',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: player.color,
                        ),
                      ),
                    ),

                    // Player Name & HP
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'HP เริ่มต้น: ${player.startingLife}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Color dot with inner border
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: player.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: player.color.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'แก้ไขผู้เล่น',
                      onPressed: () {
                        PlayerEditDialog.show(
                          context,
                          player: player,
                          defaultHp: controller.defaultStartingHp,
                          onSave: (name, color, life) {
                            controller.updatePlayer(player.id, name, color, life);
                          },
                        );
                      },
                    ),

                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: controller.canDeletePlayer ? 'ลบผู้เล่น' : 'ต้องมีอย่างน้อย 2 คน',
                      color: controller.canDeletePlayer ? Colors.redAccent : Colors.grey.withValues(alpha: 0.35),
                      onPressed: controller.canDeletePlayer
                          ? () {
                              controller.deletePlayer(player.id);
                            }
                          : null,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          // 2. SECTION: HP เริ่มต้น (Custom defined 100%)
          _buildSectionHeader(
            context,
            icon: Icons.favorite_outline,
            title: 'HP เริ่มต้น',
            subtitle: 'กำหนดค่า HP สำหรับเริ่มเกมและการ Reset เลือด',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF64748B)).withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Label and direct edit button
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCustomHpDialog(context),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.blueAccent : Colors.blue).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.edit_note, color: isDark ? Colors.blueAccent : Colors.blue[700], size: 20),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'กำหนดค่า HP เอง',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'แตะเพื่อพิมพ์ตัวเลข',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Stepper [-] [ HP ] [+]
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 26),
                      tooltip: 'ลด HP เริ่มต้น 1',
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                      onPressed: controller.defaultStartingHp > 1
                          ? () => controller.setDefaultStartingHp(controller.defaultStartingHp - 1)
                          : null,
                    ),
                    GestureDetector(
                      onTap: () => _showCustomHpDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF444444) : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${controller.defaultStartingHp}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 26),
                      tooltip: 'เพิ่ม HP เริ่มต้น 1',
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                      onPressed: () => controller.setDefaultStartingHp(controller.defaultStartingHp + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 3. SECTION: ธีม (Theme)
          _buildSectionHeader(
            context,
            icon: Icons.palette_outlined,
            title: 'ธีม',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ThemeOptionButton(
                title: 'Gray',
                color: const Color(0xFF38414E),
                isSelected: controller.themeMode == 'gray',
                onTap: () => controller.setThemeMode('gray'),
              ),
              const SizedBox(width: 12),
              _ThemeOptionButton(
                title: 'Dark',
                color: const Color(0xFF1E1E1E),
                isSelected: controller.themeMode == 'dark',
                onTap: () => controller.setThemeMode('dark'),
              ),
              const SizedBox(width: 12),
              _ThemeOptionButton(
                title: 'Light',
                color: Colors.white,
                hasBorder: true,
                isSelected: controller.themeMode == 'light',
                onTap: () => controller.setThemeMode('light'),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // 4. SECTION: ประเภทลูกเต๋า (Dice Type)
          _buildSectionHeader(
            context,
            icon: Icons.casino_outlined,
            title: 'ประเภทลูกเต๋า',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFCBD5E1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setDiceType('d6'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: controller.diceType == 'd6'
                            ? (isDark ? const Color(0xFF333333) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: controller.diceType == 'd6'
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.casino, size: 20),
                          SizedBox(width: 8),
                          Text('ลูกเต๋า 6 หน้า (D6)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setDiceType('d20'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: controller.diceType == 'd20'
                            ? (isDark ? const Color(0xFF333333) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: controller.diceType == 'd20'
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hexagon_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('ลูกเต๋า 20 หน้า (D20)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 5. GROUPED SECTION: ข้อมูลทั่วไปและการนำทาง
          Material(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF64748B)).withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ประวัติการเล่น
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history, color: Colors.purple, size: 20),
                    ),
                    title: const Text(
                      'ประวัติการเล่น',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const HistoryScreen()),
                      );
                    },
                  ),
                  const Divider(indent: 56, height: 1),

                  // Version
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    ),
                    title: const Text(
                      'Version',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '2.0.0',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ),
                  const Divider(indent: 56, height: 1),

                  // Patch Log
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.article_outlined, color: Colors.amber, size: 20),
                    ),
                    title: const Text(
                      'Patch Log',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showPatchLogDialog(context),
                  ),
                  const Divider(indent: 56, height: 1),

                  // Feedback
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.email_outlined, color: Colors.redAccent, size: 20),
                    ),
                    title: const Text(
                      'Feedback',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showFeedbackDialog(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon, size: 18, color: isDark ? Colors.blueAccent : Colors.blue[700]),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 8),
              action,
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  final String title;
  final Color color;
  final bool hasBorder;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionButton({
    required this.title,
    required this.color,
    this.hasBorder = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF388AF6)
                  : (hasBorder ? const Color(0xFFCBD5E1) : Colors.transparent),
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF388AF6).withValues(alpha: 0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Center(
            child: isSelected
                ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF388AF6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
