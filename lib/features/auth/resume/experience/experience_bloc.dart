import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Repository/resume_repository.dart';
import 'experience_event.dart';
import 'experience_state.dart';


class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final ResumeRepository repository;

  ExperienceBloc({required this.repository}) : super(ExperienceInitial()) {
    on<LoadExperiences>(_onLoadExperiences);
    on<AddExperienceEvent>(_onAddExperience);
    on<UpdateExperienceEvent>(_onUpdateExperience);
    on<DeleteExperienceEvent>(_onDeleteExperience);
  }

  Future<void> _onLoadExperiences(
      LoadExperiences event, Emitter<ExperienceState> emit) async {
    emit(ExperienceLoading());
    try {
      final exps = await repository.getExperiences(event.resumeId);
      emit(ExperienceLoaded(exps));
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }

  Future<void> _onAddExperience(
      AddExperienceEvent event, Emitter<ExperienceState> emit) async {
    try {
      await repository.addExperience(event.experience);
      emit(const ExperienceSuccess('Experience added successfully'));
      add(LoadExperiences(event.experience.resumeId));
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }

  Future<void> _onUpdateExperience(
      UpdateExperienceEvent event, Emitter<ExperienceState> emit) async {
    try {
      await repository.updateExperience(event.experience);
      emit(const ExperienceSuccess('Experience updated successfully'));
      add(LoadExperiences(event.experience.resumeId));
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }

  Future<void> _onDeleteExperience(
      DeleteExperienceEvent event, Emitter<ExperienceState> emit) async {
    try {
      await repository.deleteExperience(event.id);
      emit(const ExperienceSuccess('Experience deleted successfully'));
      // بعد الحذف، نعيد تحميل البيانات
      // إذا أردت يمكنك تمرير resumeId للحذف
      add(LoadExperiences('')); // لاحقًا نعدل لتمرير resumeId الصحيح
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }
}
