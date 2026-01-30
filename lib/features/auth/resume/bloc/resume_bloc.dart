import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repository/resume_repository.dart';
import 'resume_event.dart';
import 'resume_state.dart';

class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final ResumeRepository repository;

  ResumeBloc({required this.repository}) : super(ResumeInitial()) {
    on<LoadResumes>((event, emit) async {
      emit(ResumeLoading());
      try {
        final resumes = await repository.getResumes();
        emit(ResumeLoaded(resumes));
      } catch (e) {
        emit(ResumeError(e.toString()));
      }
    });

    on<AddResumeEvent>((event, emit) async {
      emit(ResumeLoading());
      try {
        await repository.addResume(event.resume);
        emit(ResumeActionSuccess());
      } catch (e) {
        emit(ResumeError(e.toString()));
      }
    });

    on<UpdateResumeEvent>((event, emit) async {
      emit(ResumeLoading());
      try {
        await repository.updateResume(event.resume);
        emit(ResumeActionSuccess());
      } catch (e) {
        emit(ResumeError(e.toString()));
      }
    });

    on<DeleteResumeEvent>((event, emit) async {
      emit(ResumeLoading());
      try {
        await repository.deleteResume(event.id);
        final resumes = await repository.getResumes();
        emit(ResumeLoaded(resumes));
      } catch (e) {
        emit(ResumeError(e.toString()));
      }
    });
  }
}
