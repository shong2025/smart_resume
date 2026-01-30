import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repository/resume_repository.dart';
import 'skill_event.dart';
import 'skill_state.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  final ResumeRepository repository;

  SkillBloc({required this.repository}) : super(SkillInitial()) {
    // =============================
    // LOAD
    // =============================
    on<LoadSkills>((event, emit) async {
      emit(SkillLoading());
      try {
        final skills = await repository.getSkills(event.resumeId);
        emit(SkillLoaded(skills));
      } catch (e) {
        emit(SkillError(e.toString()));
      }
    });

    // =============================
    // ADD
    // =============================
    on<AddSkillEvent>((event, emit) async {
      try {
        await repository.addSkill(event.skill);
        emit(SkillActionSuccess('Skill added successfully'));
      } catch (e) {
        emit(SkillError(e.toString()));
      }
    });

    // =============================
    // UPDATE
    // =============================
    on<UpdateSkillEvent>((event, emit) async {
      try {
        await repository.updateSkill(event.skill);
        emit(SkillActionSuccess('Skill updated successfully'));
      } catch (e) {
        emit(SkillError(e.toString()));
      }
    });

    // =============================
    // DELETE
    // =============================
    on<DeleteSkillEvent>((event, emit) async {
      try {
        await repository.deleteSkill(event.id);
        emit(SkillActionSuccess('Skill deleted successfully'));
      } catch (e) {
        emit(SkillError(e.toString()));
      }
    });
  }
}
