import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const FeedbackDialog(),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  static const String targetEmail = 'yanathronp@gmail.com';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกรายละเอียด Feedback ก่อนกดส่ง'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final subject = _subjectController.text.trim().isEmpty
        ? 'Feedback สำหรับแอป Buddy Fight Life Counter'
        : _subjectController.text.trim();

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: targetEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': message,
      }),
    );

    try {
      final launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );

      if (mounted) {
        Navigator.pop(context);
        if (launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กำลังเปิดแอปอีเมลเพื่อส่ง Feedback...'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _fallbackCopy(message);
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        _fallbackCopy(message);
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _fallbackCopy(String message) {
    Clipboard.setData(ClipboardData(text: 'ถึง: $targetEmail\nข้อความ:\n$message'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกข้อความ Feedback และอีเมล $targetEmail ลงคลิปบอร์ดแล้ว'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.email_rounded, color: Colors.redAccent, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'ส่งข้อเสนอแนะ (Feedback)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination email info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF383838) : const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.send_rounded, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'ส่งถึง: ',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    targetEmail,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subject field
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'หัวข้อข้อเสนอแนะ (ไม่บังคับ)',
                hintText: 'เช่น เสนอแนะฟีเจอร์ใหม่, แจ้งปัญหา',
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
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 14),

            // Message detail field
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'รายละเอียด Feedback *',
                hintText: 'กรอกความคิดเห็น ข้อเสนอแนะ หรือปัญหาที่พบ...',
                alignLabelWithHint: true,
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
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton.icon(
          onPressed: _isSending ? null : _sendFeedback,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          icon: _isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send, size: 18),
          label: const Text('ส่ง Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
