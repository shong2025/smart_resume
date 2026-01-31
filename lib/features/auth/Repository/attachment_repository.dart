import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../resume/models/resume_attachment_model.dart';

class AttachmentRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// رفع الصورة باستخدام Edge Function
  Future<String?> uploadAttachment({
    required File file,
    required String resumeId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Session expired');

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes).replaceAll('\n', '').replaceAll('\r', '');
      
      final extension = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';

      print('🚀 [1/2] Sending to Edge Function...');
      
      final response = await _client.functions.invoke(
        'upload_resume_image',
        body: {
          'fileName': fileName,
          'base64Data': base64Image,
          'resumeId': resumeId,
          'userId': user.id,
        },
      );

      if (response.status == 200 || response.status == 201) {
        // ✅ ملاحظة: السيرفر يقوم بحفظ البيانات في الجدول تلقائياً
        // لذا لا نقوم بعمل insert هنا لمنع التكرار
        
        dynamic data = response.data;
        if (data is String) data = jsonDecode(data);

        String? finalUrl;
        if (data is Map) {
          if (data['data'] != null && data['data'] is Map) {
            finalUrl = data['data']['publicUrl']?.toString();
          } 
          finalUrl ??= data['publicUrl']?.toString() ?? data['url']?.toString();
        }

        print('✅ [2/2] Upload Success. URL: $finalUrl');
        return finalUrl;
      }
      return null;
    } catch (e) {
      print('❌ Error in uploadAttachment: $e');
      return null;
    }
  }

  /// جلب المرفقات
  Future<List<ResumeAttachment>> getAttachments(String resumeId) async {
    try {
      final response = await _client
          .from('resume_attachments')
          .select()
          .eq('resume_id', resumeId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      // الموديل سيقوم بتصفية الروابط تلقائياً عند الاستدعاء
      return data.map((e) => ResumeAttachment.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error fetching attachments: $e');
      return [];
    }
  }
}
