import 'dart:convert';

class ResumeAttachment {
  final String id;
  final String resumeId;
  final String imageUrl;
  final DateTime createdAt;

  ResumeAttachment({
    required this.id,
    required this.resumeId,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ResumeAttachment.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['image_url'] ?? '';
    String finalUrl = rawUrl;

    // ✅ إذا كان الرابط مخزناً كـ JSON (بسبب خطأ السيرفر)، قم بتصفيته
    if (rawUrl.startsWith('{')) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(rawUrl);
        if (decoded['data'] != null && decoded['data'] is Map) {
          finalUrl = decoded['data']['publicUrl']?.toString() ?? rawUrl;
        } else if (decoded['publicUrl'] != null) {
          finalUrl = decoded['publicUrl'].toString();
        } else if (decoded['url'] != null) {
          finalUrl = decoded['url'].toString();
        }
      } catch (e) {
        // البحث عن الرابط باستخدام RegExp في حال فشل الـ Decode
        final regExp = RegExp(r'https://[^\s"}]+');
        final match = regExp.firstMatch(rawUrl);
        if (match != null) finalUrl = match.group(0)!;
      }
    }

    return ResumeAttachment(
      id: json['id'].toString(),
      resumeId: json['resume_id'].toString(),
      imageUrl: finalUrl,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}
