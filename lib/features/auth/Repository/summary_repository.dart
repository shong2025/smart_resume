import 'package:supabase_flutter/supabase_flutter.dart';

import '../resume/models/summary_model.dart';


class SummaryRepository {
  final _client = Supabase.instance.client;

  Future<Summary?> getSummary(String resumeId) async {
    final res = await _client
        .from('summary')
        .select()
        .eq('resume_id', resumeId)
        .maybeSingle();

    if (res == null) return null;
    return Summary.fromJson(res);
  }

  Future<void> addSummary(Summary summary) async {
    await _client.from('summary').insert(summary.toInsertJson());
  }

  Future<void> updateSummary(Summary summary) async {
    await _client
        .from('summary')
        .update(summary.toUpdateJson())
        .eq('id', summary.id!);
  }
}
