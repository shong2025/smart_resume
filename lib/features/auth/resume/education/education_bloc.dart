import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Repository/resume_repository.dart';
import 'education_event.dart';
import 'education_state.dart';

class EducationBloc extends Bloc<EducationEvent, EducationState> {
  final ResumeRepository repository;
  EducationBloc({required this.repository}) : super(EducationInitial()) {
    on<LoadEducation>((event, emit) async {
      emit(EducationLoading());
      try {
        final list = await repository.getEducations(event.resumeId);
        emit(EducationLoaded(list));
      } catch (e) {
        emit(EducationError(e.toString()));
      }
    });

    on<AddEducationEvent>((event, emit) async {
      try {
        await repository.addEducation(event.education);
        emit(EducationActionSuccess());
      } catch (e) {
        emit(EducationError(e.toString()));
      }
    });

    on<UpdateEducationEvent>((event, emit) async {
      try {
        await repository.updateEducation(event.education);
        emit(EducationActionSuccess());
      } catch (e) {
        emit(EducationError(e.toString()));
      }
    });

    on<DeleteEducationEvent>((event, emit) async {
      try {
        await repository.deleteEducation(event.id);
        emit(EducationActionSuccess());
      } catch (e) {
        emit(EducationError(e.toString()));
      }
    });
  }
}
