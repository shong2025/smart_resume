import 'package:supabase_flutter/supabase_flutter.dart';

import '../resume/models/resume_model.dart';
import '../resume/models/personal_info_model.dart';
import '../resume/models/experience_model.dart';
import '../resume/models/education_model.dart';
import '../resume/models/skill_model.dart';

class ResumeRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // =============================
  // HELPERS
  // =============================
  String _requireUser() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return userId;
  }

  // =============================
  // RESUMES
  // =============================
  Future<List<Resume>> getResumes() async {
    final userId = _requireUser();

    final response = await _client
        .from('resumes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Resume.fromJson(e))
        .toList();
  }

  Future<void> addResume(Resume resume) async {
    final userId = _requireUser();

    await _client.from('resumes').insert({
      'user_id': userId,
      'title': resume.title,
      'template_id': resume.templateId,
    });
  }

  Future<void> updateResume(Resume resume) async {
    if (resume.id == null) {
      throw Exception('Resume id is null');
    }

    await _client.from('resumes').update({
      'title': resume.title,
      'template_id': resume.templateId,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', resume.id!);
  }

  Future<void> deleteResume(String id) async {
    await _client.from('resumes').delete().eq('id', id);
  }

  // =============================
  // PERSONAL INFO
  // =============================
  Future<PersonalInfo?> getPersonalInfo(String resumeId) async {
    final response = await _client
        .from('personal_info')
        .select()
        .eq('resume_id', resumeId)
        .maybeSingle();

    if (response == null) return null;
    return PersonalInfo.fromJson(response);
  }

  Future<void> addPersonalInfo(PersonalInfo info) async {
    if (info.resumeId.isEmpty) {
      throw Exception('resumeId is empty');
    }

    await _client
        .from('personal_info')
        .insert(info.toInsertJson());
  }

  Future<void> updatePersonalInfo(PersonalInfo info) async {
    if (info.id == null) {
      throw Exception('PersonalInfo id is null');
    }

    await _client
        .from('personal_info')
        .update(info.toUpdateJson())
        .eq('id', info.id!);
  }

  // =============================
  // EXPERIENCES
  // =============================
  Future<List<Experience>> getExperiences(String resumeId) async {
    final response = await _client
        .from('experiences')
        .select()
        .eq('resume_id', resumeId)
        .order('start_date', ascending: false);

    return (response as List)
        .map((e) => Experience.fromJson(e))
        .toList();
  }

  Future<void> addExperience(Experience exp) async {
    if (exp.resumeId.isEmpty) {
      throw Exception('resumeId is empty');
    }

    await _client
        .from('experiences')
        .insert(exp.toInsertJson());
  }

  Future<void> updateExperience(Experience exp) async {
    if (exp.id == null) {
      throw Exception('Experience id is null');
    }

    await _client
        .from('experiences')
        .update(exp.toUpdateJson())
        .eq('id', exp.id!);
  }

  Future<void> deleteExperience(String id) async {
    await _client.from('experiences').delete().eq('id', id);
  }

  // =============================
  // EDUCATION
  // =============================
  Future<List<Education>> getEducations(String resumeId) async {
    final response = await _client
        .from('education')
        .select()
        .eq('resume_id', resumeId)
        .order('start_year', ascending: false);

    return (response as List)
        .map((e) => Education.fromJson(e))
        .toList();
  }

  Future<void> addEducation(Education edu) async {
    if (edu.resumeId.isEmpty) {
      throw Exception('resumeId is empty');
    }

    await _client
        .from('education')
        .insert(edu.toInsertJson());
  }

  Future<void> updateEducation(Education edu) async {
    if (edu.id == null) {
      throw Exception('Education id is null');
    }

    await _client
        .from('education')
        .update(edu.toUpdateJson())
        .eq('id', edu.id!);
  }

  Future<void> deleteEducation(String id) async {
    await _client.from('education').delete().eq('id', id);
  }

  // =============================
  // SKILLS ✅
  // =============================
  Future<List<Skill>> getSkills(String resumeId) async {
    final response = await _client
        .from('skills')
        .select()
        .eq('resume_id', resumeId);

    return (response as List)
        .map((e) => Skill.fromJson(e))
        .toList();
  }

  Future<void> addSkill(Skill skill) async {
    if (skill.resumeId.isEmpty) {
      throw Exception('resumeId is empty');
    }

    await _client
        .from('skills')
        .insert(skill.toInsertJson());
  }

  Future<void> updateSkill(Skill skill) async {
    if (skill.id == null) {
      throw Exception('Skill id is null');
    }

    await _client
        .from('skills')
        .update(skill.toUpdateJson())
        .eq('id', skill.id!);
  }

  Future<void> deleteSkill(String id) async {
    await _client.from('skills').delete().eq('id', id);
  }
}
